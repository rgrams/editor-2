
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
	self.layer = "gui"
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
	self.panel = self.ruu:Panel(self)
	self.wgt = self.ruu:InputField(self.field, self.onConfirm, self.value)
	self.wgt:args(self, self.wgt)
	table.insert(map, self.wgt)
	self.widgets = {
		[self.wgt] = true
	}
end

function Float.destroyRuu(self, map)
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

function Float.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Float
