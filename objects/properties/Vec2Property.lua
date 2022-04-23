
local _basePath = (...):gsub("Vec2Property$", "")
local Property = require(_basePath .. "Property")

local Vec2Property = Property:extend()

Vec2Property.type = "vec2"
Vec2Property.name = "vec2"
Vec2Property.displayName = "Vec2Property"
Vec2Property.DEFAULT_VALUE = { x = 0, y = 0 }

function Vec2Property.getDefaultValue(self)
	local value = {}
	for k,v in pairs(self.DEFAULT_VALUE) do
		value[k] = v
	end
	return value
end

function Vec2Property.getDiff(self)
	local default = self.DEFAULT_VALUE
	local dx, dy = self.value.x - default.x, self.value.y - default.y
	if dx ~= 0 or dy ~= 0 then
		return { x = dx, y = dy }
	end
end

function Vec2Property.isValid(self, value)
	local x, y = tonumber(value.x), tonumber(value.y)
	if not (x or y) then
		return false, "Property.setValue: Invalid vec2: '("..tostring(x)..", "..tostring(y)..")'. At least 'x' or 'y' must be a number."
	end
	if not x then  value.x = self.value.x  end
	if not y then  value.y = self.value.y  end
	return value
end

function Vec2Property._setValidValue(self, value)
	self.value.x, self.value.y = value.x, value.y
end

function Vec2Property.copyValue(self)
	return { x = self.value.x, y = self.value.y }
end

local _printStr = "(Prop[%s]: '%s', (%.3f, %.3f))"

function Vec2Property.__tostring(self)
	local value = self.value or self.DEFAULT_VALUE -- So we can print the Class which has no `value`.
	return _printStr:format(self.type, self.name, value.x, value.y)
end

return Vec2Property
