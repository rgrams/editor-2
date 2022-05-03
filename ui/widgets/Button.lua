
local Button = gui.Node:extend()
Button.className = "Button"

Button.font = {"assets/font/OpenSans-Semibold.ttf", 15}
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
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)

	local wgt = self.widget
	if wgt and wgt.isFocused then
		if wgt.wgtTheme.drawFocus then
			wgt.wgtTheme.drawFocus(wgt, self)
		else
			love.graphics.setColor(1, 1, 1, 1)
			local w, h = self.w+2, self.h+2
			love.graphics.rectangle("line", -w/2, -h/2, w, h)
		end
	end
end

return Button
