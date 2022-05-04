
local File = gui.Row:extend()
File.className = "File"

local InputField = require "ui.widgets.InputField"
local Button = require "ui.widgets.Button"
local fileDialog = require "lib.native-file-dialog.dialog"
local fileFieldTheme = require "ui.widgets.themes.filepath-inputField"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local spacing = 2
local width = 100
local height = 26
local dialogBtnWidth = 24

function File.set(self, name, value)
	File.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.propertyName = name
	self.value = value or ""

	self.label = gui.Text(name, font, width/3, "W", "W", "left"):setPos(2)
	self.label.color = { 0.6, 0.6, 0.6, 1 }

	self.field = InputField(self.value, 150)

	self.button = Button("...", dialogBtnWidth, "center")

	self.children = { self.label, self.field, self.button }

	self.label.isGreedy = true
	self.field.color = { 0.65, 0.65, 0.65, 1 }
end

function File.setSelection(self, selection)
	self.selection = selection
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
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function File.buttonPressed(self)
	local path = fileDialog.open()
	if path then
		self.fieldWgt:setText(path)
		self:onConfirm(self.fieldWgt)
	end
end

function File.initRuu(self, ruu, map)
	self.ruu = ruu
	self.fieldWgt = self.ruu:InputField(self.field, self.onConfirm, self.value, fileFieldTheme)
	self.fieldWgt:args(self, self.fieldWgt)
	self.fieldWgt.alignRightOnUnfocus = true
	table.insert(map, self.fieldWgt)
	self.buttonWgt = self.ruu:Button(self.button, self.buttonPressed)
	self.buttonWgt:args(self)
	table.insert(map, self.buttonWgt)
end

function File.destroyRuu(self, map)
	self.ruu:destroy(self.fieldWgt)
	self.ruu:destroy(self.buttonWgt)
	for i=#map,1,-1 do
		local wgt = map[i]
		if wgt == self.fieldWgt then
			table.remove(map, i)
			self.fieldWgt = nil
		elseif wgt == self.buttonWgt then
			table.remove(map, i)
			self.buttonWgt = nil
		end
		if not self.fieldWgt and not self.buttonWgt then
			return
		end
	end
end

return File