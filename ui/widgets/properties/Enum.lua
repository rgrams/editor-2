
local Enum = gui.Row:extend()
Enum.className = "Enum"

local Button = require "ui.widgets.Button"
local Dropdown = require "ui.widgets.Dropdown"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local spacing = 2
local width = 100
local height = 26

function Enum.set(self, name, value, PropClass)
	Enum.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.layer = "gui"
	self.propertyName = name
	self.value = value
	self.label = gui.Text(name, font, width, "W", "W", "left"):setPos(2)
	self.label.color = { 0.6, 0.6, 0.6, 1 }
	self.button = Button(value, nil, "center")
	self.children = { self.label, self.button }
	self.label.isGreedy = true
	self.button.color = { 1.65, 0.65, 0.65, 1 }

	local items = {} -- item = { text=, fn=, args= }
	self.dropdownItems = items
	for i,val in ipairs(PropClass.validValues) do
		items[i] = { text = val, fn = self.setValue, args = { self, val } }
	end
end

function Enum.ruuInput(wgt, depth, action, value, change)
	if action == "delete" and change == 1 then
		local self = wgt.object
		if not self.selection then
			print("Error: PropertyWidget[Enum].delete - No selection known.")
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

function Enum.setSelection(self, selection)
	self.selection = selection
end

function Enum.setValue(self, value)
	self.button.text.text = value
	if not self.selection then
		print("Error: PropertyWidget[Enum].setValue - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function Enum.onButtonPress(self, wgt)
	local btn = wgt.object
	local x, y = btn:toWorld(-btn.w/2, -btn.h/2)
	local dropdown = Dropdown(x, y, self.dropdownItems)
	local guiRoot = self.tree:get("/Window")
	self.tree:add(dropdown, guiRoot)
end

function Enum.initRuu(self, ruu, map)
	self.ruu = ruu
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	self.wgt = self.ruu:Button(self.button, self.onButtonPress)
	self.wgt:args(self, self.wgt)
	table.insert(map, self.wgt)
	self.widgets = {
		[self.wgt] = true
	}
end

function Enum.destroyRuu(self, map)
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

function Enum.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Enum
