
local Enum = require(GetRequireFolder(...) .. "Enum")
local TextAlign = Enum:extend()

TextAlign.name = "align"
TextAlign.typeName = "TextAlign"
TextAlign.validValues = { "left", "right", "center", "justify" }
TextAlign.DEFAULT_VALUE = "left"

_G.propClassList:add(TextAlign, TextAlign.typeName)

return TextAlign
