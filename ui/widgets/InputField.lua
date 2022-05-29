
local InputField = gui.Node:extend()
InputField.className = "InputField"

InputField.font = { "assets/font/OpenSans-Regular.ttf", 14 }
InputField.width = 100
InputField.height = 24
local pad = 2
local cursorW = 2

local selectionColor = { 0.16, 0.44, 0.78, 1 }
local cursorColor = { 1, 1, 1, 1 }

-- Modify Ruu InputField widget class directly to add select-all to all fields.
local RuuInputField = require "ui.ruu.widgets.InputField"
function RuuInputField.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat)
	if action == "select all" and change == 1 then
		wgt:selectAll()
	end
end

local function selectionDraw(self)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
end
local cursorDraw = selectionDraw

function InputField.set(self, text, width)
	width = width or self.width
	InputField.super.set(self, width, self.height)

	self.text = gui.Text(text, self.font, width - pad*2, "W", "W", "left", "stretch"):setPos(0, -1)
	self.text.layer = "gui text"
	self.cursor = gui.Node(cursorW, self.height - pad*2)
	self.selection = gui.Node(width, self.height, "W", "W")
	self.mask = gui.Mask(nil, width, self.height, "W", "W", "fill"):pad(pad, pad)

	self.children = {
		mod(self.mask, { children = {
			self.selection,
			self.text,
			self.cursor
		} })
	}

	self.selection.draw = selectionDraw
	self.cursor.draw = cursorDraw
	self.selection.color = selectionColor
	self.cursor.color = cursorColor

	self.text.color = {1, 1, 1, 1}
	self.color = {0.3, 0.3, 0.3, 1}
	self.layer = "gui"
end

function InputField.draw(self)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)

	if self.widget and self.widget.isFocused then
		love.graphics.setColor(1, 1, 1)
		local w, h = self.w+1, self.h+1
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return InputField
