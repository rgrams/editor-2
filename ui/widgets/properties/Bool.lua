
local Bool = gui.Row:extend()
Bool.className = "Bool"

local Checkbox = require "ui.widgets.Checkbox"
local checkboxTheme = require "ui.widgets.themes.checkbox"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local spacing = 2
local width = 100
local height = 26

function Bool.set(self, name, value)
	Bool.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.layer = "gui"
	self.propertyName = name
	self.value = value
	self.label = gui.Text(name, font, width, "W", "W", "left"):setPos(2)
	self.label.color = { 0.6, 0.6, 0.6, 1 }
	self.checkbox = Checkbox()
	self.children = { self.label, self.checkbox }
	self.label.isGreedy = true
	self.checkbox.color = { 1.65, 0.65, 0.65, 1 }
end

function Bool.ruuInput(wgt, depth, action, value, change)
	if action == "delete" and change == 1 then
		local self = wgt.object
		if not self.selection then
			print("Error: PropertyWidget[Bool].delete - No selection known.")
		else
			local scene = self.selection.scene
			local cmd = "removeSamePropertyFromMultiple"
			local enclosures = self.selection:copyList()
			scene.history:perform(cmd, enclosures, self.propertyName)
			local propertyPanel = self.tree:get("/Window/UI/PropertyPanel")
			propertyPanel:updateProperties(self.selection)
		end
	end
end

function Bool.setSelection(self, selection)
	self.selection = selection
end

function Bool.onToggle(self, wgt)
	local value = wgt.isChecked
	if not self.selection then
		print("Error: PropertyWidget[Bool].onToggle - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function Bool.initRuu(self, ruu, map)
	self.ruu = ruu
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	self.wgt = self.ruu:ToggleButton(self.checkbox, self.onToggle, self.value, checkboxTheme)
	self.wgt:args(self, self.wgt)
	table.insert(map, self.wgt)
	self.widgets = {
		[self.wgt] = true
	}
end

function Bool.destroyRuu(self, map)
	self.ruu:destroy(self.panel) -- Panel is not in navigation map.
	for i=#map,1,-1 do
		local wgt = map[i]
		if self.widgets[wgt] then
			self.widgets[wgt] = nil
			self.ruu:destroy(wgt)
			table.remove(map, i)
			if not next(self.widgets) then
				break
			end
		end
	end
end

function Bool.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Bool
