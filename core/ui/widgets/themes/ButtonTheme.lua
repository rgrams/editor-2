
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local ButtonTheme = EmptyTheme:extend()

require("core.ui.ruu.defaultTheme").Button = ButtonTheme

ButtonTheme.normalValue = 0.32
ButtonTheme.hoverValue = 0.34
ButtonTheme.pressValue = 0.5

ButtonTheme.textNormalValue = 0.8
ButtonTheme.textHoverValue = 1.0

ButtonTheme.bevelLighten = 0.15
ButtonTheme.bevelHoverLighten = 0.25
ButtonTheme.bevelDarken = 0.15
ButtonTheme.bevelDepth = 2

function ButtonTheme.init(self, themeData)
	ButtonTheme.super.init(self, themeData)
	local val = self.wgtTheme.normalValue
	ButtonTheme.setValue(self.object.color, val)
	if self.object.text then
		ButtonTheme.setValue(self.object.text.color, self.wgtTheme.textNormalValue)
	end
end

function ButtonTheme.hover(self)
	local val = self.wgtTheme.hoverValue
	ButtonTheme.setValue(self.object.color, val)
	if self.object.text then
		local textVal = self.wgtTheme.textHoverValue
		ButtonTheme.setValue(self.object.text.color, textVal)
	end
end

function ButtonTheme.unhover(self)
	local val = self.wgtTheme.normalValue
	ButtonTheme.setValue(self.object.color, val)
	if self.object.text then
		local textVal = self.wgtTheme.textNormalValue
		ButtonTheme.setValue(self.object.text.color, textVal)
	end
end

function ButtonTheme.press(self, mx, my, isKeyboard)
	local val = self.wgtTheme.pressValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.release(self, dontFire, mx, my, isKeyboard)
	local Theme = self.wgtTheme
	local val = self.isHovered and Theme.hoverValue or Theme.normalValue
	ButtonTheme.setValue(self.object.color, val)
	if self.object.text then
		local textVal = self.isHovered and Theme.textHoverValue or Theme.textNormalValue
		ButtonTheme.setValue(self.object.text.color, textVal)
	end
end

function ButtonTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local val, alpha = obj.color[1], obj.color[4]
	local Theme = self.wgtTheme
	local v1 = val + (self.isHovered and Theme.bevelHoverLighten or Theme.bevelLighten)
	local v2 = val - Theme.bevelDarken
	local depth = Theme.bevelDepth
	if self.isPressed then  v1, v2 = v2, v1  end
	love.graphics.setColor(v1, v1, v1, alpha)
	love.graphics.rectangle("fill", -w/2, -h/2, w, depth)
	love.graphics.setColor(v2, v2, v2, alpha)
	love.graphics.rectangle("fill", -w/2, h/2 - depth, w, depth)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		local w, h = w+1, h+1
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return ButtonTheme
