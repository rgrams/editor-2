
local _basePath = (...):gsub("Position$", "")
local Vec2 = require(_basePath .. "Vec2")

local Position = Vec2:extend()

Position.name = "pos"
Position.className = "position"

_G.propClassList:add(Position, Position.className)

function Position._setValidValue(self, value)
	self.value = value
	self.obj:setPosition(value)
end

return Position
