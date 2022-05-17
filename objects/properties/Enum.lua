
local _basePath = (...):gsub("Enum$", "")
local Property = require(_basePath .. "Property")

local list = require "lib.list"
local Enum = Property:extend()

Enum.name = "enum"
Enum.widgetName = "enum"
Enum.className = "enum"
Enum.validValues = { "one", "two", "three" }
Enum.DEFAULT_VALUE = Enum.validValues[1]

_G.propClassList:add(Enum, Enum.className)

function Enum.isValid(self, value)
	local isValid = list.contains(self.validValues, value)
	return isValid, value
end

return Enum
