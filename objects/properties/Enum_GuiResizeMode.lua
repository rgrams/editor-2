
local Enum = require(GetRequireFolder(...) .. "Enum")
local ResizeMode = Enum:extend()

ResizeMode.name = "mode"
ResizeMode.typeName = "GUIResizeMode"
ResizeMode.validValues = { "none", "fit", "cover", "stretch", "fill" }
ResizeMode.DEFAULT_VALUE = "none"

_G.propClassList:add(ResizeMode, ResizeMode.typeName)

return ResizeMode
