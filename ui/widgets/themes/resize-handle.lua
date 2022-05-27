
local defaultTheme = require("ui.ruu.defaultTheme").Panel
local theme = defaultTheme:extend()

theme.normalColor = { 0.17, 0.17, 0.17, 1 }
theme.hoverColor = { 0.25, 0.25, 0.25, 1 }
theme.pressColor = { 0.5, 0.5, 0.5, 1 }


local xCursor = love.mouse.getSystemCursor("sizewe")
local yCursor = love.mouse.getSystemCursor("sizens")

function theme.init(self, themeData)
	theme.super.init(self, themeData)
end

function theme.hover(self)
	self.object.color = theme.hoverColor
	love.mouse.setCursor(self.object.isXAxis and xCursor or yCursor)
end

function theme.unhover(self)
	self.object.color = theme.normalColor
	love.mouse.setCursor()
end

function theme.focus(self)
end

function theme.unfocus(self)
end

function theme.press(self)
	self.object.color = theme.pressColor
end

function theme.release(self, dontFire, mx, my, isKeyboard)
	self.object.color = self.isHovered and theme.hoverColor or theme.normalColor
end

return theme
