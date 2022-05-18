
local Property = require(GetRequireFolder(...) .. "Property")
local String = Property:extend()

String.name = "string"
String.typeName = "string"
String.WidgetClass = require("ui.widgets.properties.String")
String.DEFAULT_VALUE = ""

_G.propClassList:add(String, String.typeName)

function String.isValid(self, value)
	return true, tostring(value)
end

return String
