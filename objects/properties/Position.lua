
local Vec2 = require(GetRequireFolder(...) .. "Vec2")
local Position = Vec2:extend()

Position.name = "pos"
Position.className = "position"

_G.propClassList:add(Position, Position.className)

function Position._setValidValue(self, x, y)
	Position.super._setValidValue(self, x, y)
	self.obj:setPosition(self.value)
end

return Position
