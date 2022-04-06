
local Button = gui.Node:extend()
Button.className = "Button"

Button.font = {"assets/font/OpenSans-Semibold.ttf", 15}
Button.width = 100
Button.height = 24

function Button.set(self, text)
	Button.super.set(self, self.width, self.height)
	self.children = {
		gui.Text(text or "text", self.font, self.width-6, "C", "C", "left"):setPos(0, -1)
	}
	self.text = self.children[1]
	self.text.color = {0, 0, 0, 1}
	self.color = {1, 1, 1, 1}
	self.layer = "gui"
end

function Button.draw(self)
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)

	if self.widget.isFocused then
		local w, h = self.w+4, self.h+4
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Button
