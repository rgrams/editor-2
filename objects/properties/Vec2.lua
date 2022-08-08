
local Property = require(GetRequireFolder(...) .. "Property")
local Vec2 = Property:extend()

local config = require "config"

Vec2.name = "vec2"
Vec2.typeName = "vec2"
Vec2.WidgetClass = require("ui.widgets.properties.Vec2")
Vec2.defaultValue = { x = 0, y = 0 }

_G.propClassList:add(Vec2, Vec2.typeName)

function Vec2.getDefaultValue(self)
	local value = {}
	for k,v in pairs(self.defaultValue) do
		value[k] = v
	end
	return value
end

function Vec2.isAtDefault(self, overrideDefault)
	local cur, def = self.value, overrideDefault or self.defaultValue
	return self.eq(cur.x, def.x) and self.eq(cur.y, def.y)
end

function Vec2.isValid(self, value)
	-- NOTE: Don't modify `value`, it's a table that could be used on other object/properties.
	local x, y = tonumber(value.x), tonumber(value.y)
	if not (x or y) then
		return false, nil, nil, "Property.setValue: Invalid vec2: '("..tostring(x)..", "..tostring(y)..")'. At least 'x' or 'y' must be a number."
	end
	local incr = config.roundAllPropsTo
	if x then  x = math.round(x, incr)  end
	if y then  y = math.round(y, incr)  end
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

function Vec2.copyValue(self, value)
	value = value or self.value
	return { x = value.x, y = value.y }
end

local _printStr = "(Prop[%s]: '%s', (%.3f, %.3f))"

function Vec2.__tostring(self)
	local value = self.value or self.defaultValue -- So we can print the Class which has no `value`.
	return _printStr:format(self.type, self.name, value.x, value.y)
end

return Vec2
