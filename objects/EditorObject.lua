
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"

local config = require "config"

EditorObject.hitRadius = 16

local Position = require "objects.properties.Position"
local Angle = require "objects.properties.Angle"
local Scale = require "objects.properties.Scale"
local Skew = require "objects.properties.Skew"

function EditorObject.set(self, x, y, angle, ...)
	EditorObject.super.set(self, x, y, angle, ...)
	self.isSelected = false
	self.properties = {
		Position(self),
		Angle(self),
		Scale(self),
		Skew(self),
	}
end

function EditorObject.setProperty(self, name, ...)
	local props = self.properties
	for i,prop in ipairs(props) do
		if prop.name == name then
			prop:setValue(...)
			return true
		end
	end
	return false
end

function EditorObject.getProperty(self, name)
	for i,prop in ipairs(self.properties) do
		if prop.name == name then
			return prop:getValue()
		end
	end
end

function EditorObject.touchesPoint(self, wx, wy)
	local lx, ly = self:toLocal(wx, wy)
	local r = self.hitRadius
	return lx >= -r and lx <= r and ly >= -r and ly <= r
end

function EditorObject.draw(self)
	love.graphics.setBlendMode("alpha")
	local r = self.hitRadius
	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.rectangle("line", -r, -r, r*2, r*2)
	love.graphics.circle("line", 0, 0, 0.5, 4)
end

return EditorObject
