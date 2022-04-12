
local _basePath = (...):gsub("Scale$", "")
local Vec2Property = require(_basePath .. "Vec2Property")

local Scale = Vec2Property:extend()

Scale.name = "scale"
Scale.displayName = "Scale"
Scale.isOnObject = true
Scale.DEFAULT_VALUE = { x = 1, y = 1 }

function Scale.getFromObject(self)
	local sx, sy = self.obj.sx, self.obj.sy
	return { x = sx, y = sy }
end

function Scale.setOnObject(self)
	self.obj.sx, self.obj.sy = self.value.x, self.value.y
end

return Scale
