
local UI = gui.Row:extend()
UI.className = "UI"

local Ruu = require "ui.ruu.ruu"
local Viewport = require "ui.Viewport"
local PropertyPanel = require "ui.PropertyPanel"
local scenes = require "scenes"
local fileDialog = require "lib.native-file-dialog.dialog"
local fileUtil = require "lib.file-util"

local lastOpenFolder
local lastSaveFolder

Ruu.isHoverAction["pan camera"] = true
Ruu.isHoverAction["right click"] = true

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, 0, false, -1, w, h, "C", "C", "fill")
	self.layer = "gui"

	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})

	self.widget = self.ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput

	self.children = {
		Viewport(self.ruu),
		PropertyPanel(self.ruu)
	}

	self.propertyPanel = self.children[2]
	self.tool = self.children[1].children[1]
end

function UI.init(self)
	UI.super.init(self)
	Input.enable(self)
	self.ruu:mouseMoved(love.mouse.getPosition()) -- NOTE: Always gives 0, 0 :/
end

function UI.final(self)
	Input.disable(self)
end

function UI.input(self, action, value, change, rawChange, isRepeat, ...)
	local r = self.ruu:input(action, value, change, rawChange, isRepeat, ...)
	if r then  return r  end

	if action == "undo" and (change == 1 or isRepeat) then
		scenes.active.history:undo()
		self.propertyPanel:updateProperties(scenes.active.selection)
		self.tool:objectsUpdated()
	elseif action == "redo" and (change == 1 or isRepeat) then
		scenes.active.history:redo()
		self.propertyPanel:updateProperties(scenes.active.selection)
		self.tool:objectsUpdated()
	elseif action == "save" and change == 1 then
		if scenes.active then
			local filepath = fileDialog.save(lastSaveFolder)
			if not filepath then  return  end
			lastSaveFolder = fileUtil.splitFilepath(filepath)
			local exporter = require "io.defaultLuaImportExport"
			exporter.export(scenes.active, filepath)
		end
	elseif action == "open" and change == 1 then
		local filepath = fileDialog.open(lastOpenFolder)
		if not filepath then  return  end
		lastOpenFolder = fileUtil.splitFilepath(filepath)
		local importer = require "io.defaultLuaImportExport"
		importer.import(scenes.active, filepath)
	end
end

return UI
