
local _basePath = (...):gsub("Position$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Position = Vec2Property:extend()

Position.name = "pos"
Position.displayName = "Position"

function Position._setValidValue(self, value)
	self.value = value
	self.obj:setPosition(value)
end

return Position
