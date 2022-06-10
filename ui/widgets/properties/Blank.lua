
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Blank = BaseClass:extend()
Blank.className = "Blank"

local labelFont = { "assets/font/OpenSans-Regular.ttf", 15 }

function Blank.set(self, name, value, PropClass, propObj)
	Blank.super.set(self, name, value, PropClass, propObj)
	local label = gui.Text("no widget available", labelFont, self.width/2, "E", "E", "right")
	label:setPos(-5)
	label.color = { 0.6, 0.6, 0.6, 1 }
	table.insert(self.children, label)
end

function Blank.updateValue(self, value)
end

return Blank
