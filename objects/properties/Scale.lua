
local Vec2 = require(GetRequireFolder(...) .. "Vec2")
local Scale = Vec2:extend()

Scale.name = "scale"
Scale.className = "scale"
Scale.DEFAULT_VALUE = { x = 1, y = 1 }

_G.propClassList:add(Scale, Scale.className)

function Scale._setValidValue(self, x, y)
	Scale.super._setValidValue(self, x, y)
	self.obj:setScale(x, y)
end

return Scale
