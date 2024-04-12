local Vector3, __Vector2 = Vector3.new, Vector2.new; 
local HSV, Color3, Draw, Color3New = Color3.fromHSV, Color3.fromRGB, Drawing.new, Color3.new;
local Insert, Remove, Clear = table.insert, table.remove, table.clear;
local Sleep = task.wait; 
local Instance = Instance.new;
local Max = math.max;
local Clamp, Floor = math.clamp, math.floor;

local function Lerp(a, b, t) 
    return a + (b - a) * t; 
end;

local function Vector2(X, Y, R)
    return __Vector2(Floor(X), Floor(Y));
end; 

-- Services
local InputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");

local Library = { 
    Collection = { };
    classes = { };
    Graphics = { 
        ProcessInput = true;
        __FPS = 60;
        __ZIndex = 1;
        __RenderCache = { };
        __ZIndexCache = { };
        __ImmediateMemory = { Square = { }; Line = { }; Text = { }; Quad = { }; Triangle = { }; Circle = { } };
        __ImmediateCache = { };
        __back_buffer = { };
    }; 
};

--// Gui Class Definitions
Library.classes.Square = {
    Visible = true;
    Position = Vector2(0, 0);
    Size = Vector2(0, 0); 
    Filled = true;
    ZIndex = 1;
    Color = Color3(0, 0, 0);
    Transparency = 1;
};

Library.classes.Text = {
    Visible = true; 
    ZIndex = 1;
    Position = Vector2(0, 0);
    Size = Vector2(0, 0); 
    Text = "";
    TextBounds = Vector2(0, 0);
    Color = Color3(0, 0, 0);
    Outline = true;
    Transparency = 1;
};

Library.classes.Line = {
    Visible = true; 
    From = Vector2(0, 0); 
    To = Vector2(0, 0); 
    Thickness = 1; 
    Color = Color3(0, 0, 0);
    Transparency = 1;
};

Library.classes.Image = {
    Visible = true; 
    ZIndex = 1;
    Position = Vector2(0, 0);
    Size = Vector2(0, 0); 
    Data = "";
    Color = Color3(0, 0, 0);
    Transparency = 1;
};

Library.classes.Quad = { 
    Visible = true;
    PointA = Vector2(0, 0);
    PointB = Vector2(0, 0);
    PointC = Vector2(0, 0);
    PointD = Vector2(0, 0);
    Size = Vector2(0, 0); 
    Filled = true;
    ZIndex = 1;
    Color = Color3(0, 0, 0);
    Transparency = 1;
};

--@ Immediate Mode Drawing
local DRAW_CALLS = 0;

function Library.Graphics:ClearScreen()
    for i, v in pairs(self.__ImmediateMemory) do 
        for x, render in pairs(v) do 
            render.Render:Remove();
            Clear(render);
            v[x] = nil;
        end; 
    end; 

    for i, v in pairs(self.__ImmediateCache) do 
        self.__ImmediateMemory[v.Class][i] = v; 
        self.__ImmediateCache[i] = nil; 
        v.Visible = false;
    end; 

    DRAW_CALLS = 0;
end;

Library.Graphics.ImmediateDraw = function(Class, Properties, BackBuffer)
    if (Properties.Visible == false) then return; end; 
    DRAW_CALLS += 1;

    local Memory = Library.Graphics.__ImmediateMemory[Class];
    local DRAW_ID = DRAW_CALLS;
    local Drawing = Memory[#Memory] or { Render = Draw(Class); Class = Class };
    Remove(Memory, #Memory);
    Drawing.Render.Visible = true; 

    for p, v in Properties do 
        Drawing.Render[p] = v; 
    end;    

    Insert(Library.Graphics.__ImmediateCache, Drawing);

    return Drawing;
end;

Library.Graphics.ImmediateDrawPolygon = function(Poly, Properties, Bounds)
    if (#Poly == 3) then 
        Properties.PointA = Vector2(Clamp(Poly[1].x, Bounds.Min.x, Bounds.Max.x), Clamp(Poly[1].y, Bounds.Min.y, Bounds.Max.y));
        Properties.PointB = Vector2(Clamp(Poly[2].x, Bounds.Min.x, Bounds.Max.x), Clamp(Poly[2].y, Bounds.Min.y, Bounds.Max.y));
        Properties.PointC = Vector2(Clamp(Poly[3].x, Bounds.Min.x, Bounds.Max.x), Clamp(Poly[3].y, Bounds.Min.y, Bounds.Max.y));
        Library.Graphics.ImmediateDraw("Triangle", Properties);
    else 
        Properties.Filled = nil;
        for i = 1, #Poly do 
            local To = (Poly[i + 1] or Poly[1]); 
            local From = Poly[i];
            Properties.From = Vector2(Clamp(From.x, Bounds.Min.x, Bounds.Max.x), Clamp(From.y, Bounds.Min.y, Bounds.Max.y));
            Properties.To = Vector2(Clamp(To.x, Bounds.Min.x, Bounds.Max.x), Clamp(To.y, Bounds.Min.y, Bounds.Max.y));
            Library.Graphics.ImmediateDraw("Line", Properties);
        end; 
    end; 
end;

--@ Signal Class 
-- :Connect<:Close>, :Close, :Fire, :Once, :Wait
local Signal = { };
Signal.__index = Signal;

function Signal:Connect(Callback)
    local Listener = { 
        Type = "Listener";
        Callback = Callback; 
        Id = #self.Listeners + 1; 
    };

    local Sig = self;
    function Listener:Close()
        Clear(Listener);
        Remove(Sig.Listeners, Listener.Id);
        if (#Sig.Listeners == 0) then 
            self.Active = false; 
        end; 
    end; 
    
    self.Active = true;
    Insert(self.Listeners, Listener);
    return Listener;
end; 

function Signal:Once(Callback)
    local Connection; Connection = self:Connect(function()
        Connection:Close();
        Callback();
    end);

    return Connection 
end; 

function Signal:Wait()
    self.Waiting = true; 
    while (self.Waiting) do Sleep(0) end;
end; 

function Signal:Fire(...)
    self.Waiting = false;
    for i, Listener in next, self.Listeners do 
        Listener.Callback(...);
    end; 
end; 

function Signal:Close()
    for i, Listener in next, self.Listeners do 
        Listener:Close();
    end; 

    table.clear(self);
end; 

function Library.Signal() 
    local NewSignal = {
        Type = "Signal"; 
        Active = false;
        Listeners = { }; 
        Waiting = false; 
    };

    setmetatable(NewSignal, Signal);
    return NewSignal;
end;

--@ Bin Class
-- :Add, :Clear
local Bin = { };
Bin.__index = Bin; 

function Bin:Clear()
    for i, g in pairs(self.Collection) do 
        local Type = typeof(g);
        local IsTable = (Type == "table");

        if (IsTable and g.Remove) then 
            g:Remove();
            continue;
        elseif (IsTable and g.Type) then 
            Type = g.Type;
        end;

        if (Type == "RBXScriptConnection") then 
            g:Disconnect(); 
        elseif (Type == "Instance") then 
            g:Destroy(); 
        elseif (Type == "Signal" or Type == "Listener") then 
            g:Close();
        elseif (Type == "Render") then 
            g:Destroy();
        elseif (IsTable) then 
            ClearTable(g); 
        end;
    end; 
end; 

function Bin:Add(Object)
    Insert(self.Collection, Object);
    return Object;
end; 

function Library.Bin()
    local NewBin = { 
        Type = "Bin";
        Collection = { };
    };

    setmetatable(NewBin, Bin);
    return NewBin; 
end; 

--@ Helper Math functions
function Library.IsMouseOnObject(Object)
    local Mouse = InputService:GetMouseLocation(); 
    local Size = (Object.TextBounds or Object.Size);

    local X = (Mouse.X >= Object.__AbsolutePosition.X and Mouse.X <= Object.__AbsolutePosition.X + Size.X); 
    local Y = (Mouse.Y >= Object.__AbsolutePosition.Y and Mouse.Y <= Object.__AbsolutePosition.Y + Size.Y);

    return (X and Y);
end; 

function Library.ObjectInBoundsOf(Object1, Object2)
    local Object1Size = (Object1.TextBounds or Object1.Size);
    local Object2Size = (Object2.TextBounds or Object2.Size);

    local X = (Object1.__AbsolutePosition.X >= Object2.__AbsolutePosition.X and Object1.__AbsolutePosition.X <= Object2.__AbsolutePosition.X + Object2Size.X);
    local Y = (Object1.__AbsolutePosition.Y >= Object2.__AbsolutePosition.Y and Object1.__AbsolutePosition.Y <= Object2.__AbsolutePosition.Y + Object2Size.Y);
    if (not X or not Y) then return false; end; --// Avoid Calculating 2 more values 
    local X2 = (Object1.__AbsolutePosition.X + Object1Size.X >= Object2.__AbsolutePosition.X and Object1.__AbsolutePosition.X + Object1Size.X <= Object2.__AbsolutePosition.X + Object2Size.X);
    local Y2 = (Object1.__AbsolutePosition.Y + Object1Size.Y >= Object2.__AbsolutePosition.Y and Object1.__AbsolutePosition.Y + Object1Size.Y <= Object2.__AbsolutePosition.Y + Object2Size.Y);

    return (X and Y and X2 and Y2);
end;

function Library.IsMouseOnHigherZIndexThan(Object)
    for i, obj in next, Library.Graphics.__RenderCache do 
        if (not obj.Visible or obj.Transparency <= 0) then continue end; 

        if (obj.Filled and obj.ZIndex > Object.ZIndex and Library.IsMouseOnObject(obj)) then 
            return true;
        end; 
    end; 
end; 

--@ List Class 
function Library.List(Object)
    local List = { 
        Properties = {
            IgnoreUnFilled = false;
            IgnoreInvisible = false;
            InitialPadding = 0;
            Parent = Object;
            Padding = 5;
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        };
        ChildrenConnections = { };
    };

    function List:Update()
        if (not List.Properties.Parent or List.Properties.Parent.__Destroyed) then return end; 

        local X = (List.Properties.Parent.TextBounds or List.Properties.Parent.Size).X; 
        local Y = (List.Properties.Parent.TextBounds or List.Properties.Parent.Size).Y;
        local TotalWidth = 0;
        local TotalHeight = 0;
        local MaxChildWidth = 0;
        local MaxChildHeight = 0;

        for i, Child in next, self.Parent.__Children do
            if (self.Properties.IgnoreUnFilled and not Child.Filled) or (self.Properties.IgnoreInvisible and not Child.Visible) or (Child.__Properties.IgnoreList) then continue end;
            local Size = (Child.TextBounds or Child.Size);
            TotalWidth = TotalWidth + Size.X + self.Padding;
            TotalHeight = TotalHeight + Size.Y + self.Padding;
            MaxChildWidth = Max(MaxChildWidth, Size.X);
            MaxChildHeight = Max(MaxChildHeight, Size.Y);
        end

        local StartX;
        local StartY;

        StartX = (self.HorizontalAlignment == Enum.HorizontalAlignment.Center and 
        (self.Properties.FillDirection == Enum.FillDirection.Horizontal and (X - TotalWidth + self.Padding) / 2 or X / 2) - (self.Properties.FillDirection == Enum.FillDirection.Vertical and MaxChildWidth / 2 or 0))
        or (self.HorizontalAlignment == Enum.HorizontalAlignment.Right and X - TotalWidth + self.Padding) or 0;
      
        StartY = (self.VerticalAlignment == Enum.VerticalAlignment.Center and 
        (self.Properties.FillDirection == Enum.FillDirection.Vertical and (Y - TotalHeight + self.Padding) / 2 or Y / 2) - (self.Properties.FillDirection == Enum.FillDirection.Horizontal and MaxChildHeight / 2 or 0))
        or (self.VerticalAlignment == Enum.VerticalAlignment.Bottom and Y - MaxChildHeight) or 0;
      
        local CurrentPosition = Vector2(StartX, StartY);
        if (self.Properties.FillDirection == Enum.FillDirection.Vertical and self.InitialPadding) then 
            CurrentPosition = CurrentPosition + Vector2(0, self.InitialPadding);
        end; 

        for i, ChildObject in next, Object.__Children do 
            if (self.Properties.IgnoreUnFilled and not ChildObject.Filled) or (self.Properties.IgnoreInvisible and not ChildObject.Visible) or (ChildObject.__Properties.IgnoreList) then continue end;
            local Size = (ChildObject.TextBounds or ChildObject.Size);
            ChildObject.Position = CurrentPosition + (ChildObject.__Properties.ListOffset or Vector2(0, 0));

            if self.Properties.FillDirection == Enum.FillDirection.Horizontal then
                CurrentPosition = CurrentPosition + Vector2(Size.X + self.Padding, 0);
            elseif self.Properties.FillDirection == Enum.FillDirection.Vertical then
                CurrentPosition = CurrentPosition + Vector2(0, Size.Y + self.Padding);
            end
        end 
    end; 

    function List:GetSize()
        local TotalWidth = 0;
        local TotalHeight = 0;

        for i, Child in next, self.Parent.__Children do
            if (self.Properties.IgnoreUnFilled and not Child.Filled) or (self.Properties.IgnoreInvisible and not Child.Visible) or (Child.__Properties.IgnoreList) then continue end;
            local Size = (Child.TextBounds or Child.Size);
            TotalWidth = TotalWidth + Size.X + self.Padding;
            TotalHeight = TotalHeight + Size.Y + self.Padding;
        end; 

        return {
            Width = TotalWidth; 
            Height = TotalHeight; 
        }; 
    end; 
    
    setmetatable(List, {
        __index = function(self, index) 
            return self.Properties[index];
        end; 

        __newindex = function(self, index, value)
            rawset(self.Properties, index, value);
            self:Update();
        end; 
    });

    List.Parent.ChildAdded:Connect(function(c) 
        List:Update(); 
    end);

    List.Parent.ChildRemoved:Connect(function(c) 
        List:Update(); 
    end);

    List.Parent.Changed:Connect(function(Property) 
        if (Property) == "Size" then 
            List:Update(); 
        end; 
    end);

    List:Update();
    return List;
end;

function Library.Graphics:SetParent(Object, Parent)
    if (not Object or Object.__Destroyed) then return end; 

    if (Object.__Parent) then 
        Object.__Parent.__Children[Object.__ChildIndex] = nil;
    end;

    if (not Parent and Object.__Parent) then Object.__Parent.ChildRemoved:Fire(Object); end;
    if (Object._Parent) then Object.__Parent = Parent; end;
    
    if (Parent) then 
        Insert(Parent.__Children, Object);
        Object.__Parent.ChildAdded:Fire(Object);
        Object.__ChildIndex = #Parent.__Children;
        Library.Graphics:UpdateChildren(Object.__Parent, "Visible");
    end;
end

function Library.Graphics:UpdateChildren(Object, Property) 
    if (not Object or Object.__Destroyed or #Object.__Children == 0) then return end; 

    if (Property == "Position") then 
        local Position = Object.__AbsolutePosition;

        for i, Child in next, Object.__Children do
            if (Child.Visible) then 
                if (Child.__ClassName == "Line") then
                    Child.__Drawing.From = Position + Child.__Properties.From;
                    Child.__Drawing.To = Position + Child.__Properties.To;
                else 
                    Child.__AbsolutePosition = (Position + (Child.__Properties.Position or Vector2(0, 0)));
                    Child.__Drawing.Position = Child.__AbsolutePosition;
                end;

                self:UpdateChildren(Child, "Position");
            end;
        end
    elseif (Property == "Visible") then 
        for i, Child in next, Object.__Children do 
            if (not Object.__Drawing.Visible) then 
                Child.__CachedVisiblity = Child.__Drawing.Visible;
                Child.__Drawing.Visible = false;
                Child.Changed:Fire(Property, Child.__Drawing.Visible);
            else 
                Child.__Drawing.Visible = ((Child.__CachedVisiblity ~= nil) and Child.__CachedVisiblity) or Child.__AbsoluteVisiblity;
                Child.Changed:Fire(Property, Child.__Drawing.Visible);
            end; 

            Child.__Properties.Visible = Child.__Drawing.Visible;
            self:UpdateChildren(Child, "Visible");                     
        end;    
    end; 
end

--@ Tween Class 
local Tween = { };
Tween.__index = Tween;

function Tween:Play()
    self.PlaybackState = Enum.PlaybackState.Playing;
    self.__Stepped = RunService.Stepped:Connect(function(_, DeltaTime)
        if (self.__Cancelled or self.Object.__Destroyed) then 
            self.__Stepped:Disconnect();
            return; 
        elseif (self.__Paused) then 
            return;
        end; 

        self.__Elapsed = (self.__Elapsed + DeltaTime); 

        local Alpha = TweenService:GetValue(self.__Elapsed / self.Info.Time, self.Info.EasingStyle, self.Info.EasingDirection);
        
        for p, g in next, self.Goals do 
            if (typeof(g) == "Color3") then 
                local R, G, B = Lerp(self.__Original[p].R, g.R, Alpha), Lerp(self.__Original[p].G, g.G, Alpha), Lerp(self.__Original[p].B, g.B, Alpha);
                self.Object:SetProperty(p, Color3New(R, G, B));
            elseif (typeof(g) == "Vector2") then 
                local X, Y = Lerp(self.__Original[p].X, g.X, Alpha), Lerp(self.__Original[p].Y, g.Y, Alpha);
                self.Object:SetProperty(p, Vector2(X, Y));
            else 
                self.Object:SetProperty(p, Lerp(self.__Original[p], g, Alpha));
            end; 
        end; 

        if (self.__Elapsed >= self.Info.Time) then 
            self.__Stepped:Disconnect();
            self.Completed:Fire();
            self.PlaybackState = Enum.PlaybackState.Completed;
        end; 
    end);
end; 

function Tween:Pause()
    self.__Paused = true;
    self.PlaybackState = Enum.PlaybackState.Paused;
end; 

function Tween:Resume()
    self.__Paused = false; 
    self.PlaybackState = Enum.PlaybackState.Playing;
end; 

function Tween:Cancel() 
    self.__Cancelled = true;
    self.PlaybackState = Enum.PlaybackState.Cancelled;
end; 

function Tween.new(Object, TweenInfo, Goals)
    local NewTween = { 
        PlaybackState = Enum.PlaybackState.Begin;
        Completed = Library.Signal();
        Info = TweenInfo;
        Goals = Goals;
        Object = Object;
        __Original = { };
        __Elapsed = 0;
        __Stepped = nil;
        __Paused = false;
        __Cancelled = false;
    };

    for p, v in next, NewTween.Goals do 
        NewTween.__Original[p] = Object[p];
    end; 

    setmetatable(NewTween, Tween);
    return NewTween;
end;

function Library.Graphics:Create(Class, Properties)
    local ObjectBin =  Library.Bin();

    local Object = { 
        Type = "Render";
        __Drawing = Draw(Class);
        __Class = Library.classes[Class];
        __ClassName = Class;
        __Parent = (Properties and Properties.Parent);
        __Children = { };
        __AbsolutePosition = Vector2(0, 0);
        __AbsoluteVisiblity = Properties.Visible or false;
        __Properties = (Properties or { });
        __ChildIndex = 0;
        __GlobalRenderIndex = 0;
        __Destroyed = false;
        __BIN = ObjectBin; 

        __Mouse1Down = false;
        __MouseEntered = false;
        Changed = ObjectBin:Add(Library.Signal()); 
        ChildAdded = ObjectBin:Add(Library.Signal()); 
        ChildRemoved = ObjectBin:Add(Library.Signal());
        MouseEnter = ObjectBin:Add(Library.Signal()); 
        MouseLeave = ObjectBin:Add(Library.Signal()); 
        Mouse1Down = ObjectBin:Add(Library.Signal()); 
        Mouse1Up = ObjectBin:Add(Library.Signal());
        Mouse1Click = ObjectBin:Add(Library.Signal());
    };

    if (Class == "Square") then Object.__Drawing.Filled = false; end;
    
    function Object:SetProperty(Property, Value)
        if (self.__Destroyed) then return end; 

        if (Property == "Parent") then 
            Library.Graphics:SetParent(self, Value);
        elseif (Property == "Position") then
            if (not Value) then return; end;
            local Position = Value; 
            if (self.__Parent) then Position = (Value + self.__Parent.__Drawing.Position) end; 
    
            self.__Properties.Position = Value; 
            self.__Drawing.Position = Position;
            self.__AbsolutePosition = Position;

            Library.Graphics:UpdateChildren(self, Property);
        elseif (Property == "From") then 
            local From = Value;
            if (self.__Parent) then From = (Value + self.__Parent.__Drawing.Position) end; 

            self.__Properties.From = Value;
            self.__Drawing.From = Value; 
        elseif (Property == "To") then 
            local To = Value;
            if (self.__Parent) then To = (Value + self.__Parent.__Drawing.Position) end; 

            self.__Properties.To = Value;
            self.__Drawing.To = Value; 
        elseif (Property == "Visible") then 
            self.__Drawing.Visible = Value; 
            self.__Properties.Visible = Value;

            Library.Graphics:UpdateChildren(self, Property);
            Object.Position = Object.Position;
        elseif (Property == "ListOffset") then 
            self.__Properties.ListOffset = Value; 
        elseif (Property == "IgnoreList") then 
            self.__Properties[Property] = Value;
        else 
            self.__Drawing[Property] = Value; 
            self.__Properties[Property] = Value;
        end; 

        self.Changed:Fire(Property, Value);
    end; 

    function Object:Tween(TweenInfo, Goals)
        return Tween.new(Object, TweenInfo, Goals);
    end;

    function Object:Destroy()
        Library.Graphics.__RenderCache[self.__GlobalRenderIndex] = nil;

        if (self.__Parent) then 
            self.__Parent.__Children[self.__ChildIndex] = nil; 
        end; 

        for i, c in next, self.__Children do 
            c:Destroy(); 
        end; 

        Object.__Drawing:Remove();
        self.Parent = nil;
        self.__Destroyed = true;
        self.__BIN:Clear();
    end; 

    setmetatable(Object, {
        __index = function(self, index)
            if (self.__Class[index]) then 
                return (self.__Properties[index] or self.__Drawing[index]);
            end; 
        end;

        __newindex = function(self, index, value)
            if (index == "__CachedVisiblity") then 
                rawset(self, index, value);
                return;
            end;

            self:SetProperty(index, value); 
        end;
    });

    Object.__Properties.IgnoreList = false;
    Object.__Drawing.ZIndex = self.__ZIndex;
    self.__ZIndex = self.__ZIndex + 1;

    for p, v in next, Properties do 
        Object:SetProperty(p, v); 
    end;

    Insert(self.__RenderCache, Object);
    Object.__GlobalRenderIndex = #self.__RenderCache;
    return Object; 
end;

Library.Collection = Library.Bin();
Library.Graphics.OnPaint = Library.Signal();

Library.Collection:Add(InputService.InputBegan:Connect(function(Input, Gme)
    if (not Library.Graphics.ProcessInput) then return end;

    for i, object in pairs(Library.Graphics.__RenderCache) do 
        if (not object.Visible or not (object.Mouse1Down.Active or object.Mouse1Click.Active)) then continue end;

        if (Input.UserInputType == Enum.UserInputType.MouseButton1) then 
            if (Library.IsMouseOnObject(object) and not Library.IsMouseOnHigherZIndexThan(object)) then 
                object.__Mouse1Down = true; 
                object.Mouse1Down:Fire(Input, Gme);
            end; 
        end; 
    end; 
end));

Library.Collection:Add(InputService.InputEnded:Connect(function(Input, Gme)
    if (not Library.Graphics.ProcessInput) then return end;

    for i, object in pairs(Library.Graphics.__RenderCache) do 
        if (not object.Visible or not (object.Mouse1Up.Active or object.Mouse1Click.Active)) then continue end; 

        if (Input.UserInputType == Enum.UserInputType.MouseButton1) then 
            if (object.Visible and Library.IsMouseOnObject(object) and not Library.IsMouseOnHigherZIndexThan(object)) then 
                if (object.__Mouse1Down) then object.Mouse1Click:Fire(Input, Gme); end;
                object.__Mouse1Down = false; 
                if (not object.Mouse1Up.Active) then break end; -- Means the engine was unloaded
                object.Mouse1Up:Fire(Input, Gme);
            end; 
        end; 
    end; 
end));

Library.Collection:Add(InputService.InputChanged:Connect(function(Input, Gme)
    if (not Library.Graphics.ProcessInput) then return end;
    if not (Input.UserInputType == Enum.UserInputType.MouseMovement) then return end;

    for i, object in pairs(Library.Graphics.__RenderCache) do
        if (not object.Visible or not object.MouseEnter.Active or not object.MouseLeave.Active) then continue; end; 

        if (not object.__MouseEntered and Library.IsMouseOnObject(object)) then -- and not Library.IsMouseOnHigherZIndexThan(object)
            object.MouseEnter:Fire(Input, Gme); 
            object.__MouseEntered = true;
        elseif (object.__MouseEntered and not Library.IsMouseOnObject(object)) then
            object.MouseLeave:Fire(Input, Gme);
            object.__MouseEntered = false;
        end;  
    end; 
end));

coroutine.resume(coroutine.create(function()
    while (true) do 
        Library.Graphics:ClearScreen();
        Library.Graphics.OnPaint:Fire();
        task.wait(1 / Library.Graphics.__FPS);
    end;
end));

return Library;
