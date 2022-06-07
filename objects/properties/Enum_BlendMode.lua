
local Enum = require(GetRequireFolder(...) .. "Enum")
local BlendMode = Enum:extend()

BlendMode.name = "align"
BlendMode.typeName = "BlendMode"
BlendMode.validValues = { "alpha", "add", "subtract", "replace", "screen" }
BlendMode.defaultValue = "alpha"

_G.propClassList:add(BlendMode, BlendMode.typeName)

return BlendMode
