
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"

local config = require "config"

EditorObject.hitRadius = 16

function EditorObject.set(self, x, y, angle, ...)
	EditorObject.super.set(self, x, y, angle, ...)
	self.isSelected = false
	self.properties = {}
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
