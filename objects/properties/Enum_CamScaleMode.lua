
local Enum = require(GetRequireFolder(...) .. "Enum")
local CamScaleMode = Enum:extend()

CamScaleMode.name = "scaleMode"
CamScaleMode.typeName = "CamScaleMode"
CamScaleMode.validValues = { "expand view", "fixed area", "fixed width", "fixed height" }
CamScaleMode.defaultValue = "fixed area"

_G.propClassList:add(CamScaleMode, CamScaleMode.typeName)

return CamScaleMode
