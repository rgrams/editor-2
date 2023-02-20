
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local File = BaseClass:extend()
File.className = "File"

local PropData = require "core.commands.data.PropData"
local config = require "core.config"
local FilepathInputField = require "core.ui.widgets.InputField-Filepath"
local Button = require "core.ui.widgets.Button"
local fileDialog = require "core.lib.native-file-dialog.dialog"
local fileUtil = require "core.lib.file-util"

File.labelWidth = File.width/3
local dialogBtnWidth = 24
local defaultLastFolderKey = "lastFilePropFolder"

function File.set(self, name, value, PropClass, propObj)
	File.super.set(self, name, value, PropClass, propObj)

	self.lastFolderKey = propObj.lastFolderKey or defaultLastFolderKey

	self.field = FilepathInputField(self.value, 150)
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
	local lastFolder = config[self.lastFolderKey] or config.lastFilePropFolder or config.lastOpenFolder
	local path = fileDialog.open(lastFolder)
	if path then
		config[self.lastFolderKey] = fileUtil.splitFilepath(path)
		self.fieldWgt:setText(path)
		self:onConfirm(self.fieldWgt)
	end
end

function File.initRuu(self, ruu, ...)
	File.super.initRuu(self, ruu, ...)

	self.fieldWgt = self.field:initRuu(self.ruu, self.onConfirm)
	self.fieldWgt:args(self, self.fieldWgt)
	self:registerWidget(self.fieldWgt)

	self.buttonWgt = self.button:initRuu(self.ruu, self.buttonPressed)
	self.buttonWgt:args(self)
	self:registerWidget(self.buttonWgt)
end

return File
