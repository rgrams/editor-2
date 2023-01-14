
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local String = BaseClass:extend()
String.className = "String"

local PropData = require "core.commands.data.PropData"
local InputField = require "core.ui.widgets.InputField"

String.labelWidth = String.width/4

function String.set(self, name, value, PropClass, propObj)
	String.super.set(self, name, value, PropClass, propObj)
	self.field = InputField(self.value, 175)
	table.insert(self.children, self.field)
end

function String.updateValue(self, value)
	self.wgt:setText(value)
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
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
	end
end

function String.initRuu(self, ruu, navList)
	String.super.initRuu(self, ruu, navList)
	self.wgt = self.field:initRuu(self.ruu, self.onConfirm)
	self.wgt:args(self, self.wgt)
	self:addWidget(self.wgt)
end

return String
