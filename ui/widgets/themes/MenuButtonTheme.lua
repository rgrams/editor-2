
local ButtonTheme = require(GetRequireFolder(...) .. "ButtonTheme")
local MenuButtonTheme = ButtonTheme:extend()

local font = { "assets/font/OpenSans-Regular.ttf", 13 }
local textValue = 1.0

MenuButtonTheme.normalValue = 0.2
MenuButtonTheme.hoverValue = 0.35
MenuButtonTheme.pressValue = 0.4

function MenuButtonTheme.init(self, themeData)
	MenuButtonTheme.super.init(self, themeData)

	local textNode = self.object.text
	MenuButtonTheme.setValue(textNode.color, textValue)
	textNode.font = new.font(unpack(font))
	textNode.fontFilename, textNode.fontSize = font[1], font[2]
	textNode:setPos(16)
end

function MenuButtonTheme.draw(self, obj)
	local hw, hh = obj.w/2, obj.h/2

	love.graphics.setColor(obj.color)
	love.graphics.rectangle("fill", -hw, -hh, obj.w, obj.h)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 0.05)
		love.graphics.rectangle("line", -obj.w/2, -obj.h/2, obj.w, obj.h)
	end
end

return MenuButtonTheme