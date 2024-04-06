local EXPORTS = { }; 

local MATH = loadstring(game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Lua/math.lua"))(); 
local mat4, vector3 = MATH.mat4, MATH.vector3;
local rad, max = math.rad, math.max;

local OFFSET_VIEW = vector3.new(1, 1, 0);

local triangle = { };
triangle.__index = triangle;

function triangle.new(a, b, c)
	local new_triangle = {
		a = a or vector3.new();
		b = b or vector3.new(); 
		c = c or vector3.new(); 
		light = 0;
		_p = { };
	};
	
	table.insert(new_triangle._p, new_triangle.a);
	table.insert(new_triangle._p, new_triangle.b);
	table.insert(new_triangle._p, new_triangle.c);
	
	setmetatable(new_triangle, triangle);
	return new_triangle;
end;

local mesh = { existing_meshes = { } }; 
mesh.__index = mesh; 

function mesh.new(verts)
    local new_mesh = {
        verticies = verts or { }; 
        scale = vector3.new(1, 1, 1); 
        rotation = vector3.new(0, 0, 0); 
        position = vector3.new(0, 0, 0); 
        rgb = {255, 255, 255}; -- temporary hopefully will load textures soon (big maybe)
    }; 

    setmetatable(new_mesh, mesh); 
    table.insert(mesh.existing_meshes, new_mesh); 
    return new_mesh; 
end; 

function mesh.load_verticies_from_obj(self, obj_string)
    local verticies = { };
    local triangles = { };
	local has_textures = false

	for line in obj_string:gmatch("[^\r\n]+") do
		local s = { line:match("(%S+) (%S+) (%S+)%s?(%S*)") };
		local cmd = s[1];

		if cmd == "v" then
			local v = vector3.new(tonumber(s[2]), tonumber(s[3]), tonumber(s[4]));
			table.insert(verticies, v);
		elseif cmd == "f" then
			for i = 2, #s do
				local index = tonumber(s[i]:match("(%d+)/"))
				if index then
					has_textures = true
					break;
				end;
			end;

			if has_textures then
				break;
			end;
		end;
	end;

	for line in obj_string:gmatch("[^\r\n]+") do
		local s = { line:match("(%S+) (%S+) (%S+)%s?(%S*)") };
		local cmd = s[1];

		if cmd == "f" then
			local f = { };

			for i = 2, #s do
				local v, vt, vn = s[i]:match("(%d+)/?(%d*)/?(%d*)");
				table.insert(f, { tonumber(v), tonumber(vt), tonumber(vn) });
			end;

			local t = triangle.new(verticies[f[1][1]], verticies[f[2][1]], verticies[f[3][1]]);
			table.insert(triangles, t);
		end;
	end;

    self.verticies = triangles;
end; 

local camera = { }; 
camera.__index = camera;

function camera.new(fov, aspect_ratio, resolution) 
    if (not resolution) then error("[Camera]: you need to set a resolution whilst creating a new camera"); return end; 

    local new_camera = {    
        field_of_view = fov or 60; 
        yaw = 0; 
        resolution = resolution;
        look_vector = vector3.new(0, 0, 0); 
        right_vector = vector3.new(0, 0, 0);
        position = vector3.new(0, 0, 0); 
        rotation = vector3.new(0, 0, 0); 
        projection = mat4.projection(aspect_ratio, 90);
    };

    setmetatable(new_camera, camera); 
    return new_camera; 
end; 

function camera:get_projected_mesh_tris(target_mesh, light_direction)
    local ProjctedPoints = { };

    local rot_z = mat4.z_rotation(rad(target_mesh.rotation.x));
    local rot_x = mat4.x_rotation(rad(target_mesh.rotation.z));
    local rot_y = mat4.y_rotation(rad(target_mesh.rotation.y));
    local translation = mat4.translate(target_mesh.position.x, target_mesh.position.y, target_mesh.position.z);
    local scale = mat4.scale(target_mesh.scale.x, target_mesh.scale.y, target_mesh.scale.z);
    
    local world_matrix = mat4.new():give_identity(); 
    world_matrix = rot_z * rot_x * rot_y;
    world_matrix = world_matrix * scale;
    world_matrix = world_matrix * translation;

    local camera_rot_matrix = mat4.y_rotation(rad(self.yaw));
    local up_vector = vector3.new(0, 1, 0);
    local target_vector = vector3.new(0, 0, 1);
    local look_direction = camera_rot_matrix * target_vector;	
    target_vector = self.position + look_direction;
    self.look_vector = look_direction;


    local camera_matrix, right_vector = mat4.look_at(self.position, target_vector, up_vector); 
    local MatrixView = camera_matrix:get_inverse();
    self.right_vector = right_vector;

    for i, tri in pairs(target_mesh.verticies) do 
        local projected_tri = triangle.new(); 
        local transformed_tri = triangle.new();
        local view_tri = triangle.new();

        transformed_tri.a = world_matrix * tri.a;
        transformed_tri.b = world_matrix * tri.b;
        transformed_tri.c = world_matrix * tri.c;


        local Normal, Line1, Line2 = vector3.new(), vector3.new(), vector3.new(); 
        Line1 = transformed_tri.b - transformed_tri.a;
        Line2 = transformed_tri.c - transformed_tri.a;
        Normal = Line2:cross_product(Line1):normalise();

        local CameraRay = transformed_tri.a - self.position;

        if (Normal:dot_product(CameraRay) > 0.0) then 
            local LightDirection = light_direction:normalise();
            projected_tri.light = max(0.1, LightDirection:dot_product(Normal));

            view_tri.a = MatrixView * transformed_tri.a;
            view_tri.b = MatrixView * transformed_tri.b;
            view_tri.c = MatrixView * transformed_tri.c;

            projected_tri.a = self.projection * view_tri.a;
            projected_tri.b = self.projection * view_tri.b;
            projected_tri.c = self.projection * view_tri.c;


            projected_tri.a = projected_tri.a / projected_tri.a.w
            projected_tri.b = projected_tri.b / projected_tri.b.w;
            projected_tri.c = projected_tri.c / projected_tri.c.w;

            -- Put into view
            local OffsetView = vector3.new(1, 1, 0);
            projected_tri.a = projected_tri.a + OffsetView;
            projected_tri.b = projected_tri.b + OffsetView;
            projected_tri.c = projected_tri.c + OffsetView;

            projected_tri.a.x = projected_tri.a.x * 0.5 * self.resolution[1]; 
            projected_tri.a.y = projected_tri.a.y * 0.5 * self.resolution[2]; 
            projected_tri.b.x = projected_tri.b.x * 0.5 * self.resolution[1]; 
            projected_tri.b.y = projected_tri.b.y * 0.5 * self.resolution[2]; 
            projected_tri.c.x = projected_tri.c.x * 0.5 * self.resolution[1]; 
            projected_tri.c.y = projected_tri.c.y * 0.5 * self.resolution[2];

            table.insert(ProjctedPoints, projected_tri)
        end;

        table.sort(ProjctedPoints, function(t1, t2)
            local z1 = (t1.a.z + t1.b.z + t1.c.z) / 3;
            local z2 = (t2.a.z + t2.b.z + t2.c.z) / 3;

            return (z1 > z2);
        end);
    end; 

    return ProjctedPoints;
end; 

EXPORTS.camera = camera; 
EXPORTS.mesh = mesh; 

return EXPORTS;
