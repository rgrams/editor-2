
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local File = BaseClass:extend()
File.className = "File"

local PropData = require "commands.data.PropData"
local config = require "config"
local InputField = require "ui.widgets.InputField"
local Button = require "ui.widgets.Button"
local fileDialog = require "lib.native-file-dialog.dialog"
local FilepathFieldTheme = require "ui.widgets.themes.FilepathFieldTheme"
local fileUtil = require "lib.file-util"

File.labelWidth = File.width/3
local dialogBtnWidth = 24

function File.set(self, name, value, PropClass, propObj)
	File.super.set(self, name, value, PropClass, propObj)

	self.field = InputField(self.value, 150)
	table.insert(self.children, self.field)

	self.button = Button("...", dialogBtnWidth, "center")
	table.insert(self.children, self.button)
end

function File.updateValue(self, value)
	self.fieldWgt:setText(value)
end

function File.onConfirm(self, wgt)
	if wgt.text == wgt.oldText then
		return
	end
	local value = wgt.text
	if not self.selection then
		print("Error: PropertyWidget[File].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
	end
end

function File.buttonPressed(self)
	local path = fileDialog.open(config.lastFilePropFolder)
	if path then
		config.lastFilePropFolder = fileUtil.splitFilepath(path)
		self.fieldWgt:setText(path)
		self:onConfirm(self.fieldWgt)
	end
end

function File.initRuu(self, ruu, navList)
	File.super.initRuu(self, ruu, navList)

	self.fieldWgt = self.ruu:InputField(self.field, self.onConfirm, self.value, FilepathFieldTheme)
	self.fieldWgt:args(self, self.fieldWgt)
	self.fieldWgt.alignRightOnUnfocus = true
	self:addWidget(self.fieldWgt)

	self.buttonWgt = self.ruu:Button(self.button, self.buttonPressed)
	self.buttonWgt:args(self)
	self:addWidget(self.buttonWgt)
end

return File
