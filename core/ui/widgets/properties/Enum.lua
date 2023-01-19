
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Enum = BaseClass:extend()
Enum.className = "Enum"

local PropData = require "core.commands.data.PropData"
local Button = require "core.ui.widgets.Button"
local Dropdown = require "core.ui.widgets.Dropdown"

function Enum.set(self, name, value, PropClass, propObj)
	Enum.super.set(self, name, value, PropClass, propObj)
	self.PropClass = PropClass

	self.button = Button(value, nil, "center")
	table.insert(self.children, self.button)

	local items = {} -- item = { text=, fn=, args= }
	self.dropdownItems = items
	for i,val in ipairs(PropClass.validValues) do
		items[i] = { text = val, fn = self.setValue, args = { self, val } }
	end
end

function Enum.updateValue(self, value)
	self.button.text.text = value
	self.value = value
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
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
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

function Enum.initRuu(self, ruu, ...)
	Enum.super.initRuu(self, ruu, ...)

	self.wgt = self.button:initRuu(ruu, self.onButtonPress)
	self.wgt:args(self, self.wgt)
	self:registerWidget(self.wgt)
end

return Enum
