
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
	local curX, curY = self:getValue()
	local default = self.DEFAULT_VALUE
	local dx, dy = curX - default.x, curY - default.y
	if dx ~= 0 or dy ~= 0 then
		return dx, dy
	end
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

function Vec2Property.copyValue(self)
	local x, y = self:getValue()
	return { x = x, y = y }
end

function Vec2Property.setFromCopy(self, value)
	self:setValue(value.x, value.y)
end

local _printStr = "(Prop[%s]: '%s', (%.3f, %.3f))"

function Vec2Property.__tostring(self)
	local value = (self.isOnObject and self.obj) and self.obj[self.name] or self.value
	value = value or self.DEFAULT_VALUE
	return _printStr:format(self.type, self.name, value.x, value.y)
end

return Vec2Property
