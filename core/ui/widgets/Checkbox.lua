
local Checkbox = gui.Node:extend()
Checkbox.className = "Checkbox"

local totalW = 24
local totalH = 24

function Checkbox.set(self)
	Checkbox.super.set(self, totalW, totalH, "C", "C")
	self.color = { 1, 1, 1, 1 }
	self.layer = "gui"
end

function Checkbox.draw(self)
	local widget = self.widget
	if widget then
		widget.theme.draw(widget, self)
	end
end

return Checkbox
