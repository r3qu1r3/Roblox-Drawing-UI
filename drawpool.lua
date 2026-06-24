local Camera = workspace.CurrentCamera;
local DrawPool = {}
DrawPool.__drawingPools   = { {}, {}, {} }       -- all entries, per priority
DrawPool.__freeQueues     = { {}, {}, {} }        -- [priority][drawType] = { entry, ... }
DrawPool.__activeEntries  = { {}, {}, {} }        -- only entries used this frame
DrawPool.__cleanupTime    = 2.5
DrawPool.__idleDestroyTime = 5
DrawPool.__lastCleanup    = tick()

local ValidTypes = {
    Line     = true,
    Text     = true,
    Circle   = true,
    Square   = true,
    Quad     = true,
    Triangle = true,
    Image    = true,
}

-- ─────────────────────────────────────────────
-- Internal: lazily initialise a free-queue slot
-- ─────────────────────────────────────────────
local function getFreeQueue(self, priority, drawType)
    local pq = self.__freeQueues[priority]
    local q  = pq[drawType]
    if not q then
        q = {}
        pq[drawType] = q
    end
    return q
end

-- ─────────────────────────────────────────────
-- BeginFrame  –  O(active) not O(pool)
-- ─────────────────────────────────────────────
function DrawPool:BeginFrame()
    for p = 1, 3 do
        local active = self.__activeEntries[p]
        for i = 1, #active do
            active[i].UsedThisFrame = false
        end
    end
end

-- ─────────────────────────────────────────────
-- Allocate  –  O(1) fast path via free queue
-- ─────────────────────────────────────────────
function DrawPool:Allocate(drawType, priority)
    priority = priority or 1
    local queue = getFreeQueue(self, priority, drawType)

    local entry = queue[#queue]         -- pop from back (no shift cost)
    if entry then
        queue[#queue] = nil
        entry.Free = false
        -- add to active list so EndFrame can see it
        local active = self.__activeEntries[priority]
        active[#active + 1] = entry
        return entry
    end

    -- nothing free → create a new object
    assert(ValidTypes[drawType], ("Invalid drawing type: %s"):format(tostring(drawType)))
    local object = Drawing.new(drawType)
    entry = {
        Object       = object,
        Type         = drawType,
        Free         = false,
        UsedThisFrame = true,
        LastUpdated  = tick(),
    }
    local pool = self.__drawingPools[priority]
    pool[#pool + 1] = entry

    local active = self.__activeEntries[priority]
    active[#active + 1] = entry
    return entry
end

-- ─────────────────────────────────────────────
-- Draw  –  thin wrapper around Allocate
-- ─────────────────────────────────────────────
function DrawPool:Draw(drawType, properties, priority)
    local entry  = self:Allocate(drawType, priority)
    local object = entry.Object

    if properties then
        for prop, value in next, properties do
            -- only write if the value actually differs (avoids dirty-flagging the renderer)
            if object[prop] ~= value then
                object[prop] = value
            end
        end
    end

    object.Visible       = true
    entry.UsedThisFrame  = true
    entry.Free           = false
    entry.LastUpdated    = tick()
    return object
end

function DrawPool:Draw3DRing(cf, radius, segments, color)
    segments = segments or 32

    local points = {}

    for i = 0, segments do
        local theta = (i / segments) * math.pi * 2

        local localPos = Vector3.new(
            math.cos(theta) * radius,
            math.sin(theta) * radius,
            0
        )

        local worldPos = cf:PointToWorldSpace(localPos)

        local screenPos, visible = Camera:WorldToViewportPoint(worldPos)

        points[i + 1] = {
            Pos = Vector2.new(screenPos.X, screenPos.Y),
            Visible = visible
        }
    end

    for i = 1, segments do
        local p1 = points[i]
        local p2 = points[i + 1]

        if p1.Visible and p2.Visible then
            self:Draw("Line", {
                Color = color;
                Thickness = 2;
                From = p1.Pos;
                To = p2.Pos;
            })
        end
    end
end

-- ─────────────────────────────────────────────
-- EndFrame  –  O(active) not O(pool)
-- Returns freed entries to their per-type queues
-- ─────────────────────────────────────────────
function DrawPool:EndFrame()
    local now = tick()
    for p = 1, 3 do
        local active    = self.__activeEntries[p]
        local pq        = self.__freeQueues[p]
        local writeIdx  = 0

        for i = 1, #active do
            local entry = active[i]
            if entry.UsedThisFrame then
                -- keep in active list
                writeIdx = writeIdx + 1
                active[writeIdx] = entry
            else
                -- return to free queue
                entry.Object.Visible = false
                entry.Free           = true
                entry.LastUpdated    = now

                local q = pq[entry.Type]
                if not q then
                    q = {}
                    pq[entry.Type] = q
                end
                q[#q + 1] = entry
            end
        end

        -- clear stale tail of active list
        for i = writeIdx + 1, #active do
            active[i] = nil
        end
    end
end

-- ─────────────────────────────────────────────
-- Cleanup  –  remove objects idle for too long
-- Iterates only the full pool, runs infrequently
-- ─────────────────────────────────────────────
function DrawPool:Cleanup()
    local now = tick()
    if now - self.__lastCleanup < self.__cleanupTime then return end
    self.__lastCleanup = now

    for p = 1, 3 do
        local pool = self.__drawingPools[p]
        local pq   = self.__freeQueues[p]

        for i = #pool, 1, -1 do
            local entry = pool[i]
            if entry.Free and (now - entry.LastUpdated) >= self.__idleDestroyTime then
                entry.Object:Remove()
                pool[i] = pool[#pool]   -- O(1) swap-remove
                pool[#pool] = nil

                -- remove from free queue too
                local q = pq[entry.Type]
                if q then
                    for j = #q, 1, -1 do
                        if q[j] == entry then
                            q[j] = q[#q]
                            q[#q] = nil
                            break
                        end
                    end
                end
            end
        end
    end
end

return DrawPool;
