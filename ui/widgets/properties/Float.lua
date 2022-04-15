
local Float = gui.Row:extend()
Float.className = "Float"

local InputField = require "ui.widgets.InputField"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local spacing = 2
local width = 100
local height = 26

function Float.set(self, name, value)
	Float.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.propertyName = name
	self.value = value or 0
	self.label = gui.Text(name, font, width, "W", "W", "left"):setPos(2)
	self.label.color = { 0.6, 0.6, 0.6, 1 }
	self.field = InputField(self.value)
	self.children = { self.label, self.field }
	self.label.isGreedy = true
	self.field.color = { 0.65, 0.65, 0.65, 1 }
end

function Float.setSelection(self, selection)
	self.selection = selection
end

function Float.onConfirm(self, wgt)
	if wgt.text == wgt.oldText then
		return
	end
	local value = tonumber(wgt.text)
	if not value then
		return true -- Reject input.
	end
	if not self.selection then
		print("Error: PropertyWidget[Float].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function Float.initRuu(self, ruu, map)
	self.ruu = ruu
	self.widget = self.ruu:InputField(self.field, self.onConfirm, self.value)
	self.widget:args(self, self.widget)
	table.insert(map, self.widget)
end

function Float.destroyRuu(self, map)
	self.ruu:destroy(self.widget)
	for i,wgt in ipairs(map) do
		if wgt == self.widget then
			table.remove(map, i)
			break
		end
	end
end

return Float
