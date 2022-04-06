
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

function PropertyPanel.set(self, ruu)
	PropertyPanel.super.set(self, 5, false, nil, 250, 600, "E", "E", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Node(100, 20)
	}
	self.ruu = ruu
end

function PropertyPanel.draw(self)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
end

return PropertyPanel
