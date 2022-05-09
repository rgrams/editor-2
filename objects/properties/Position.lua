
local _basePath = (...):gsub("Position$", "")
local Vec2 = require(_basePath .. "Vec2")

local Position = Vec2:extend()

Position.name = "pos"

function Position._setValidValue(self, value)
	self.value = value
	self.obj:setPosition(value)
end

return Position
