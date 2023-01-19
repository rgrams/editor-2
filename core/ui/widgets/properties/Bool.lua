
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Bool = BaseClass:extend()
Bool.className = "Bool"

local PropData = require "core.commands.data.PropData"
local Checkbox = require "core.ui.widgets.Checkbox"

function Bool.set(self, name, value, PropClass, propObj)
	Bool.super.set(self, name, value, PropClass, propObj)
	self.checkbox = Checkbox()
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
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
	end
end

function Bool.initRuu(self, ruu, ...)
	Bool.super.initRuu(self, ruu, ...)
	self.wgt = self.checkbox:initRuu(self.ruu, self.onToggle, self.value)
	self.wgt:args(self, self.wgt)
	self:registerWidget(self.wgt)
end

return Bool
