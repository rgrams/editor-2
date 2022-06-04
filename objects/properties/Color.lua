
local Vec4 = require(GetRequireFolder(...) .. "Vec4")
local Color = Vec4:extend()

Color.name = "color"
Color.typeName = "color"
Color.WidgetClass = require("ui.widgets.properties.Vec4")
Color.wgtFieldLabels = { "r", "g", "b", "a" }
Color.defaultValue = { 1, 1, 1, 1 }

_G.propClassList:add(Color, Color.typeName)

return Color
