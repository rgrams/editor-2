
local _basePath = (...):gsub("Vec2$", "")
local Property = require(_basePath .. "Property")

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

function Vec2.getDiff(self)
	local default = self.DEFAULT_VALUE
	local dx, dy = self.value.x - default.x, self.value.y - default.y
	if dx ~= 0 or dy ~= 0 then
		return { x = dx, y = dy }
	end
end

function Vec2.isValid(self, value)
	local x, y = tonumber(value.x), tonumber(value.y)
	if not (x or y) then
		return false, nil, "Property.setValue: Invalid vec2: '("..tostring(x)..", "..tostring(y)..")'. At least 'x' or 'y' must be a number."
	end
	if not x then  value.x = self.value.x  end
	if not y then  value.y = self.value.y  end
	return true, value
end

function Vec2._setValidValue(self, value)
	self.value.x, self.value.y = value.x, value.y
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
