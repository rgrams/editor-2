
local DefaultTheme = require("core.ui.ruu.defaultTheme").InputField
local InputFieldTheme = DefaultTheme:extend()

InputFieldTheme.normalValue = 0.18
InputFieldTheme.hoverValue = 0.15
InputFieldTheme.pressValue = 0.1

InputFieldTheme.bevelLighten = 0.15
InputFieldTheme.bevelHoverLighten = 0.20
InputFieldTheme.bevelDarken = 0.15

local function setValue(color, val)
	color[1], color[2], color[3] = val, val, val
end

function InputFieldTheme.init(self, themeData)
	InputFieldTheme.super.init(self, themeData)
	setValue(self.object.color, self.wgtTheme.normalValue)
end

function InputFieldTheme.hover(self)
	local val = self.isPressed and self.wgtTheme.pressValue or self.wgtTheme.hoverValue
	setValue(self.object.color, val)
end

function InputFieldTheme.unhover(self)
	setValue(self.object.color, self.wgtTheme.normalValue)
end

function InputFieldTheme.press(self)
	setValue(self.object.color, self.wgtTheme.pressValue)
end

function InputFieldTheme.release(self)
	local val = self.isHovered and self.wgtTheme.hoverValue or self.wgtTheme.normalValue
	setValue(self.object.color, val)
end

function InputFieldTheme.draw(self, obj)
	-- TODO: Inner bevel.
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local val, alpha = obj.color[1], obj.color[4]
	local Theme = self.wgtTheme
	local v1 = val - Theme.bevelDarken
	local v2 = val + (self.isHovered and Theme.bevelHoverLighten or Theme.bevelLighten)
	love.graphics.setColor(v1, v1, v1, alpha)
	love.graphics.rectangle("fill", -w/2, -h/2, w, 2)
	love.graphics.setColor(v2, v2, v2, alpha)
	love.graphics.rectangle("fill", -w/2, h/2 - 2, w, 2)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		local w, h = w+1, h+1
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return InputFieldTheme
