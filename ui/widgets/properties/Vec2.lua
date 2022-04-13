
local Vec2 = gui.Row:extend()
Vec2.className = "Vec2"

local InputField = require "ui.widgets.InputField"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local sublabelFont = { "assets/font/OpenSans-Regular.ttf", 12 }
local spacing = 1
local width = 100
local height = 26

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) + 4
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = { 0.6, 0.6, 0.6, 1 }
	return label
end

function Vec2.set(self, name, x, y)
	Vec2.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.children = {
		gui.Text(name, font, width, "W", "W", "left"):setPos(2),
		Sublabel("x"),
		InputField(x or 0, 50),
		Sublabel("y"),
		InputField(y or 0, 50),
	}
	local text = self.children[1]
	text.isGreedy = true
	text.color = { 0.65, 0.65, 0.65, 1 }
end

return Vec2
