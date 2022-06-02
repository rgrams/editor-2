
local Vec2 = require(GetRequireFolder(...) .. "Vec2")
local Color = Vec2:extend()

Color.name = "color"
Color.typeName = "color"
Color.WidgetClass = require("ui.widgets.properties.Color")
Color.defaultValue = { 1, 1, 1, 1 }

_G.propClassList:add(Color, Color.typeName)

function Color.isAtDefault(self)
	local cur, def = self.value, self.defaultValue
	return cur[1] == def[1] and cur[2] == def[2] and cur[3] == def[3] and cur[4] == def[4]
end

function Color.isValid(self, value)
	local r, g, b, a = tonumber(value[1]), tonumber(value[2]), tonumber(value[3]), tonumber(value[4])
	if not (r or g or b or a) then
		return false, nil, nil, nil, nil, "Property.setValue: Invalid color parameter, must have at least one r, g, b, or a key with a number value."
	end
	local cur = self.value
	r, g, b, a = r or cur[1], g or cur[2], b or cur[3], a or cur[4]
	return true, r, g, b, a
end

function Color.setValue(self, value)
	local isValid, r, g, b, a, errMsg = self:isValid(value)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(r, g, b, a)
end

function Color._setValidValue(self, r, g, b, a)
	local val = self.value
	val[1], val[2], val[3], val[4] = r, g, b, a
end

function Color.copyValue(self)
	local val = self.value
	return { val[1], val[2], val[2], val[4] }
end

local _printStr = "(Prop[%s]: '%s', (%.2f, %.2f, %.2f, %.2f))"

function Color.__tostring(self)
	local val = self.value
	return _printStr:format(self.typeName, self.name, val[1], val[2], val[3], val[4])
end

return Color
