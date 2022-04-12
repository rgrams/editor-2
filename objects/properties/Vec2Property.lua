
local _basePath = (...):gsub("Vec2Property$", "")
local Property = require(_basePath .. "Property")

local Vec2Property = Property:extend()

Vec2Property.type = "vec2"
Vec2Property.name = "vec2"
Vec2Property.displayName = "Vec2Property"

function Vec2Property.getDefaultValue(self)
	return { x = 0, y = 0 }
end

function Vec2Property.isValid(self, x, y)
	x, y = tonumber(x), tonumber(y)
	if not (x or y) then
		return false, "Property.setValue: Invalid vec2: '("..tostring(x)..", "..tostring(y)..")'. At least 'x' or 'y' must be a number."
	end
	local value = self.isOnObject and self.obj[self.name] or self.value
	if x then  value.x = x  end
	if y then  value.y = y  end
	return value
end

function Vec2Property.getValue(self)
	local value = self.isOnObject and self.obj[self.name] or self.value
	return value.x, value.y
end

local _printStr = "(Prop[%s]: '%s', (%.3f, %.3f))"

function Vec2Property.__tostring(self)
	local value = self.isOnObject and self.obj[self.name] or self.value
	return _printStr:format(self.type, self.name, value.x, value.y)
end

return Vec2Property
