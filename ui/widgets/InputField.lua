
local InputField = gui.Node:extend()
InputField.className = "InputField"

InputField.font = { "assets/font/OpenSans-Regular.ttf", 14 }
InputField.width = 100
InputField.height = 24
local pad = 2
local cursorW = 2

local selectionColor = { 0.16, 0.44, 0.78, 1 }
local cursorColor = { 1, 1, 1, 1 }

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
	self.text.maskObject = nil
	self.cursor.maskObject = nil
	self.selection.maskObject = nil
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)

	if self.widget and self.widget.isFocused then
		local w, h = self.w+4, self.h+4
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return InputField
