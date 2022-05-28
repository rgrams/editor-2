
local UI = gui.Row:extend()
UI.className = "UI"

local Ruu = require "ui.ruu.ruu"
local Viewport = require "ui.Viewport"
local PropertyPanel = require "ui.PropertyPanel"
local ResizeHandle = require "ui.widgets.ResizeHandle"
local scenes = require "scenes"
local fileDialog = require "lib.native-file-dialog.dialog"
local fileUtil = require "lib.file-util"
local objectFn = require "commands.functions.object-functions"

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
		ResizeHandle("/Window/UI/PropertyPanel"),
		PropertyPanel(self.ruu)
	}

	self.children[2]:initRuu(self.ruu)

	self.propertyPanel = self.children[3]
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
		local past = scenes.active.history.past
		local cmd = past[#past] -- { name, doArgs, undoArgs }
		if cmd then
			local undoArgs = cmd[3]
			undoArgs[1] = self -- Set caller to ourself.
			scenes.active.history:undo()
		end
	elseif action == "redo" and (change == 1 or isRepeat) then
		local future = scenes.active.history.future
		local cmd = future[#future]
		if cmd then
			local redoArgs = cmd[2]
			redoArgs[1] = self -- Set caller to ourself.
			scenes.active.history:redo()
		end
	elseif action == "next tab" and (change == 1 or isRepeat) then
		if #scenes > 1 then
			local index = scenes.getIndex(scenes.active)
			local nextIndex = ((index - 1 + 1) % #scenes) + 1
			scenes.setActive(scenes[nextIndex])
		end
	elseif action == "prev tab" and (change == 1 or isRepeat) then
		if #scenes > 1 then
			local index = scenes.getIndex(scenes.active)
			local prevIndex = ((index - 1 - 1) % #scenes) + 1
			scenes.setActive(scenes[prevIndex])
		end
	elseif action == "save" and change == 1 then
		if scenes.active then
			local filepath = scenes.active.filepath
			if not filepath then  filepath = fileDialog.save(lastSaveFolder)  end
			if not filepath then  return  end
			lastSaveFolder = fileUtil.splitFilepath(filepath)
			self:saveScene(scenes.active, filepath)
		end
	elseif action == "save as" and change == 1 then
		if scenes.active then
			local filepath = fileDialog.save(lastSaveFolder)
			if not filepath then  return  end
			lastSaveFolder = fileUtil.splitFilepath(filepath)
			self:saveScene(scenes.active, filepath)
		end
	elseif action == "open" and change == 1 then
		local filepath = fileDialog.open(lastOpenFolder)
		if not filepath then  return  end

		local folder = fileUtil.splitFilepath(filepath)
		lastOpenFolder = folder

		self:openScene(filepath)
	end
end

function UI.saveScene(self, scene, filepath)
	scene.filepath = filepath
	local _, filename = fileUtil.splitFilepath(filepath)
	scene.name = filename
	if scenes.active == scene then
		love.window.setTitle("Editor - " .. scene.name)
	end
	local exporter = require "io.defaultLuaImportExport"
	exporter.export(scene, filepath)
end

function UI.openScene(self, filepath)
	local _, filename = fileUtil.splitFilepath(filepath)
	local importer = require "io.defaultLuaImportExport"
	local scene = scenes.create(filename, filepath)
	local addArgsList = importer.import(scene, filepath)
	if addArgsList then
		objectFn.addObjects(self, scene, addArgsList)
		scenes.add(scene)
		_G.shouldRedraw = true
	end
end

return UI
