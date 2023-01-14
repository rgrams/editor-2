
local Button = require(GetRequireFolder(...) .. "Button")
local TabCloseBtn = Button:extend()

TabCloseBtn.normalCheckVal = 0.47 -- Same as Tab.
TabCloseBtn.hoverCheckVal = 0.59
TabCloseBtn.normalUncheckVal = 0.32 -- Same as Tab.
TabCloseBtn.hoverUncheckVal = 0.45

TabCloseBtn.textCheckNormalVal = 0.75
TabCloseBtn.textUncheckNormalVal = 0.5

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
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("line", 0, 0, r+0.5, 16)
	end
end

function TabCloseBtn.hover(self, wgt)
	-- self:updateColors()
end

function TabCloseBtn.unhover(self, wgt)
	-- self:updateColors()
end

function TabCloseBtn.release(self, dontFire, mx, my, isKeyboard)
	self:updateColors()
end

return TabCloseBtn
