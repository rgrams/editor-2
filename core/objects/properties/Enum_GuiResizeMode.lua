
local Enum = require(GetRequireFolder(...) .. "Enum")
local ResizeMode = Enum:extend()

ResizeMode.name = "mode"
ResizeMode.typeName = "GUIResizeMode"
ResizeMode.validValues = { "none", "fit", "cover", "stretch", "fill" }
ResizeMode.defaultValue = "none"

_G.propClassList:add(ResizeMode, ResizeMode.typeName)

return ResizeMode
