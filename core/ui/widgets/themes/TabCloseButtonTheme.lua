
local TabTheme = require(GetRequireFolder(...) .. "TabTheme")
local TabCloseButtonTheme = TabTheme:extend()

-- TabCloseButtonTheme.normalCheckVal = 0.47 -- Same as Tab.
TabCloseButtonTheme.hoverCheckVal = 0.59
-- TabCloseButtonTheme.normalUncheckVal = 0.32 -- Same as Tab.
TabCloseButtonTheme.hoverUncheckVal = 0.45

TabCloseButtonTheme.textCheckNormalVal = 0.75
TabCloseButtonTheme.textUncheckNormalVal = 0.5

function TabCloseButtonTheme.init(self, themeData)
	self.object = themeData
	themeData.widget = self
	self.object.text:setPos(0, -2)
	self.theme.updateColors(self)
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
	self.theme.updateColors(self)
end

return TabCloseButtonTheme
