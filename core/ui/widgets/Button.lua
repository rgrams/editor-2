
local Button = gui.Node:extend()
Button.className = "Button"

local setValue = require "core.lib.setValue"
Button.theme = require "core.ui.object-as-theme"

Button.normalValue = 0.32
Button.hoverValue = 0.34
Button.pressValue = 0.5

Button.textNormalValue = 0.8
Button.textHoverValue = 1.0

Button.bevelLighten = 0.15
Button.bevelHoverLighten = 0.25
Button.bevelDarken = 0.15
Button.bevelDepth = 2

Button.font = { "core/assets/font/OpenSans-Semibold.ttf", 15 }
Button.width = 100
Button.height = 24
Button.textX, Button.textY = 0, -2

function Button.set(self, text, width, textAlign)
	width = width or self.width
	textAlign = textAlign or "left"
	Button.super.set(self, width, self.height)
	self.text = gui.Text(text or "text", self.font, width-6, "C", "C", textAlign)
	self.text:setPos(self.textX, self.textY)
	self.children = { self.text }
	self.color = { 1, 1, 1, 1 }
	setValue(self.color, self.normalValue)
	setValue(self.text.color, self.textNormalValue)
	self.layer = "gui"
end

function Button.initRuu(self, ruu, fn, ...)
	self.ruu = ruu
	local widget = ruu:Button(self, fn, self.theme):args(...)
	widget.object = self
	self.widget = widget
	return widget
end

function Button.hover(self, widget)
	setValue(self.color, self.hoverValue)
	if self.text then  setValue(self.text.color, self.textHoverValue)  end
end

function Button.unhover(self, widget)
	setValue(self.color, self.normalValue)
	if self.text then  setValue(self.text.color, self.textNormalValue)  end
end

function Button.focus(self, widget)  end
function Button.unfocus(self, widget)  end

function Button.press(self, widget, mx, my, isKeyboard)
	setValue(self.color, self.pressValue)
end

function Button.release(self, widget, dontFire, mx, my, isKeyboard)
	local val = widget.isHovered and self.hoverValue or self.normalValue
	setValue(self.color, val)
	if self.text then
		local textVal = widget.isHovered and self.textHoverValue or self.textNormalValue
		setValue(self.text.color, textVal)
	end
end

function Button.draw(self)
	love.graphics.setColor(self.color)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local isHovered, isPressed, isFocused = false, false, false
	local widget = self.widget
	if widget then
		isHovered = widget.isHovered
		isFocused = widget.isFocused
		isPressed = widget.isPressed
	end

	local val, alpha = self.color[1], self.color[4]
	local valUp = val + (isHovered and self.bevelHoverLighten or self.bevelLighten)
	local valDown = val - self.bevelDarken
	local depth = self.bevelDepth
	if isPressed then  valUp, valDown = valDown, valUp  end
	love.graphics.setColor(valUp, valUp, valUp, alpha)
	love.graphics.rectangle("fill", -w/2, -h/2, w, depth)
	love.graphics.setColor(valDown, valDown, valDown, alpha)
	love.graphics.rectangle("fill", -w/2, h/2 - depth, w, depth)

	if isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		local fw, fh = w+1, h+1
		love.graphics.rectangle("line", -fw/2, -fh/2, fw, fh)
	end
end

return Button
