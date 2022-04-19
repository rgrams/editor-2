
local Class = require "philtre.modules.base-class"
local Property = Class:extend()

Property.type = "float"
Property.name = "property"
Property.displayName = "Property"
Property.isOnObject = false
Property.DEFAULT_VALUE = 0

function Property.set(self, obj, isOnObject)
	self.obj = obj
	self.isOnObject = isOnObject
	if self.isOnObject then
		self.value = self:getFromObject()
	else
		self.value = self:getDefaultValue()
	end
end

function Property.getFromObject(self)
	local val = self.obj[self.name]
	if not val then
		val = self:getDefaultValue()
		self.obj[self.name] = val
	end
	return val
end

function Property.setOnObject(self)
	self.obj[self.name] = self.value
end

function Property.getDefaultValue(self)
	return self.DEFAULT_VALUE
end

function Property.getDiff(self)
	local curVal = self:getValue()
	local diff = curVal - self.DEFAULT_VALUE
	if diff ~= 0 then
		return diff
	end
end

function Property.isValid(self, value)
	local validValue = tonumber(value)
	local errMsg = not validValue and "Property.setValue: Invalid value: "..tostring(value)..". Must be a number."
	return validValue, errMsg
end

function Property.setValue(self, ...)
	local validValue, errMsg = self:isValid(...)
	if not validValue then
		return errMsg
	end
	self.value = validValue
	if self.isOnObject then
		self:setOnObject()
	end
end

function Property.getValue(self)
	return self.isOnObject and self.obj[self.name] or self.value
end

Property.copyValue = Property.getValue -- These will be separate for vector/table properties
Property.setFromCopy = Property.setValue

local _printStr = "(Prop[%s]: '%s', %s)"

function Property.__tostring(self)
	local value = (self.isOnObject and self.obj) and self.obj[self.name] or self.value
	value = value or self.DEFAULT_VALUE
	return _printStr:format(self.type, self.name, tostring(value))
end

return Property
