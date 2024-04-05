-- NOTE: This feature will be optional for those who have better graphics cards. 

local floor, abs = math.floor, math.abs;

local LINE_DRAW_SAFETY_ITERATION_MAX = 1000;

-- buffer class 
local graphics_buffer = { }; 
graphics_buffer.__index = graphics_buffer; 

function graphics_buffer.new_buffer(resolution, pixel_size) 
	local buffer = { 
		resolution = resolution; 
		pixel_size = pixel_size; 
		buffer_height = floor(resolution[2] / pixel_size);
		buffer_width = floor(resolution[1] / pixel_size);
		pixels = { };
	};

	for x = 0, buffer.buffer_width do 
		buffer.pixels[x] = { }; 
		for y = 0, buffer.buffer_height do  
			buffer.pixels[x][y] = { 0, 0, 0 };
		end; 
	end; 

	setmetatable(buffer, graphics_buffer); 
	return buffer; 
end; 

function graphics_buffer:set_pixel(x, y, rgb)
	if (not self.pixels[x] or not self.pixels[x][y]) then return end; 
	self.pixels[x][y] = rgb; 
end; 

function graphics_buffer:flush_buffer(clear_rgb) 
	for x = 0, self.buffer_width do 
		for y = 0, self.buffer_height do  
			self.pixels[x][y] = clear_rgb;
		end; 
	end; 
end; 

--// Source: https://en.wikipedia.org/wiki/Line_drawing_algorithm
function graphics_buffer:draw_line(x1, y1, x2, y2, rgb) 
	local x1, x2, y1, y2 = floor(x1), floor(x2), floor(y1), floor(y2);
	local dx = abs(x2 - x1);
	local dy = -abs(y2 - y1);
	local sx = (x1 < x2) and 1 or -1;
	local sy = (y1 < y2) and 1 or -1;
	local err = dx + dy;
	local iterations = 0; 

	while true do 
		-- safety check for now
		iterations = iterations + 1; 
		if iterations >= LINE_DRAW_SAFETY_ITERATION_MAX then break end;

		self:set_pixel(x1, y1, rgb);
		if (x1 == x2 and y1 == y2) then break end;

		local e2 = 2 * err; 
		if (e2 >= dy) then 
			if (x1 == x2) then break end;
			err = err + dy;
			x1 = x1 + sx;
		end;

		if (e2 <= dx) then
			if (y1 == y2 and sy == 1) or (y1 == y2 and sy == -1) then break end;
			err = err + dx;
			y1 = y1 + sy;
		end;
	end;
end; 

--// Source: idk forgot
function graphics_buffer:draw_triangle(p1, p2, p3, rgb, filled)
	if (not p1 or not p2 or not p3) then return end;

	if (not filled) then 
		self:draw_line(p1[1], p1[2], p2[1], p2[2], rgb);
		self:draw_line(p2[1], p2[2], p3[1], p3[2], rgb);
		self:draw_line(p3[1], p3[2], p1[1], p1[2], rgb);
		return;
	end;

	local verticies = { p1, p2, p3 };
	table.sort(verticies, function(a, b) 
		return a[2] < b[2]; 
	end);

	local x1, y1 = verticies[1][1], verticies[1][2];
	local x2, y2 = verticies[2][1], verticies[2][2];
	local x3, y3 = verticies[3][1], verticies[3][2];

	local slope_left = (x2 - x1) / (y2 - y1);
	local slope_right = (x3 - x1) / (y3 - y1);

	local x_left, x_right = x1, x1;

	for scanline = y1, y2 do
		self:draw_line(x_left, scanline, x_right, scanline, rgb);
		x_left = x_left + slope_left;
		x_right = x_right + slope_right;
	end;

	local slope_left = (x3 - x2) / (y3 - y2);
	x_left = x2;

	for scanline = y2, y3 do
		self:draw_line(x_left, scanline, x_right, scanline, rgb);
		x_left = x_left + slope_left;
		x_right = x_right + slope_right;
	end;
end;

return graphics_buffer
