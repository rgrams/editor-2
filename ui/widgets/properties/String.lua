
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local String = BaseClass:extend()
String.className = "String"

local InputField = require "ui.widgets.InputField"

String.labelWidth = String.width/4

function String.set(self, name, value, PropClass)
	String.super.set(self, name, value, PropClass)
	self.field = InputField(self.value, 175)
	table.insert(self.children, self.field)
end

function String.onConfirm(self, wgt)
	if wgt.text == wgt.oldText then
		return
	end
	local value = wgt.text
	if not self.selection then
		print("Error: PropertyWidget[String].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function String.initRuu(self, ruu, navList)
	String.super.initRuu(self, ruu, navList)
	self.wgt = self.ruu:InputField(self.field, self.onConfirm, self.value)
	self.wgt:args(self, self.wgt)
	self:addWidget(self.wgt)
end

return String