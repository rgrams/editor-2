
local Property = require(GetRequireFolder(...) .. "Property")
local Vec2 = Property:extend()

Vec2.widgetName = "vec2"
Vec2.className = "vec2"
Vec2.name = "vec2"
Vec2.DEFAULT_VALUE = { x = 0, y = 0 }

_G.propClassList:add(Vec2, Vec2.className)

function Vec2.getDefaultValue(self)
	local value = {}
	for k,v in pairs(self.DEFAULT_VALUE) do
		value[k] = v
	end
	return value
end

function Vec2.isAtDefault(self)
	return self.value.x == self.DEFAULT_VALUE.x and self.value.y == self.DEFAULT_VALUE.y
end

function Vec2.isValid(self, value)
	-- NOTE: Don't modify `value`, it's a table that could be used on other object/properties.
	local x, y = tonumber(value.x), tonumber(value.y)
	if not (x or y) then
		return false, nil, nil, "Property.setValue: Invalid vec2: '("..tostring(x)..", "..tostring(y)..")'. At least 'x' or 'y' must be a number."
	end
	return true, x or self.value.x, y or self.value.y
end

function Vec2.setValue(self, value)
	local isValid, validX, validY, errMsg = self:isValid(value)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(validX, validY)
end

function Vec2._setValidValue(self, x, y)
	self.value.x, self.value.y = x, y
end

function Vec2.copyValue(self)
	return { x = self.value.x, y = self.value.y }
end

local _printStr = "(Prop[%s]: '%s', (%.3f, %.3f))"

function Vec2.__tostring(self)
	local value = self.value or self.DEFAULT_VALUE -- So we can print the Class which has no `value`.
	return _printStr:format(self.type, self.name, value.x, value.y)
end

return Vec2
