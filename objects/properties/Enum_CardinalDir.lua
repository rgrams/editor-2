
local Enum = require(GetRequireFolder(...) .. "Enum")
local Cardinal = Enum:extend()

Cardinal.name = "dir"
Cardinal.typeName = "cardinalDir"
Cardinal.validValues = { "C", "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
Cardinal.defaultValue = "C"

_G.propClassList:add(Cardinal, Cardinal.typeName)

return Cardinal
