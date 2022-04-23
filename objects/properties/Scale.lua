
local _basePath = (...):gsub("Scale$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Scale = Vec2Property:extend()

Scale.name = "scale"
Scale.displayName = "Scale"
Scale.DEFAULT_VALUE = { x = 1, y = 1 }

function Scale._setValidValue(self, value)
	self.value = value
	self.obj:setScale(value.x, value.y)
end

return Scale
