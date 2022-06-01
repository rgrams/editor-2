
local Button = gui.Node:extend()
Button.className = "Button"

Button.font = { "assets/font/OpenSans-Semibold.ttf", 15 }
Button.width = 100
Button.height = 24

function Button.set(self, text, width, textAlign)
	width = width or self.width
	textAlign = textAlign or "left"
	Button.super.set(self, width, self.height)
	self.text = gui.Text(text or "text", self.font, width-6, "C", "C", textAlign)
	self.text:setPos(0, -1)
	self.children = { self.text }
	self.color = {1, 1, 1, 1}
	self.layer = "gui"
end

function Button.draw(self)
	local widget = self.widget
	if widget then
		widget.wgtTheme.draw(widget, self)
	end
end

return Button
