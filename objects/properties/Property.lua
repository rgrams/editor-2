
local Class = require "philtre.modules.base-class"
local Property = Class:extend()

Property.type = "float"
Property.name = "property"
Property.displayName = "Property"
Property.isOnObject = false

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
	return 0
end

function Property.isValid(self, value)
	local validValue = tonumber(value)
	local errMsg = not validValue and "Property.setValue: Invalid value: "..tostring(value)..". Must be a number."
	return validValue, errMsg
end

function Property.setValue(self, ...)
	local validValue, errMsg = self:isValid(self, ...)
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

local _printStr = "(Prop[%s]: '%s', %s)"

function Property.__tostring(self)
	local value = self.isOnObject and self.obj[self.name] or self.value
	return _printStr:format(self.type, self.name, tostring(value))
end

return Property
