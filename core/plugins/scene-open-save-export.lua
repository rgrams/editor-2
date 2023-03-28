
local scenes = require "core.scenes"
local config = require "core.config"
local signals = require "core.signals"
local fileUtil = require "core.lib.file-util"
local fileDialog = require "core.lib.native-file-dialog.dialog"
local requirePath = require "core.require-path"

local function saveScene(scene, filepath)
	local isFirstSave = not scene.filepath

	scene.filepath = filepath
	local _, filename = fileUtil.splitFilepath(filepath)
	scene.name = filename
	local tabBar = editor.Tree:get("/Window/UI/MainRow/VPColumn/TabBar")
	tabBar:setTabText(scene, scene.name)
	local exporter = require "core.io.defaultLuaImportExport"
	exporter.export(scene, filepath)
	signals.send("file saved", editor.UI, scene, filepath)

	if isFirstSave and scene:getProperty("useProjectLocalPaths") then
		local projectFolder = fileUtil.findProject(scene.filepath, config.projectFileExtension)
		if projectFolder then  requirePath.prepend(projectFolder)  end
	end
	return true
end

local function exportScene(scene, exporterName, isExportAs)
	local exporter = _G.exporterList:get(exporterName)

	local filepath = not isExportAs and scene.lastExportFilepath
	if not filepath then  filepath = fileDialog.save(config.lastExportFolder or config.lastSaveFolder)  end
	if not filepath then  return true  end
	config.lastExportFolder = fileUtil.splitFilepath(filepath)
	if scene.lastExportFilepath ~= filepath then
		scene.lastExportFilepath = filepath
		signals.send("export path modified", editor.UI, scene, filepath)
	end
	scene.lastUsedExporter = exporterName

	exporter.export(scene, filepath)
	signals.send("file exported", editor.UI, scene, filepath, exporter)
	return true
end

local function openScene(filepath)
	-- If scene is already open, just switch to it.
	for i,scene in ipairs(scenes) do
		if scene.filepath == filepath then
			scenes.setActive(scene)
			return true
		end
	end
	-- Otherwise, import it into a new scene.
	local importer = require "core.io.defaultLuaImportExport"
	local scene = importer.import(filepath)
	if scene then
		scenes.add(scene)
		_G.shouldRedraw = true
	end
	return true
end

local function action_new()
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
end

local function action_save()
	if scenes.active then
		local filepath = scenes.active.filepath
		if not filepath then  filepath = fileDialog.save(config.lastSaveFolder)  end
		if not filepath then  return  end
		config.lastSaveFolder = fileUtil.splitFilepath(filepath)
		saveScene(scenes.active, filepath)
	end
end

local function action_saveAs()
	if scenes.active then
		local filepath = fileDialog.save(config.lastSaveFolder)
		if not filepath then  return  end
		config.lastSaveFolder = fileUtil.splitFilepath(filepath)
		saveScene(scenes.active, filepath)
	end
end

local function action_open()
	local paths = fileDialog.openMultiple(config.lastOpenFolder)
	if not paths then  return  end

	for i,filepath in ipairs(paths) do
		if i == 1 then
			local folder = fileUtil.splitFilepath(paths[1])
			config.lastOpenFolder = folder
		end
		openScene(filepath)
	end
end

local function getExporterNameList()
	local list = {}
	for i,exporter in ipairs(_G.exporterList) do
		list[i] = _G.exporterList:getName(exporter)
	end
	return list
end

local function action_export()
	if scenes.active then
		local exporterName = scenes.active.lastUsedExporter
		if not exporterName then
			-- Make callback for exporter choice box:
			local cb = function(choice)
				exporterName = choice
				if not exporterName then  return -- Canceled.
				else  exportScene(scenes.active, exporterName)  end
			end
			editor.multipleChoiceBox(getExporterNameList(), cb, "Choose an exporter:")
		else
			exportScene(scenes.active, exporterName)
		end
		return true
	end
end

local function action_exportAs()
	if scenes.active then
		-- Make callback for exporter choice box:
		local cb = function(choice)
			local exporterName = choice
			if not exporterName then  return -- Canceled.
			else  exportScene(scenes.active, exporterName, true)  end -- Continue export.
		end
		editor.multipleChoiceBox(getExporterNameList(), cb, "Choose an exporter:")
		return true
	end
end

editor.registerAction("new", action_new)
editor.registerAction("save", action_save)
editor.registerAction("save as", action_saveAs)
editor.registerAction("open", action_open)
editor.registerAction("export", action_export)
editor.registerAction("export as", action_exportAs)

editor.bindActionToInput("new", "new scene")
editor.bindActionToInput("save", "save")
editor.bindActionToInput("save as", "save as")
editor.bindActionToInput("open", "open")
editor.bindActionToInput("export", "export")
editor.bindActionToInput("export as", "export as")
