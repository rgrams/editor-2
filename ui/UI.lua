
local UI = gui.Column:extend()
UI.className = "UI"

local config = require "config"
local Ruu = require "ui.ruu.ruu"
local Toolbar = require "ui.Toolbar"
local TabBar = require "ui.TabBar"
local Viewport = require "ui.Viewport"
local PropertyPanel = require "ui.PropertyPanel"
local ResizeHandle = require "ui.widgets.ResizeHandle"
local scenes = require "scenes"
local fileDialog = require "lib.native-file-dialog.dialog"
local fileUtil = require "lib.file-util"
local requirePath = require "require-path"
local signals = require "signals"
local updateSceneTitleScript = require "ui.updateSceneTitle_script"

Ruu.isHoverAction["pan camera"] = true
Ruu.isHoverAction["right click"] = true

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, 0, false, -1, w, h, "C", "C", "fill")
	self.layer = "viewport"

	self.ruu = Ruu()
	self.ruu:registerLayers({"viewport", "gui"}) -- Bottom to top.

	self.widget = self.ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput

	local vpCol = gui.Column(0, false, -1, 100, 100, "C", "C", "fill")
	vpCol.name = "VPColumn"
	vpCol.isGreedy = true
	vpCol.children = {
		TabBar(self.ruu),
		Viewport(self.ruu),
	}

	local mainRow = gui.Row(0, false, -1, 50, 50, "C", "C", "fill")
	mainRow.name = "MainRow"
	mainRow.isGreedy = true
	mainRow.children = {
		vpCol,
		ResizeHandle("/Window/UI/MainRow/PropertyPanel"),
		PropertyPanel(self.ruu)
	}

	self.children = {
		Toolbar(self.ruu),
		mainRow,
	}

	mainRow.children[2]:initRuu(self.ruu)

	self.propertyPanel = mainRow.children[3]

	self.scripts = { updateSceneTitleScript }
end

function UI.init(self)
	UI.super.init(self)
	Input.enable(self)
	self.ruu:mouseMoved(love.mouse.getPosition()) -- NOTE: Always gives 0, 0 :/
end

function UI.final(self)
	Input.disable(self)
end

local function getExporterNameList()
	local list = {}
	for i,exporter in ipairs(_G.exporterList) do
		list[i] = _G.exporterList:getName(exporter)
	end
	return list
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
			signals.send("undo", self, cmd)
		end
	elseif action == "redo" and (change == 1 or isRepeat) then
		local future = scenes.active.history.future
		local cmd = future[#future]
		if cmd then
			local redoArgs = cmd[2]
			redoArgs[1] = self -- Set caller to ourself.
			scenes.active.history:redo()
			signals.send("redo", self, cmd)
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
	elseif action == "close tab" and (change == 1) then
		scenes.remove(scenes.active)
	elseif action == "new scene" and (change == 1) then
		local name = "Untitled"
		local suffixIndex = 0
		local existingSceneName = {}
		for i,scene in ipairs(scenes) do
			existingSceneName[scene.name] = true
		end
		while existingSceneName[name] do
			suffixIndex = suffixIndex + 1
			name = "Untitled-" .. suffixIndex
		end
		scenes.add( scenes.create(name) )
	elseif action == "save" and change == 1 then
		if scenes.active then
			local filepath = scenes.active.filepath
			if not filepath then  filepath = fileDialog.save(config.lastSaveFolder)  end
			if not filepath then  return  end
			config.lastSaveFolder = fileUtil.splitFilepath(filepath)
			self:saveScene(scenes.active, filepath)
		end
	elseif action == "save as" and change == 1 then
		if scenes.active then
			local filepath = fileDialog.save(config.lastSaveFolder)
			if not filepath then  return  end
			config.lastSaveFolder = fileUtil.splitFilepath(filepath)
			self:saveScene(scenes.active, filepath)
		end
	elseif action == "open" and change == 1 then
		local filepath = fileDialog.open(config.lastOpenFolder)
		if not filepath then  return  end

		local folder = fileUtil.splitFilepath(filepath)
		config.lastOpenFolder = folder

		self:openScene(filepath)
	elseif action == "export" and change == 1 then
		if scenes.active then
			local exporterName = scenes.active.lastUsedExporter
			if not exporterName then
				local cb = function(choice)
					exporterName = choice
					if not exporterName then  return -- Canceled.
					else  self:exportScene(scenes.active, exporterName)  end -- Continue export.
				end
				editor.multipleChoiceBox(getExporterNameList(), cb, "Choose an exporter:")
				return -- multiChoiceBox callback will continue the export (or not).
			else
				self:exportScene(scenes.active, exporterName)
			end
		end
	elseif action == "export as" and change == 1 then
		if scenes.active then
			local cb = function(choice)
				local exporterName = choice
				if not exporterName then  return -- Canceled.
				else  self:exportScene(scenes.active, exporterName, true)  end -- Continue export.
			end
			editor.multipleChoiceBox(getExporterNameList(), cb, "Choose an exporter:")
			return -- multiChoiceBox callback will continue the export (or not).
		end
	elseif action == "run game" and change == 1 then
		local scene = scenes.active
		if scene then
			if not scene.filepath then
				editor.messageBox("Can't run the game for this scene, it hasn't been saved anywhere!", "Failed to run game")
			else
				local gameFolder
				if scene:getProperty("useProjectLocalPaths") then
					local projectFolder = fileUtil.findProject(scene.filepath, config.projectFileExtension)
					if not projectFolder then
						editor.messageBox("Can't find project for this scene: \n\n"..tostring(scene.filepath).."\n", "Failed to run game")
						return
					else
						gameFolder = projectFolder
					end
				else
					gameFolder = fileUtil.splitFilepath(scene.filepath)
				end
				print("   running game in folder: "..tostring(gameFolder))
				os.execute("love '"..gameFolder.."'")
			end
		end
	end
end

function UI.saveScene(self, scene, filepath)
	local isFirstSave = not scene.filepath
	scene.filepath = filepath
	local _, filename = fileUtil.splitFilepath(filepath)
	scene.name = filename
	local tabBar = self.tree:get("/Window/UI/MainRow/VPColumn/TabBar")
	tabBar:setTabText(scene, scene.name)
	local exporter = require "io.defaultLuaImportExport"
	exporter.export(scene, filepath)
	signals.send("file saved", self, scene, filepath)
	if isFirstSave and scene:getProperty("useProjectLocalPaths") then
		local projectFolder = fileUtil.findProject(scene.filepath, config.projectFileExtension)
		if projectFolder then  requirePath.prepend(projectFolder)  end
	end
end

function UI.exportScene(self, scene, exporterName, isExportAs)
	local exporter = _G.exporterList:get(exporterName)

	local filepath = not isExportAs and scene.lastExportFilepath
	if not filepath then  filepath = fileDialog.save(config.lastExportFolder or config.lastSaveFolder)  end
	if not filepath then  return  end
	config.lastExportFolder = fileUtil.splitFilepath(filepath)
	if scene.lastExportFilepath ~= filepath then
		scene.lastExportFilepath = filepath
		signals.send("export path modified", self, scene, filepath)
	end
	scene.lastUsedExporter = exporterName

	exporter.export(scene, filepath)
	signals.send("file exported", self, scene, filepath, exporter)
end

function UI.openScene(self, filepath)
	-- If scene is already open, just switch to it.
	for i,scene in ipairs(scenes) do
		if scene.filepath == filepath then
			scenes.setActive(scene)
			return
		end
	end

	local importer = require "io.defaultLuaImportExport"
	local scene = importer.import(filepath)
	if scene then
		scenes.add(scene)
		_G.shouldRedraw = true
	end
end

return UI
