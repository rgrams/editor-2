
local ButtonTheme = require(GetRequireFolder(...) .. "ButtonTheme")
local CheckboxTheme = ButtonTheme:extend()

local boxWidth = 14
local boxHeight = 14
local checkW = 6

local bgColor = { 0.15, 0.15, 0.15, 1 }
local checkColor = { 0.8, 0.8, 0.8, 1 }

function CheckboxTheme.setChecked(self, isChecked)  end

function CheckboxTheme.draw(self, obj)
	local w, h = boxWidth, boxHeight
	love.graphics.setColor(bgColor)
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
	love.graphics.setColor(obj.color)
	love.graphics.rectangle("line", -w/2, -h/2, w, h)

	if self.isChecked then
		love.graphics.setColor(checkColor)
		love.graphics.rectangle("fill", -checkW/2, -checkW/2, checkW, checkW)
	end

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 1)
		w, h = obj.w - 2, obj.h - 2
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return CheckboxTheme
