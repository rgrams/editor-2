
local Float = gui.Row:extend()
Float.className = "Float"

local InputField = require "ui.widgets.InputField"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local spacing = 2
local width = 100
local height = 26

function Float.set(self, name, value)
	Float.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.children = {
		gui.Text(name, font, width, "W", "W", "left"):setPos(2),
		InputField(0),
	}
	local text = self.children[1]
	text.isGreedy = true
	text.color = { 0.65, 0.65, 0.65, 1 }
end

return Float
