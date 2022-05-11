
local _basePath = (...):gsub("Angle$", "")
local Property = require(_basePath .. "Property")

local Angle = Property:extend()

Angle.name = "angle"
Angle.className = "angle"

_G.propClassList:add(Angle, Angle.className)

function Angle._setValidValue(self, angle)
	angle = math.rad(angle)
	self.value = angle
	self.obj:setAngle(angle)
end

function Angle.getValue(self)
	return math.deg(self.obj.angle)
end

Angle.copyValue = Angle.getValue

return Angle
