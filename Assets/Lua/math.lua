local EXPORTS = { }; 

local cos, sin, sqrt, tan, rad, pi = math.cos, math.sin, math.sqrt, math.tan, math.rad, math.pi;

--@ Vector3
--@ { x, y, z, w }
local vector3 = { type = "Vector3", Type = "Vector3" };
vector3.__index = vector3;

--@ Metamethod overloads
vector3.__add = function(self, v)
	local t = typeof(v);
	if (t == "table") then 
		return vector3.new(self.x + v.x, self.y + v.y, self.z + v.z);
	else
		return vector3.new(self.x + v, self.y + v, self.z + v);
	end;
end; 

vector3.__sub = function(self, v)
	local t = typeof(v);
	if (t == "table") then 
		return vector3.new(self.x - v.x, self.y - v.y, self.z - v.z);
	else
		return vector3.new(self.x - v, self.y - v, self.z - v);
	end;
end; 

vector3.__div = function(self, v)
	local t = typeof(v);
	if (t == "table") then 
		return vector3.new(self.x / v.x, self.y / v.y, self.z / v.z);
	else
		return vector3.new(self.x / v, self.y / v, self.z / v);
	end;
end; 

vector3.__mul = function(self, v)
	local t = typeof(v);
	if (t == "table") then 
		return vector3.new(self.x * v.x, self.y * v.y, self.z * v.z);
	else
		return vector3.new(self.x * v, self.y * v, self.z * v);
	end;
end; 

function vector3.cross_product(self, v2)
	local v = vector3.new();
	v.x = self.y * v2.z - self.z * v2.y;
	v.y = self.z * v2.x - self.x * v2.z;
	v.z = self.x * v2.y - self.y * v2.x;
	return v;
end;

function vector3.dot_product(self, v2)
	return self.x * v2.x + self.y * v2.y + self.z * v2.z
end;

function vector3.length(self)
	return sqrt(self:dot_product(self, self))
end;

function vector3.normalise(self)
	local l = self:length();
	return vector3.new(self.x / l, self.y / l, self.z / l);
end;

function vector3.new(x, y, z, w)
	local vector = { x = x or 0, y = y or 0, z = z or 0, w = w or 1 };
	setmetatable(vector, vector3);
	return vector; 
end; 

--@ Mat4 
local mat4 = { type = "Matrix" }; 
mat4.__index = mat4; 

mat4.__mul = function(self, Other)
	local T = Other.type or Other.Type or typeof(Other);

	if T == "Vector3" then
		return vector3.new(
			Other.x * self[1][1] + Other.y * self[2][1] + Other.z * self[3][1] + Other.w * self[4][1],
			Other.x * self[1][2] + Other.y * self[2][2] + Other.z * self[3][2] + Other.w * self[4][2],
			Other.x * self[1][3] + Other.y * self[2][3] + Other.z * self[3][3] + Other.w * self[4][3],
			Other.x * self[1][4] + Other.y * self[2][4] + Other.z * self[3][4] + Other.w * self[4][4]
		);
	elseif T == "Matrix" then
		local m = self.new();

		for i = 1, 4 do
			for j = 1, 4 do
				m[i][j] = self[i][1] * Other[1][j] + self[i][2] * Other[2][j] + self[i][3] * Other[3][j] + self[i][4] * Other[4][j];
			end;
		end;

		return m;
	end;
end;

function mat4.new(matrix_data) --{{f32; 4}; 4} 4x4
	local matrix = (matrix_data or { });
	setmetatable(matrix, mat4);

	if (matrix_data) then return matrix; end;

	for i = 1, 4 do 
		matrix[i] = { };
		for v = 1, 4 do 
			matrix[i][v] = 0;
		end; 
	end;

	return matrix;
end;

function mat4.translate(x, y, z)
	return mat4.new({
		{1.0, 0, 0, 0};
		{0, 1.0, 0, 0};
		{0, 0, 1.0, 0};
		{x, y, z, 1.0};
	});
end;

function mat4.z_rotation(rad)
	return mat4.new({
		{1, 0, 0, 0};
		{0, cos(rad), sin(rad), 0};
		{0, -sin(rad), cos(rad), 0};
		{0, 0, 0, 1};
	});
end;

function mat4.y_rotation(rad)
	return mat4.new({
		{cos(rad), 0, sin(rad), 0};
		{0, 1.0, 0, 0};
		{-sin(rad), 0, cos(rad), 0};
		{0, 0, 0, 1.0};
	});
end;

function mat4.x_rotation(rad)
	return mat4.new({
		{cos(rad), sin(rad), 0, 0};
		{-sin(rad), cos(rad), 0, 0};
		{0, 0, 1.0, 0};
		{0, 0, 0, 1.0};
	});
end;

function mat4.scale(x, y, z)
	return mat4.new({
		{x, 0, 0, 0};
		{0, y, 0, 0};
		{0, 0, z, 0};
		{0, 0, 0, 1.0};
	});
end;

function mat4.get_inverse(self) 
	local matrix = mat4.new();

	for i = 1, 3 do
		for j = 1, 3 do
			matrix[i][j] = self[j][i]
		end;
	end;

	matrix[4][4] = 1.0;

	matrix[4][1] = -(self[4][1] * matrix[1][1] + self[4][2] * matrix[2][1] + self[4][3] * matrix[3][1]);
	matrix[4][2] = -(self[4][1] * matrix[1][2] + self[4][2] * matrix[2][2] + self[4][3] * matrix[3][2]);
	matrix[4][3] = -(self[4][1] * matrix[1][3] + self[4][2] * matrix[2][3] + self[4][3] * matrix[3][3]);

	return matrix;
end; 

function mat4.look_at(position, target, up)
	local new_forward = (target - position):normalise();
	local new_right = up:cross_product(new_forward):normalise();
	local new_up = new_forward:cross_product(new_right);

	return mat4.new{
		{new_right.x, new_right.y, new_right.z, 0.0},
		{new_up.x, new_up.y, new_up.z, 0.0},
		{new_forward.x, new_forward.y, new_forward.z, 0.0},
		{position.x, position.y, position.z, 1.0}
	}, new_right; 
end;

function mat4.give_identity(self)	
	self[1][1] = 1; 
	self[2][2] = 1; 
	self[3][3] = 1; 
	self[4][4] = 1; 
	return self;
end; 

function mat4.projection(aspect_ratio, fov, far, near)
	local far = far or 1000; 
	local near = near or 0.1; 
	local fov_radius = 1 / tan(fov * 0.5 / 180 * pi);

	local projection = mat4.new{
		{aspect_ratio * fov_radius, 0, 0, 0},
		{0, fov_radius, 0, 0},
		{0, 0, far / (far - near), 1},
		{0, 0, (-far * near) / (far - near), 0}
	};

	return projection;
end; 

--// EXPORTS 
EXPORTS.mat4 = mat4; 
EXPORTS.vector3 = vector3; 

return EXPORTS;
