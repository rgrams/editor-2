
local TabTheme = require(GetRequireFolder(...) .. "TabTheme")
local TabCloseButtonTheme = TabTheme:extend()

function TabCloseButtonTheme.init(self, themeData)
	self.object = themeData
	self.object.text:setPos(0, -2)

	local Theme = self.wgtTheme
	local val = Theme.normalUncheckVal
	TabCloseButtonTheme.setValue(self.object.color, val)
end

function TabCloseButtonTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local r = obj.h/2
	love.graphics.circle("fill", 0, 0, r, 16)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("line", 0, 0, r+0.5, 16)
	end
end

function TabCloseButtonTheme.release(self, dontFire, mx, my, isKeyboard)
	local Theme = self.wgtTheme
	Theme.update(self)
end

function TabCloseButtonTheme.update(self)
	local Theme = self.wgtTheme
	local val
	if self.isPressed then
		val = Theme.pressValue
	else
		if self.isHovered then
			val = self.isChecked and Theme.hoverCheckVal or Theme.hoverUncheckVal
		else
			val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
		end
	end
	TabCloseButtonTheme.setValue(self.object.color, val)
end

return TabCloseButtonTheme
