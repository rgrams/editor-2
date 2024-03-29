
-- Base class for properties and also a 'float' type property.

local Class = require "core.philtre.core.base-class"
local Property = Class:extend()

local config = require "core.config"

Property.name = "float"
Property.typeName = "float" -- For add-property menu and import/export.
Property.WidgetClass = require("core.ui.widgets.properties.Float")
Property.defaultValue = 0

_G.propClassList:add(Property, Property.typeName)

function Property.set(self, obj, name, isClassBuiltin)
	self.obj = obj
	self.name = name or self.name
	self.value = self:getDefaultValue()
	self.isClassBuiltin = isClassBuiltin
	self.isNonRemovable = isClassBuiltin
end

function Property.getDefaultValue(self)
	return self.defaultValue
end

function Property.eq(a, b, tolerance)
	tolerance = tolerance or 0.000000001
	return math.abs(a - b) <= tolerance
end

function Property.isAtDefault(self, overrideDefault)
	local curVal = self:getValue()
	return curVal == (overrideDefault or self.defaultValue)
end

function Property.isValid(self, value)
	local validValue = tonumber(value)
	local isValid = validValue
	if isValid then
		validValue = math.round(validValue, config.roundAllPropsTo)
	end
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

function Property.copyValue(self, value)
	if value ~= nil then  return value
	else  return self.value  end
end

local _printStr = "(Prop[%s]: '%s', %s)"

function Property.__tostring(self)
	local value = self.value or self.defaultValue -- So we can print the Class which has no `value`.
	return _printStr:format(self.typeName, self.name, tostring(value))
end

return Property
