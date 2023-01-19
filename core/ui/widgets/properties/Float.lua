
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Float = BaseClass:extend()
Float.className = "Float"

local PropData = require "core.commands.data.PropData"
local InputField = require "core.ui.widgets.InputField"

function Float.set(self, name, value, PropClass, propObj)
	Float.super.set(self, name, value, PropClass, propObj)
	self.field = InputField(self.value)
	table.insert(self.children, self.field)
end

function Float.updateValue(self, value)
	self.wgt:setText(value)
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
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
	end
end

function Float.initRuu(self, ruu, ...)
	Float.super.initRuu(self, ruu, ...)
	self.wgt = self.field:initRuu(self.ruu, self.onConfirm)
	self.wgt:args(self, self.wgt)
	self:registerWidget(self.wgt)
end

return Float
