
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local ButtonTheme = EmptyTheme:extend()

require("ui.ruu.defaultTheme").Button = ButtonTheme

ButtonTheme.normalValue = 0.55
ButtonTheme.hoverValue = 0.7
ButtonTheme.pressValue = 1.0

function ButtonTheme.init(self, themeData)
	ButtonTheme.super.init(self, themeData)
	local val = self.wgtTheme.normalValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.hover(self)
	local val = self.wgtTheme.hoverValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.unhover(self)
	local val = self.wgtTheme.normalValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.press(self, mx, my, isKeyboard)
	local val = self.wgtTheme.pressValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.release(self, dontFire, mx, my, isKeyboard)
	local theme = self.wgtTheme
	local val = self.isHovered and theme.hoverValue or theme.normalValue
	ButtonTheme.setValue(self.object.color, val)
end

function ButtonTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	love.graphics.rectangle("fill", -obj.w/2, -obj.h/2, obj.w, obj.h)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		local w, h = obj.w+1, obj.h+1
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return ButtonTheme
