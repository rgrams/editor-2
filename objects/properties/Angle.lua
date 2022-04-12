
local _basePath = (...):gsub("Angle$", "")
local Property = require(_basePath .. "Property")

local Angle = Property:extend()

Angle.name = "angle"
Angle.displayName = "Angle"
Angle.isOnObject = true

return Angle
