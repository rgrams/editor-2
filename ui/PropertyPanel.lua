
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

function PropertyPanel.set(self, ruu)
	PropertyPanel.super.set(self, 5, false, nil, 250, 600, "E", "E", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Node(100, 20)
	}
	self.layer = "gui"
	self.ruu = ruu
	self.widget = self.ruu:Panel(self)
end

local maxLineWidth = 1

function PropertyPanel.draw(self)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	if self.widget.isFocused then
		local depth = self.panelIndex or 0
		local lineWidth = maxLineWidth / (depth + 1)
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor(1, 1, 1, 0.5)

		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)

		love.graphics.setLineWidth(1)
	end
end

return PropertyPanel
