
local _basePath = (...):gsub("Skew$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Skew = Vec2Property:extend()

Skew.name = "skew"

function Skew._setValidValue(self, value)
	self.value = value
	self.obj:setSkew(value.x, value.y)
end

return Skew
