
local Button = require(GetRequireFolder(...) .. "Button")
local Checkbox = Button:extend()
Checkbox.className = "Checkbox"

local setValue = require "core.lib.setValue"
Checkbox.theme = require "core.ui.object-as-theme"

local totalW = 24
local totalH = 24
local boxWidth = 14
local boxHeight = 14
local checkW = 6
local bgColor = { 0.15, 0.15, 0.15, 1 }
local checkColor = { 0.8, 0.8, 0.8, 1 }

function Checkbox.set(self)
	gui.Node.set(self, totalW, totalH, "C", "C")
	self.color = { 1, 1, 1, 1 }
	setValue(self.color, self.normalValue)
	self.layer = "gui"
end

-- Use properties directly from widget, don't need to change anything on object.
function Checkbox.setChecked(self, widget, isChecked)  end

function Checkbox.initRuu(self, ruu, fn, value, ...)
	self.ruu = ruu
	local widget = ruu:ToggleButton(self, fn, value, self.theme):args(...)
	widget.object = self
	self.widget = widget
	return widget
end

function Checkbox.draw(self)
	local w, h = boxWidth, boxHeight
	love.graphics.setColor(bgColor)
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("line", -w/2, -h/2, w, h)

	local widget = self.widget
	if widget then
		if widget.isChecked then
			love.graphics.setColor(checkColor)
			love.graphics.rectangle("fill", -checkW/2, -checkW/2, checkW, checkW)
		end

		if widget.isFocused then
			love.graphics.setColor(1, 1, 1, 1)
			w, h = self.w - 2, self.h - 2
			love.graphics.rectangle("line", -w/2, -h/2, w, h)
		end
	end
end

return Checkbox
