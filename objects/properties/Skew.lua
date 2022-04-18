
local _basePath = (...):gsub("Skew$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Skew = Vec2Property:extend()

Skew.name = "skew"
Skew.displayName = "Skew"
Skew.isOnObject = true

function Skew.getFromObject(self)
	local kx, ky = self.obj.kx, self.obj.ky
	return { x = kx, y = ky }
end

function Skew.setOnObject(self)
	self.obj:setSkew(self.value.x, self.value.y)
end

return Skew
