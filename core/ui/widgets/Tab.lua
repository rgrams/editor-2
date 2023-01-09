
local Button = require "core.ui.widgets.Button"
local Tab = Button:extend()
Tab.className = "Tab"

Tab.width = 120
Tab.height = 24
Tab.buttonWidth = 20

function Tab.set(self, text)
	Tab.super.set(self, text, self.width, "left")
	self.text:setPivot("W"):setAnchor("W")
	self:setPad(3)
	local w = self.buttonWidth
	self.closeBtn = Button("x", w, "center"):setPivot("E"):setAnchor("E"):setSize(w, w, true):setPos(1)
	table.insert(self.children, self.closeBtn)
end

-- .setChecked() - Doesn't fire any callback, just updates the self.isChecked & the theme.

return Tab
