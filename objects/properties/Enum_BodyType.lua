
local Enum = require(GetRequireFolder(...) .. "Enum")
local BodyType = Enum:extend()

BodyType.name = "bodyType"
BodyType.typeName = "bodyType"
BodyType.validValues = { "dynamic", "static", "kinematic", "trigger" }
BodyType.DEFAULT_VALUE = "dynamic"

_G.propClassList:add(BodyType, BodyType.typeName)

return BodyType
