
local Property = require(GetRequireFolder(...) .. "Property")
local String = Property:extend()

String.name = "string"
String.typeName = "string"
String.WidgetClass = require("core.ui.widgets.properties.String")
String.defaultValue = ""

_G.propClassList:add(String, String.typeName)

function String.isValid(self, value)
	return true, tostring(value)
end

return String
