
local Button = require "ui.widgets.Button"
local Tab = Button:extend()
Tab.className = "Tab"

Tab.width = 120
Tab.height = 24

function Tab.set(self, text)
	Tab.super.set(self, text, self.width, "left")
	self.text:pivot("W"):anchor("W")
	self:pad(3)
	self.closeBtn = Button("x", 20, "center"):pivot("E"):anchor("E"):size(20, 20, true)
	table.insert(self.children, self.closeBtn)
end

-- .setChecked() - Doesn't fire any callback, just updates the self.isChecked & the theme.

return Tab
