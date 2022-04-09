
local Tool = gui.Node:extend()
Tool.className = "Tool"

local scenes = require "scenes"

function Tool.set(self, ruu)
	Tool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.widget.press = self.press
end

local function makeObj()
	local obj = Object()
	obj.draw = function()
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("line", -5, -5, 10, 10)
	end
	return obj
end

function Tool.press(wgt, mx, my, isKeyboard)
	print("Tool.press", mx, my, isKeyboard)
end

function Tool.ruuInput(wgt, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == "add" and change == 1 and Input.isPressed("shift") then
		if scenes.active then
			scenes.active:add(makeObj())
			return true
		end
	end
end

function Tool.draw(self)
	love.graphics.setColor(1, 0, 0, 1)
end

return Tool
