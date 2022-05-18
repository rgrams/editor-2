
local Property = require(GetRequireFolder(...) .. "Property")
local Bool = Property:extend()

Bool.name = "bool"
Bool.typeName = "bool"
Bool.WidgetClass = require("ui.widgets.properties.Bool")
Bool.DEFAULT_VALUE = "false"

_G.propClassList:add(Bool, Bool.typeName)

function Bool.isValid(self, value)
	local isValid = value == true or value == false
	return isValid, value
end

return Bool
