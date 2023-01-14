
local InputField = gui.Node:extend()
InputField.className = "InputField"

local DefaultTheme = require("core.ui.ruu.defaultThemes").InputField
InputField.theme = DefaultTheme:extend()

local style = require "core.ui.style"

InputField.font = style.inputFieldFont
InputField.width = 100
InputField.height = 24
local pad = 2
local cursorW = 2

InputField.normalColor = style.inputFieldColor
InputField.hoverColor = style.inputFieldHoverColor
InputField.pressColor = style.inputFieldPressColor

InputField.bevelLighten = style.inputFieldBevelLighten
InputField.bevelHoverLighten = style.inputFieldBevelHoverLighten
InputField.bevelDarken = style.inputFieldBevelDarken

-- Modify Ruu InputField widget class directly to add select-all to all fields.
local RuuInputField = require "core.ui.ruu.widgets.InputField"
function RuuInputField.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat)
	if action == "select all" and change == 1 then
		wgt:selectAll()
	end
end

-- Simple draw method for selection and cursor nodes.
local function drawRect(self)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
end

function InputField.set(self, text, width)
	width = width or self.width
	InputField.super.set(self, width, self.height)

	self.text = gui.Text(text, self.font, width - pad*2, "W", "W", "left", "stretch"):setPos(0, -1)
	self.text.layer = "gui text"
	self.cursor = gui.Node(cursorW, self.height - pad*2)
	self.selection = gui.Node(width, self.height, "W", "W")
	self.mask = gui.Mask(nil, width, self.height, "W", "W", "fill"):setPad(pad, pad)

	self.children = {
		mod(self.mask, { children = {
			self.selection,
			self.text,
			self.cursor
		} })
	}

	self.selection.draw = drawRect
	self.cursor.draw = drawRect
	self.selection.color = style.textSelectColor
	self.cursor.color = style.textCursorColor

	self.text.color = style.inputFieldTextColor
	self.color = self.normalColor
	self.layer = "gui"
end

function InputField.initRuu(self, ruu, fn, ...)
	self.ruu = ruu
	local widget = ruu:InputField(self, fn, self.text.text, self.theme):args(...)
	return widget
end

function InputField.theme.init(wgt, self)
	wgt.object = self
	self.widget = wgt
	wgt.textObj = self.text
	wgt.cursorObj = self.cursor
	wgt.selectionObj = self.selection

	if self.tree then
		self.cursor:setVisible(wgt.isFocused)
		self.selection:setVisible(wgt.isFocused)
	else
		self.cursor.visible = wgt.isFocused
		self.selection.visible = wgt.isFocused
	end

	wgt.font = self.text.font
	wgt.scrollOX = 0
	wgt.textOriginX = self.text.pos.x

	wgt.theme.updateMaskSize(wgt)
	wgt.theme.updateText(wgt)
	self.color = self.normalColor
end

function InputField.theme.hover(wgt)
	local self = wgt.object
	self.color = wgt.isPressed and self.pressColor or self.hoverColor
end

function InputField.theme.unhover(wgt)
	local self = wgt.object
	self.color = self.normalColor
end

function InputField.theme.press(wgt)
	local self = wgt.object
	self.color = self.pressColor
end

function InputField.theme.release(wgt)
	local self = wgt.object
	local col = wgt.isHovered and self.hoverColor or self.normalColor
	self.color = col
end

function InputField.draw(self)
	love.graphics.setColor(self.color)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local val, alpha = self.color[1], self.color[4]
	local v1 = val - self.bevelDarken
	local v2 = val + (self.isHovered and self.bevelHoverLighten or self.bevelLighten)
	love.graphics.setColor(v1, v1, v1, alpha)
	love.graphics.rectangle("fill", -w/2, -h/2, w, 2)
	love.graphics.setColor(v2, v2, v2, alpha)
	love.graphics.rectangle("fill", -w/2, h/2 - 2, w, 2)

	if self.widget and self.widget.isFocused then
		love.graphics.setColor(style.focusLineColor)
		local fw, fh = w+1, h+1
		love.graphics.rectangle("line", -fw/2, -fh/2, fw, fh)
	end
end

return InputField
