
local _basePath = (...):gsub("Skew$", "")
local Vec2 = require(_basePath .. "Vec2")

local Skew = Vec2:extend()

Skew.name = "skew"
Skew.className = "skew"

_G.propClassList:add(Skew, Skew.className)

function Skew._setValidValue(self, value)
	self.value = value
	self.obj:setSkew(value.x, value.y)
end

return Skew
