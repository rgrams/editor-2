
local Vec2 = require(GetRequireFolder(...) .. "Vec2")
local Vec4 = Vec2:extend()

local config = require "config"
local round = math.round

Vec4.name = "vec4"
Vec4.typeName = "vec4"
Vec4.WidgetClass = require("ui.widgets.properties.Vec4")
Vec4.wgtFieldLabels = { "x", "y", "z", "w" }
Vec4.defaultValue = { 1, 1, 1, 1 }

_G.propClassList:add(Vec4, Vec4.typeName)

function Vec4.isAtDefault(self, overrideDefault)
	local cur, def = self.value, overrideDefault or self.defaultValue
	return cur[1] == def[1] and cur[2] == def[2] and cur[3] == def[3] and cur[4] == def[4]
end

function Vec4.isValid(self, value)
	local x, y, z, w = tonumber(value[1]), tonumber(value[2]), tonumber(value[3]), tonumber(value[4])
	if not (x or y or z or w) then
		return false, nil, nil, nil, nil, "Property.setValue: Invalid vec4 parameter, must have at least one x, y, z, or w key with a number value."
	end
	local cur = self.value
	local incr = config.roundAllPropsTo
	if x then  x = round(x, incr)  end
	if y then  y = round(y, incr)  end
	if z then  z = round(z, incr)  end
	if w then  w = round(w, incr)  end
	x, y, z, w = x or cur[1], y or cur[2], z or cur[3], w or cur[4]
	return true, x, y, z, w
end

function Vec4.setValue(self, value)
	local isValid, x, y, z, w, errMsg = self:isValid(value)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(x, y, z, w)
end

function Vec4._setValidValue(self, x, y, z, w)
	local val = self.value
	val[1], val[2], val[3], val[4] = x, y, z, w
end

function Vec4.copyValue(self)
	local val = self.value
	return { val[1], val[2], val[3], val[4] }
end

local _printStr = "(Prop[%s]: '%s', (%.2f, %.2f, %.2f, %.2f))"

function Vec4.__tostring(self)
	local val = self.value
	return _printStr:format(self.typeName, self.name, val[1], val[2], val[3], val[4])
end

return Vec4
