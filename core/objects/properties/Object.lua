
local Property = require(GetRequireFolder(...) .. "Property")
local Object = Property:extend()

Object.name = "object"
Object.typeName = "object"
Object.WidgetClass = require("core.ui.widgets.properties.Object")
Object.defaultValue = ""

_G.propClassList:add(Object, Object.typeName)

function Object.isValid(self, value)
	return true, tostring(value)
end

return Object
