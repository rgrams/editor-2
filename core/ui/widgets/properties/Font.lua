
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Font = BaseClass:extend()
Font.className = "Font"

local PropData = require "core.commands.data.PropData"
local config = require "core.config"
local InputField = require "core.ui.widgets.InputField"
local FilepathInputField = require "core.ui.widgets.InputField-Filepath"
local Button = require "core.ui.widgets.Button"
local fileDialog = require "core.lib.native-file-dialog.dialog"
local fileUtil = require "core.lib.file-util"

Font.labelWidth = Font.width/3
local dialogBtnWidth = 24

function Font.set(self, name, value, PropClass, propObj)
	Font.super.set(self, name, value, PropClass, propObj)

	self.sizeField = InputField(self.value[2], 35)
	table.insert(self.children, self.sizeField)

	self.pathField = FilepathInputField(self.value[1], 115)
	table.insert(self.children, self.pathField)

	self.button = Button("...", dialogBtnWidth, "center")
	table.insert(self.children, self.button)
end

function Font.updateValue(self, value)
	self.pathWgt:setText(value[1])
	self.sizeWgt:setText(value[2])
end

function Font.onConfirm(self, wgt, field)
	if wgt.text == wgt.oldText then
		return
	end
	local value = wgt.text
	if field == "size" and not tonumber(wgt.text) then
		return true
	end
	if not self.selection then
		print("Error: PropertyWidget[Font].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local propValue = {}
		if field == "path" then
			propValue[1] = value
		else
			propValue[2] = value
		end
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, propValue))
	end
end

function Font.buttonPressed(self)
	local path = fileDialog.open(config.lastFontPropFolder)
	if path then
		config.lastFontPropFolder = fileUtil.splitFilepath(path)
		self.pathWgt:setText(path)
		self:onConfirm(self.pathWgt, "path")
	end
end

function Font.initRuu(self, ruu, navList)
	Font.super.initRuu(self, ruu, navList)

	self.sizeWgt = self.sizeField:initRuu(self.ruu, self.onConfirm)
	self.sizeWgt:args(self, self.sizeWgt, "size")
	self:addWidget(self.sizeWgt)

	self.pathWgt = self.pathField:initRuu(self.ruu, self.onConfirm)
	self.pathWgt:args(self, self.pathWgt, "path")
	self:addWidget(self.pathWgt)

	self.buttonWgt = self.button:initRuu(self.ruu, self.buttonPressed)
	self.buttonWgt:args(self)
	self:addWidget(self.buttonWgt)
end

return Font
