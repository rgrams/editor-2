
local _basePath = (...):gsub("Angle$", "")
local Property = require(_basePath .. "Property")

local Angle = Property:extend()

Angle.name = "angle"
Angle.displayName = "Angle"

function Angle.set(self, obj)
	self.obj = obj
	self.value = obj.angle
end

function Angle._setValidValue(self, angle)
	self.value = angle
	self.obj:setAngle(angle)
end

function Angle.getValue(self)
	return self.obj.angle
end

return Angle
