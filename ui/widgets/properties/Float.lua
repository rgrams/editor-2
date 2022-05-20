
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Float = BaseClass:extend()
Float.className = "Float"

local InputField = require "ui.widgets.InputField"

function Float.set(self, name, value, PropClass)
	Float.super.set(self, name, value, PropClass)
	self.field = InputField(self.value)
	table.insert(self.children, self.field)
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
		scene.history:perform(cmd, caller, enclosures, self.propertyName, value)
	end
end

function Float.initRuu(self, ruu, navList)
	Float.super.initRuu(self, ruu, navList)
	self.wgt = self.ruu:InputField(self.field, self.onConfirm, self.value)
	self.wgt:args(self, self.wgt)
	self:addWidget(self.wgt)
end

return Float
