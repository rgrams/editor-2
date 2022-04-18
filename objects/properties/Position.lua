
local _basePath = (...):gsub("Position$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Position = Vec2Property:extend()

Position.name = "pos"
Position.displayName = "Position"
Position.isOnObject = true

function Position.setOnObject(self)
	self.obj:setPosition(self.value)
end

return Position
