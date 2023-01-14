
local Button = require(GetRequireFolder(...) .. "Button")
local MenuButton = Button:extend()

MenuButton.font = { "core/assets/font/OpenSans-Regular.ttf", 13 }
MenuButton.fontObj = new.font(unpack(MenuButton.font)) -- For Dropdown to check widths.
MenuButton.normalValue = 0.2
MenuButton.hoverValue = 0.35
MenuButton.pressValue = 0.4
MenuButton.textX = 16

function MenuButton.draw(self)
	local w, h = self.w, self.h
	local hw, hh = w/2, h/2

	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -hw, -hh, w, h)

	if self.widget and self.widget.isFocused then
		love.graphics.setColor(1, 1, 1, 0.05)
		love.graphics.rectangle("line", -hw-0.5, -hh-0.5, w+1, h+1)
	end
end

return MenuButton
