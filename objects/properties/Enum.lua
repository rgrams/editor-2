
local Property = require(GetRequireFolder(...) .. "Property")
local Enum = Property:extend()

local list = require "lib.list"

Enum.name = "enum"
Enum.typeName = "enum"
Enum.WidgetClass = require("ui.widgets.properties.Enum")
Enum.validValues = { "one", "two", "three" }
Enum.defaultValue = Enum.validValues[1]

_G.propClassList:add(Enum, Enum.typeName)

function Enum.isValid(self, value)
	local isValid = list.contains(self.validValues, value)
	return isValid, value
end

function Enum.getIndex(self, value)
	for i,v in ipairs(self.validValues) do
		if v == value then
			return i
		end
	end
end

return Enum
