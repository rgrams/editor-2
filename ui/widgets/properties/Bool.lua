
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Bool = BaseClass:extend()
Bool.className = "Bool"

local Checkbox = require "ui.widgets.Checkbox"
local CheckboxTheme = require "ui.widgets.themes.CheckboxTheme"

function Bool.set(self, name, value, PropClass, propObj)
	Bool.super.set(self, name, value, PropClass, propObj)
	self.checkbox = Checkbox()
	self.checkbox.color = { 1.65, 0.65, 0.65, 1 }
	table.insert(self.children, self.checkbox)
end

function Bool.updateValue(self, value)
	self.wgt:setChecked(value)
end

function Bool.onToggle(self, wgt)
	local value = wgt.isChecked
	if not self.selection then
		print("Error: PropertyWidget[Bool].onToggle - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, self.propertyName, value)
	end
end

function Bool.initRuu(self, ruu, navList)
	Bool.super.initRuu(self, ruu, navList)
	self.wgt = self.ruu:ToggleButton(self.checkbox, self.onToggle, self.value, CheckboxTheme)
	self.wgt:args(self, self.wgt)
	self:addWidget(self.wgt)
end

return Bool
