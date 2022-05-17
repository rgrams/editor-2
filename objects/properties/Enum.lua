
local Property = require(GetRequireFolder(...) .. "Property")
local Enum = Property:extend()

local list = require "lib.list"

Enum.name = "enum"
Enum.className = "enum"
Enum.WidgetClass = require("ui.widgets.properties.Enum")
Enum.validValues = { "one", "two", "three" }
Enum.DEFAULT_VALUE = Enum.validValues[1]

_G.propClassList:add(Enum, Enum.className)

function Enum.isValid(self, value)
	local isValid = list.contains(self.validValues, value)
	return isValid, value
end

return Enum
