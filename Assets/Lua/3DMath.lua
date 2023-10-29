--[[
    Documentation: 

    Cameras - 
        Camera.new({0, 0}, 60) @resolution, @fov 
    
    Objects -
        Object.new()

    Vector3 - 
        Vector3(0, 0, 0) @x, @y, @z
]]

local Vector2 = Vector2.new;
local cos, sin, sqrt, tan, rad, pi = math.cos, math.sin, math.sqrt, math.tan, math.rad, math.pi;

--@ Vector3 class (um because w duh)
local Vector3 = { };
Vector3.__index = Vector3;

--@ Metamethod overloads
Vector3.__add = function(self, v)
    local T = typeof(v);
    if (T == "table") then 
        return Vector3.new(self.x + v.x, self.y + v.y, self.z + v.z);
    else
        return Vector3.new(self.x + v, self.y + v, self.z + v);
    end;
end; 

Vector3.__sub = function(self, v)
    local T = typeof(v);
    if (T == "table") then 
        return Vector3.new(self.x - v.x, self.y - v.y, self.z - v.z);
    else
        return Vector3.new(self.x - v, self.y - v, self.z - v);
    end;
end; 

Vector3.__div = function(self, v)
    local T = typeof(v);
    if (T == "table") then 
        return Vector3.new(self.x / v.x, self.y / v.y, self.z / v.z);
    else
        return Vector3.new(self.x / v, self.y / v, self.z / v);
    end;
end; 

Vector3.__mul = function(self, v)
    local T = typeof(v);
    if (T == "table") then 
        return Vector3.new(self.x * v.x, self.y * v.y, self.z * v.z);
    else
        return Vector3.new(self.x * v, self.y * v, self.z * v);
    end;
end; 

function Vector3.new(x, y, z, w)
    local Vector = { x = x or 0; y = y or 0; z = z or 0; w = w or 1 };
    setmetatable(Vector, Vector3);
    return Vector; 
end; 

--@ Matrix Class
local Matrix = { };
Matrix.__index = Matrix; 

--@ Metamethod overloads
Matrix.__mul = function(self, m)
    local rm = { }; 

    for i = 1, #self do
        rm[i] = { };

        for j = 1, #m[1] do
            local sum = 0;

            for k = 1, #self[1] do
                sum = sum + self[i][k] * m[k][j];
            end;

            rm[i][j] = sum;
        end;

    end;

    setmetatable(rm, Matrix);
    return rm;
end;

function Matrix:MultiplyByVector(i)
    local v = Vector3.new();

    v.x = i.x * self[1][1] + i.y * self[2][1] + i.z * self[3][1] + i.w * self[4][1];
    v.y = i.x * self[1][2] + i.y * self[2][2] + i.z * self[3][2] + i.w * self[4][2];
    v.z = i.x * self[1][3] + i.y * self[2][3] + i.z * self[3][3] + i.w * self[4][3];
    v.w = i.x * self[1][4] + i.y * self[2][4] + i.z * self[3][4] + i.w * self[4][4];

    return v;
end;

function Matrix.Translate(v)
    return Matrix.new({
        {1, 0, 0, 0};
        {0, 1, 0, 0};
        {0, 0, 1, 0};
        {v.x, v.y, v.z, 1};
    });
end;

function Matrix.RotateX(rad)
    return Matrix.new({
        {1, 0, 0, 0};
        {0, cos(rad), sin(rad), 0};
        {0, -sin(rad), cos(rad), 0};
        {0, 0, 0, 1};
    });
end;
    
function Matrix.RotateY(rad)
    return Matrix.new({
        {cos(rad), 0, sin(rad), 0};
        {0, 1, 0, 0};
        {-sin(rad), 0, cos(rad), 0};
        {0, 0, 0, 1};
    });
end;

function Matrix.RotateZ(rad)
    return Matrix.new({
        {cos(rad), sin(rad), 0, 0};
        {-sin(rad), cos(rad), 0, 0};
        {0, 0, 1, 0};
        {0, 0, 0, 1};
    });
end;

function Matrix.Scale(Size)
    return Matrix.new({
        {Size.x, 0, 0, 0};
        {0, Size.y, 0, 0};
        {0, 0, Size.z, 0};
        {0, 0, 0, 1};
    });
end;

function Matrix.new(Data)
    local NewMatrix = (Data or { });
    setmetatable(NewMatrix, Matrix);

    if (Data) then return NewMatrix; end;

    for i = 1, 4 do 
        NewMatrix[i] = { };

        for v = 1, 4 do 
            NewMatrix[i][v] = 0;
        end; 
    end;

    return NewMatrix;
end;

--@ Projection Base
local Projection = { };

function Projection.new(Camera)
    local NP = { };

    NP.Near = Camera.NearPlane; 
    NP.Far = Camera.FarPlane; 
    NP.Right = tan(Camera.H_FieldOfView / 2); 
    NP.Left = -NP.Right;
    NP.Top = tan(Camera.V_FieldOfView / 2);
    NP.Bottom = -NP.Top;
    NP.Matrix = Matrix.new({
        {2 / (NP.Right - NP.Left), 0, 0, 0};
        {0, 2 / (NP.Top - NP.Bottom), 0, 0};
        {0, 0, (NP.Far + NP.Near) / (NP.Far - NP.Near), 1};
        {0, 0, -2 * NP.Near * NP.Far / (NP.Far - NP.Near), 0};
    })

    NP.WorldToScreenMatrix = Matrix.new({
        {Camera.Width / 2, 0, 0, 0};
        {0, -Camera.Height / 2, 0, 0};
        {0, 0, 1, 0};
        {Camera.Width / 2, Camera.Height / 2, 0, 1};
    });

    return NP;
end; 

--@ Object Class 
local Object = { }; 
Object.__index = Object; 

function Object.ParseObjectDataWithTextures(Data)
    local Verts = { };
    local Faces = { };

    for line in Data:gmatch("[^\r\n]+") do 
        local Words = {line:match("(%S+) (%S+) (%S+)%s?(%S*)")};
        local Key = line:sub(1, 2):gsub(" ", "");

        if (Key == "v") then 
            table.insert(Verts, {tonumber(Words[2]), tonumber(Words[3]), tonumber(Words[4]), 1});
        elseif (Key == "f") then 
            for i = 2, #Words do
                local Face = { };

                for index in Words[i]:gmatch("(%d+)/?") do
                    table.insert(Face, tonumber(index));
                end;

                table.insert(Faces, Face);
            end;
        end;
    end; 

    return Matrix.new(Verts), Faces;
end;

function Object.ParseObjectData(Data)
    local Verts = { };
    local Faces = { };

    for line in Data:gmatch("[^\r\n]+") do
        local Words = {line:match("(%S+) (%S+) (%S+)%s?(%S*)")};
        local Key = line:sub(1, 2):gsub(" ", "");

        if (Key == "v") then
            table.insert(Verts, {tonumber(Words[2]), tonumber(Words[3]), tonumber(Words[4]), 1});
        elseif (Key == "f") then
            table.insert(Faces, {tonumber(Words[2]), tonumber(Words[3]), tonumber(Words[4])});
        end;
    end;

    return Matrix.new(Verts), Faces;
end;

function Object:Project(Camera)
    local Vertexes = self.Vertexes;
    Vertexes = Vertexes * Matrix.Scale(self.Scale);
    Vertexes = Vertexes * Matrix.RotateX(self.Rotation.x) * Matrix.RotateY(self.Rotation.y) * Matrix.RotateZ(self.Rotation.z);
    Vertexes = Vertexes * Matrix.Translate(self.Position); 
    Vertexes = Vertexes * Camera:GetMatrix() * Camera.Projection.Matrix;

    for i = #Vertexes, 1, -1 do
        local Vertex = Vertexes[i];
        local W = Vertex[4];

        if Vertex[4] < Camera.NearPlane then
            table.remove(Vertexes, i)
            continue;
        end;

        Vertexes[i] = {Vertex[1] / W, Vertex[2] / W, Vertex[3] / W, 1.0};
    end
    
    Vertexes = Vertexes * Camera.Projection.WorldToScreenMatrix;

    for i = #Vertexes, 1, -1 do
        Vertexes[i] = Vector2(Vertexes[i][1], Vertexes[i][2]);
    end;

    return Vertexes, self.Faces;
end; 

function Object:Get2DBoundingBox(Camera, Vertexes, Faces)
    local Vertexes, Faces = Vertexes, Faces; 
    if (not Vertexes) then Vertexes, Faces = self:Project(Camera); end;

    local MinX, MinY = math.huge, math.huge
    local MaxX, MaxY = -math.huge, -math.huge

    for i = 1, #Vertexes do
        local x, y = Vertexes[i].x, Vertexes[i].y

        if (x < MinX) then MinX = x; end; 
        if (x > MaxX) then MaxX = x; end; 
        if (y < MinY) then MinY = y; end; 
        if (y > MaxY) then MaxY = y; end;
    end;

    return Vector2(MinX, MinY), Vector2(MaxX, MaxY);
end

function Object.new()
    local NewObject = { 
        Position = Vector3.new(0, 0, 0); 
        Rotation = Vector3.new(0, math.rad(45), 0);
        Scale = Vector3.new(1, 1, 1);
        Vertexes = Matrix.new({ {0, 0, 0, 1}, {0, 1, 0, 1}, {1, 1, 0, 1}, {1, 0, 0, 1}, {0, 0, 1, 1}, {0, 1, 1, 1}, {1, 1, 1, 1}, {1, 0, 1, 1} });
        Faces = { {1, 2, 3, 4}, {5, 6, 7, 8}, {1, 5, 6, 2}, {3, 4, 8, 7}, {2, 3, 7, 6}, {1, 4, 8, 5} };
    }; 

    setmetatable(NewObject, Object);
    return NewObject;
end;

--@ Camera Class 
local Camera = { };
Camera.__index = Camera; 

function Camera:GetMatrix()
    local Rotation = Matrix.RotateX(self.Pitch) * Matrix.RotateY(self.Yaw);

    self.Forward = Rotation:MultiplyByVector(Vector3.new(0, 0, 1, 1));
    self.Up = Rotation:MultiplyByVector(Vector3.new(0, 1, 0, 1)); 
    self.Right = Rotation:MultiplyByVector(Vector3.new(1, 0, 0, 1));

    return self:Translate() * self:Rotate();
end;

function Camera:Translate()
    return Matrix.new({
        {1, 0, 0, 0};
        {0, 1, 0, 0};
        {0, 0, 1, 0};
        {-self.Position.x, -self.Position.y, -self.Position.z, 1};
    }); 
end;

function Camera:Rotate()
    return Matrix.new({
        {self.Right.x, self.Up.x, self.Forward.x, 0};
        {self.Right.y, self.Up.y, self.Forward.y, 0};
        {self.Right.z, self.Up.z, self.Forward.z, 0};
        {0, 0, 0, 1};
    }); 
end;

function Camera:WorldToScreenPoint(Point) 
    local Vertex = Vector3.new(0, 0, 0, 1);
    Vertex = Matrix.Translate(Point):MultiplyByVector(Vertex); 
    Vertex = self.Projection.Matrix:MultiplyByVector(self:GetMatrix():MultiplyByVector(Vertex));

    if (Vertex.w < self.NearPlane) then 
        return false;
    end; 

    Vertex = Vector3.new(Vertex.x / Vertex.w, Vertex.y / Vertex.w, Vertex.z / Vertex.x, 1);
    Vertex = self.Projection.WorldToScreenMatrix:MultiplyByVector(Vertex);
    
    return Vector2(Vertex.x, Vertex.y), NotClipping;
end;

function Camera:SetResolution(Resolution)
    self.Width = Resolution[1]; 
    self.Height = Resolution[2];
    self.V_FieldOfView = self.H_FieldOfView * (self.Height / self.Width);
    self.Projection = Projection.new(self);
end;

function Camera.new(Resolution, Fov)
    local NewCamera = {
        Width = (Resolution and Resolution[1] or 500); 
        Height = (Resolution and Resolution[2] or 600); 
        Position = Vector3.new(0, 0, 0);    
        Forward = Vector3.new(0, 0, 1, 1);
        Up = Vector3.new(0, 1, 0, 1);
        Right = Vector3.new(1, 0, 0, 1);
        H_FieldOfView = rad(Fov) or (pi / 3);
        NearPlane = 0.1; 
        FarPlane = 100;
        Pitch = 0; 
        Yaw = 0;
    };

    NewCamera.V_FieldOfView = NewCamera.H_FieldOfView * (NewCamera.Height / NewCamera.Width);
    NewCamera.Projection = Projection.new(NewCamera);
    
    setmetatable(NewCamera, Camera);
    return NewCamera;
end; 

return {
    Vector3 = Vector3.new;
    Object = Object; 
    Camera = Camera;
    Matrix = Matrix.new;
    Projection = Projection.new;
};
