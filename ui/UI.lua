
local UI = gui.Node:extend()
UI.className = "UI"

local Panel = require "ui.Panel"

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, w, h, "NW", "C", "fill")
	self.layer = "gui"

	self.children = {
		Panel()
	}
end

return UI
