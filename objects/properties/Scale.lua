
local _basePath = (...):gsub("Scale$", "")
local Vec2 = require(_basePath .. "Vec2")

local Scale = Vec2:extend()

Scale.name = "scale"
Scale.DEFAULT_VALUE = { x = 1, y = 1 }

function Scale._setValidValue(self, value)
	self.value = value
	self.obj:setScale(value.x, value.y)
end

return Scale
