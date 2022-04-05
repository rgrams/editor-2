
local Panel = gui.Column:extend()
Panel.className = "Panel"

local Ruu = require "ui.ruu.ruu"
local Button = require "ui.Button"
local InputField = require "ui.InputField"

function Panel.set(self)
	local w, h = love.graphics.getDimensions()
	Panel.super.set(self, 5, false, nil, 300, h, "E", "E", "none", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Node(100, 20)
	}
	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})

	self.flux = require("philtre.lib.flux").group()

	self.wgtMap = {}
end

function Panel.init(self)
	Panel.super.init(self)
	Input.enable(self)
end

function Panel.final(self)
	Input.disable(self)
end

function Panel.update(self, dt)
	self.flux:update(dt)
end

function Panel.input(self, action, value, change, ...)
	if action == "next" and Input.isPressed("shift") then
		action = "prev"
	end
	self.ruu:input(action, value, change, ...)
end

return Panel
