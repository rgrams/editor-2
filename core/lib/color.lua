
local M = {}

function M.lighten(color, value, out)
	out = out or {}
	out[1], out[2], out[3] = color[1]+value, color[2]+value, color[3]+value
	out[4] = color[4]
	return out
end

function M.darken(color, value, out)
	return M.lighten(color, -value, out)
end

function M.invert(color, out)
	out = out or {}
	out[1], out[2], out[3], out[4] = 1-color[1], 1-color[2], 1-color[3], color[4]
	return out
end

function M.alpha(color, a)
	color[4] = a
	return color
end

function M.getValue(color)
	return color[1]*0.2126 + color[2]*0.7152 + color[3]*0.0722
end

return M
