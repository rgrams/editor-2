
local Checkbox = gui.Node:extend()
Checkbox.className = "Checkbox"

local totalW = 24
local totalH = 24
local width = 14
local height = 14

local checkW = 6

local bgColor = { 0.15, 0.15, 0.15, 1 }
local checkColor = { 0.8, 0.8, 0.8, 1 }

function Checkbox.set(self)
	Checkbox.super.set(self, totalW, totalH, "C", "C")
	self.color = { 1, 1, 1, 1 }
	self.layer = "gui"
	self.isChecked = false
end

function Checkbox.draw(self)
	local w, h = width, height
	love.graphics.setColor(bgColor)
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("line", -w/2, -h/2, w, h)

	if self.isChecked then
		love.graphics.setColor(checkColor)
		love.graphics.rectangle("fill", -checkW/2, -checkW/2, checkW, checkW)
	end

	local wgt = self.widget
	if wgt and wgt.isFocused then
		love.graphics.setColor(1, 1, 1, 0.3)
		w, h = w+8, h+8
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Checkbox
