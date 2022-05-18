
local Enum = require(GetRequireFolder(...) .. "Enum")
local Cardinal = Enum:extend()

Cardinal.name = "dir"
Cardinal.typeName = "cardinalDir"
Cardinal.validValues = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "C" }
Cardinal.DEFAULT_VALUE = "C"

_G.propClassList:add(Cardinal, Cardinal.typeName)

return Cardinal
