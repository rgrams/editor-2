
local Button = require(GetRequireFolder(...) .. "Button")
local TabCloseBtn = Button:extend()
TabCloseBtn.className = "TabXBtn"

local style = require "core.ui.style"

TabCloseBtn.normalCheckColor = style.tabNormalCheckColor
TabCloseBtn.hoverCheckColor = style.tabCloseHoverCheckColor
TabCloseBtn.normalUncheckColor = style.tabNormalUncheckColor
TabCloseBtn.hoverUncheckColor = style.tabCloseHoverUncheckColor
TabCloseBtn.pressColor = style.tabPressColor

TabCloseBtn.textCheckNormalColor = style.tabCloseTextNormalCheckColor
TabCloseBtn.textCheckHoverColor = style.tabTextHoverCheckColor
TabCloseBtn.textUncheckNormalColor = style.tabCloseTextNormalUncheckColor
TabCloseBtn.textUncheckHoverColor = style.tabTextHoverUncheckColor

function TabCloseBtn.set(self, ...)
	TabCloseBtn.super.set(self, ...)
end

function TabCloseBtn.initRuu(self, ...)
	local widget = TabCloseBtn.super.initRuu(self, ...)
	self:updateColors() -- Method added from Tab to avoid require loop.
	return widget
end

function TabCloseBtn.draw(self)
	love.graphics.setColor(self.color)
	local r = self.h/2
	love.graphics.circle("fill", 0, 0, r, 16)

	if self.widget and self.widget.isFocused then
		love.graphics.setColor(style.focusLineColor)
		love.graphics.circle("line", 0, 0, r+0.5, 16)
	end
end

function TabCloseBtn.hover(self, wgt)
	self:updateColors()
end

function TabCloseBtn.unhover(self, wgt)
	self:updateColors()
end

function TabCloseBtn.release(self, dontFire, mx, my, isKeyboard)
	self:updateColors()
end

return TabCloseBtn
