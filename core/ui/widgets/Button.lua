
local Button = gui.Node:extend()
Button.className = "Button"

local style = require "core.ui.style"
Button.theme = require "core.ui.object-as-theme"

Button.normalColor = style.buttonColor
Button.hoverColor = style.buttonHoverColor
Button.pressColor = style.buttonPressColor

Button.textNormalColor = style.buttonTextColor
Button.textHoverColor = style.buttonTextHoverColor

Button.bevelLighten = style.buttonBevelLighten
Button.bevelHoverLighten = style.buttonBevelHoverLighten
Button.bevelDarken = style.buttonBevelDarken
Button.bevelDepth = style.buttonBevelDepth

Button.font = style.buttonFont
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
	self.color = self.normalColor
	self.text.color = self.textNormalColor
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
	self.color = self.hoverColor
	if self.text then  self.text.color = self.textHoverColor  end
end

function Button.unhover(self, widget)
	self.color = self.normalColor
	if self.text then  self.text.color = self.textNormalColor  end
end

function Button.focus(self, widget)  end
function Button.unfocus(self, widget)  end

function Button.press(self, widget, mx, my, isKeyboard)
	self.color = self.pressColor
end

function Button.release(self, widget, dontFire, mx, my, isKeyboard)
	self.color = widget.isHovered and self.hoverColor or self.normalColor
	if self.text then
		self.text.color = widget.isHovered and self.textHoverColor or self.textNormalColor
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
		love.graphics.setColor(style.focusLineColor)
		local fw, fh = w+1, h+1
		love.graphics.rectangle("line", -fw/2, -fh/2, fw, fh)
	end
end

return Button
