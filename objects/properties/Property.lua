
local Class = require "philtre.modules.base-class"
local Property = Class:extend()

Property.widgetName = "float"
Property.className = "float" -- For add-property menu and import/export.
Property.name = "property"
Property.DEFAULT_VALUE = 0

_G.propClassList:add(Property, Property.className)

function Property.set(self, obj, name)
	self.obj = obj
	self.name = name or self.name
	self.value = self:getDefaultValue()
end

function Property.getDefaultValue(self)
	return self.DEFAULT_VALUE
end

function Property.isAtDefault(self)
	local curVal = self:getValue()
	return curVal == self.DEFAULT_VALUE
end

function Property.isValid(self, value)
	local validValue = tonumber(value)
	local isValid = validValue
	local errMsg = not validValue and "Property.setValue: Invalid value: "..tostring(value)..". Must be a number."
	return isValid, validValue, errMsg
end

function Property.setValue(self, value)
	local isValid, validValue, errMsg = self:isValid(value)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(validValue)
end

function Property._setValidValue(self, value)
	self.value = value
end

function Property.getValue(self)
	return self.value
end

Property.copyValue = Property.getValue -- These will be separate for vector/table properties

local _printStr = "(Prop[%s]: '%s', %s)"

function Property.__tostring(self)
	local value = self.value or self.DEFAULT_VALUE -- So we can print the Class which has no `value`.
	return _printStr:format(self.type, self.name, tostring(value))
end

return Property
