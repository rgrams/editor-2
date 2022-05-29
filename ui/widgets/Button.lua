
local Button = gui.Node:extend()
Button.className = "Button"

Button.font = { "assets/font/OpenSans-Semibold.ttf", 15 }
Button.width = 96
Button.height = 24

function Button.set(self, text, width, textAlign)
	width = width or self.width
	textAlign = textAlign or "left"
	Button.super.set(self, width, self.height)
	self.children = {
		gui.Text(text or "text", self.font, width-6, "C", "C", textAlign):setPos(0, -1)
	}
	self.text = self.children[1]
	self.text.color = {0, 0, 0, 1}
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
