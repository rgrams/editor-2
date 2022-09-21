
local Vec2 = require(GetRequireFolder(...) .. "Vec2")
local VertexArray = Vec2:extend()

VertexArray.name = "vertices"
VertexArray.typeName = "vertexArray"
VertexArray.WidgetClass = require("core.ui.widgets.properties.Blank")
VertexArray.defaultValue = {}

_G.propClassList:add(VertexArray, VertexArray.typeName)

function VertexArray.isAtDefault(self, overrideDefault)
	local cur, default = self.value, overrideDefault or self.defaultValue
	if #cur ~= #default then
		return false
	else
		for i,defVal in ipairs(default) do
			if not self.eq(cur[i], defVal) then
				return false
			end
		end
	end
	return true
end

function VertexArray.isValid(self, value)
	if not type(value) == "table" and value[1] and value[2] then
		return false, nil, "VertexArray.setValue: Value is not a sequence."
	end
	return true, value
end

function VertexArray.setValue(self, value)
	local isValid, validValue, errMsg = self:isValid(value)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(validValue)
end

function VertexArray._setValidValue(self, newVal)
	local val = self.value
	local oldLen, newLen = #val, #newVal
	for i=1,math.max(oldLen, newLen) do
		-- Will clear extra values if the old array is longer than the new one.
		val[i] = newVal[i]
	end
end

function VertexArray.copyValue(self, value)
	local val = value or self.value
	local copy = {}
	for i=1,#val do  copy[i] = val[i]  end
	return copy
end

local _printStr = "(Prop[%s]: '%s', { %s })"

function VertexArray.__tostring(self)
	local valStr = table.concat(self.value, ", ")
	return _printStr:format(self.type, self.name, valStr)
end

return VertexArray
