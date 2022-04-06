
local UI = gui.Row:extend()
UI.className = "UI"

local Ruu = require "ui.ruu.ruu"
local Viewport = require "ui.Viewport"
local PropertyPanel = require "ui.PropertyPanel"

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, 0, false, -1, w, h, "NW", "C", "fill")
	self.layer = "gui"

	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})

	self.children = {
		Viewport(self.ruu),
		PropertyPanel(self.ruu)
	}
end

function UI.init(self)
	UI.super.init(self)
	Input.enable(self)
end

function UI.final(self)
	Input.disable(self)
end

function UI.input(self, action, value, change, ...)
	if action == "next" and Input.isPressed("shift") then
		action = "prev"
	end
	self.ruu:input(action, value, change, ...)
end

return UI
