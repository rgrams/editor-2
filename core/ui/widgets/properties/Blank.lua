
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Blank = BaseClass:extend()
Blank.className = "Blank"

function Blank.set(self, name, value, PropClass, propObj)
	Blank.super.set(self, name, value, PropClass, propObj)
	local label = gui.Text("no widget available", self.font, self.width/2, "E", "E", "right")
	label:setPos(-5)
	label.color = self.labelColor
	table.insert(self.children, label)
end

function Blank.updateValue(self, value)
end

return Blank
