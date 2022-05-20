
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Enum = BaseClass:extend()
Enum.className = "Enum"

local Button = require "ui.widgets.Button"
local Dropdown = require "ui.widgets.Dropdown"

function Enum.set(self, name, value, PropClass)
	Enum.super.set(self, name, value, PropClass)
	self.PropClass = PropClass

	self.button = Button(value, nil, "center")
	table.insert(self.children, self.button)
	self.button.color = { 1.65, 0.65, 0.65, 1 }

	local items = {} -- item = { text=, fn=, args= }
	self.dropdownItems = items
	for i,val in ipairs(PropClass.validValues) do
		items[i] = { text = val, fn = self.setValue, args = { self, val } }
	end
end

function Enum.setValue(self, value)
	self.button.text.text = value
	self.value = value
	if not self.selection then
		print("Error: PropertyWidget[Enum].setValue - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, self.propertyName, value)
	end
end

function Enum.onButtonPress(self, wgt)
	local btn = wgt.object
	local x, y = btn:toWorld(-btn.w/2, -btn.h/2)
	local focusedIndex = self.PropClass:getIndex(self.value)
	local dropdown = Dropdown(x, y, self.dropdownItems, focusedIndex)
	local guiRoot = self.tree:get("/Window")
	self.tree:add(dropdown, guiRoot)
end

function Enum.initRuu(self, ruu, navList)
	Enum.super.initRuu(self, ruu, navList)

	self.wgt = self.ruu:Button(self.button, self.onButtonPress)
	self.wgt:args(self, self.wgt)
	self:addWidget(self.wgt)
end

return Enum
