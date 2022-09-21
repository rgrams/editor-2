
local Window = gui.Node:extend()
Window.className = "Window"

local UI = require "core.ui.UI"

function Window.set(self)
	local w, h = love.graphics.getDimensions()
	Window.super.set(self, w, h, "NW", "C", "fill")
	self.layer = "gui"
	self.children = { UI() }
end

return Window
