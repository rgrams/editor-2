
-- Scene importer & exporter for the editor's default lua file format.

local M = {}

local objToStr = require "core.philtre.lib.object-to-string"
local fileUtil = require "core.lib.file-util"
local scenes = require "core.scenes"
local objectFn = require "core.commands.functions.object-functions"
local propFn = require "core.commands.functions.property-functions"
local classList = _G.objClassList
local propClassList = _G.propClassList
local config = require "core.config"
local ChildScene = require "core.objects.ChildScene"
local AddObjData = require "core.commands.data.AddObjData"
local PropData = require "core.commands.data.PropData"
local requirePath = require "core.require-path"

M.defaultOptions = {
	omitUnmodifiedBuiltins = true
}

local function getPropExportValue(prop, localFilepath)
	local val = prop:copyValue()
	local propType = prop.typeName
	if propType == "file" or propType == "image" or propType == "script" then
		if val ~= "" then
			val = fileUtil.getRelativePath(localFilepath, val)
		end
	elseif propType == "font" then
		if val[1] ~= "" then
			val[1] = fileUtil.getRelativePath(localFilepath, val[1])
		end
	end
	return val
end

local function copyPropertyData(child, omitUnmod, localFilepath)
	local properties = {}
	for _,prop in ipairs(child.properties) do
		local doExport = false
		if child.isChildSceneObj then
			if not (omitUnmod and prop:isAtDefault()) then
				doExport = true
			end
		else
			if not (omitUnmod and prop.isClassBuiltin and prop:isAtDefault()) then
				doExport = true
			end
		end
		if doExport then
			local propExportData = {
				name = prop.name,
				value = getPropExportValue(prop, localFilepath),
				type = prop.typeName
			}
			if not prop.isClassBuiltin then  propExportData.isExtra = true  end
			table.insert(properties, propExportData)
		end
	end
	return properties
end

local function getSceneAddedObjects(children, idMap, list, parentID)
	for i=1,children.maxn or #children do
		local obj = children[i]
		if obj then
			if not idMap[obj:getProperty("id")] then
				list = list or {}
				table.insert(list, { obj=obj, parentID=parentID })
			elseif obj.children then -- Only want base objects added, not all their descendants.
				getSceneAddedObjects(obj.children, idMap, list, obj:getProperty("id"))
			end
		end
	end
	return list
end

local copyChildrenData

local function copyChildData(child, options, localFilepath)
	local omitUnmod = options.omitUnmodifiedBuiltins
	local data = {}
	local Class = getmetatable(child)
	data.class = Class.displayName
	if Class == ChildScene then
		data.sceneFilepath = fileUtil.getRelativePath(localFilepath, child.sceneFilepath)
		local childProperties = {}
		for id,enclosure in pairs(child.sceneEnclosureIDMap) do
			local obj = enclosure[1]
			local props = copyPropertyData(obj, omitUnmod, localFilepath)
			if #props > 0 then
				childProperties[id] = props
			end
		end
		-- TODO: Get deleted objects.
		--   Check each object in the ID map to see if it still exists.
		-- Get added objects.
		local addedObjects = {}
		if child.children then
			local parentID = child:getProperty("id")
			local addedObjList = getSceneAddedObjects(child.children, child.sceneEnclosureIDMap, {}, parentID)
			for i,v in ipairs(addedObjList) do
				addedObjects[v.parentID] = addedObjects[v.parentID] or {}
				local childData = copyChildData(v.obj, options, localFilepath)
				table.insert(addedObjects[v.parentID], childData)
			end
		end
		local mods = {
			rootProperties = copyPropertyData(child, omitUnmod, localFilepath),
			childProperties = childProperties,
			addedObjects = addedObjects,
		}
		data.properties = mods
	else
		data.properties = copyPropertyData(child, omitUnmod, localFilepath)
		if child.children then
			data.children = copyChildrenData(child.children, options, localFilepath)
		end
	end
	return data
end

function copyChildrenData(children, options, localFilepath)
	local output = {}
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			local data = copyChildData(child, options, localFilepath)
			table.insert(output, data)
		end
	end
	return output
end

function M.export(scene, filepath, options)
	print("EXPORT: "..filepath)
	local file, errMsg = io.open(filepath, "w")
	if not file then
		editor.messageBox(errMsg, "Export Failed: Could not access target file")
		return
	end

	local relFilepathFolder = filepath

	if scene:getProperty("useProjectLocalPaths") then
		local projectFolder = fileUtil.findProject(filepath, config.projectFileExtension)
		if not projectFolder then
			local startFolder = fileUtil.splitFilepath(filepath)
			local msg = "This scene is flagged to use project-local paths, "..
				"but we couldn't find the project file that it's associated with.\n\n"..
				"Searched all folders from '"..startFolder.."' and up.\n\n"..
				"Will fall back to using scene-local paths."
			editor.messageBox(msg, "Export Warning: Failed to find project")
		else
			relFilepathFolder = projectFolder
		end
	end

	options = options or M.defaultOptions
	local data = copyChildrenData(scene.children, options, relFilepathFolder)
	data.isSceneFile = true
	data.lastUsedExporter = scene.lastUsedExporter
	if scene.lastExportFilepath then
		data.lastExportFilepath = fileUtil.getRelativePath(relFilepathFolder, scene.lastExportFilepath)
	end
	if #scene.properties > 0 then
		data.properties = copyPropertyData(scene, options.omitUnmodifiedBuiltins, relFilepathFolder)
	end
	local str = "return " .. objToStr(data) .. "\n"
	file:write(str)

	file:close()
end

local function isAbsPath(path)
	return path:match("^[\\/]")
end

local function getPropImportValue(val, name, Class, localFilepath)
	local propType = Class.typeName
	if propType == "file" or propType == "image" or propType == "script" then
		if val ~= "" and not isAbsPath(val) then
			val = fileUtil.resolveRelativePath(localFilepath, val)
		end
	elseif propType == "font" then
		if val[1] ~= "" and not isAbsPath(val[1]) then
			val[1] = fileUtil.resolveRelativePath(localFilepath, val[1])
		end
	end
	return val
end

-- Convert from import data: { type=, name=, value= }
-- To : PropData { name, value, Class }
-- And convert filepaths to global.
local function makeAddPropDatas(importedProperties, localFilepath, isChildSceneObj)
	local propDatas = { isChildSceneObj = isChildSceneObj }
	for i,prop in ipairs(importedProperties) do
		local Class = propClassList:get(prop.type)
		local name = prop.name
		local value = getPropImportValue(prop.value, name, Class, localFilepath)
		local defaultValue, isNonRemovable
		if isChildSceneObj then
			defaultValue, isNonRemovable = value, true
		end
		table.insert(propDatas, PropData(name, value, Class, defaultValue, nil, isNonRemovable))
	end
	return propDatas
end

local function makeAddObjData(scene, objData, parentEnclosure, localFilepath, isChildSceneObj)
	local Class = classList:get(objData.class)
	local enclosure = {}
	local properties
	local children
	if Class == ChildScene then
		local modsData = objData.properties
		local mods = { isChildSceneObj = isChildSceneObj }
		if modsData.rootProperties then
			mods.rootProperties = makeAddPropDatas(modsData.rootProperties, localFilepath, isChildSceneObj)
		end
		mods.childProperties = {}
		if mods.childProperties then
			for id,propData in pairs(modsData.childProperties) do
				mods.childProperties[id] = makeAddPropDatas(propData, localFilepath)
			end
		end

		local scenePath = fileUtil.resolveRelativePath(localFilepath, objData.sceneFilepath)
		mods.sceneFilepath = scenePath
		local _, addRootObjDatas, scenePropDatas = M.import(scenePath, nil, enclosure, scene, true)
		children = addRootObjDatas
		-- TODO: Need to add ChildScene's ID to the map.
		local sceneEnclosureIDMap, objDataIDMap = ChildScene.recursiveMapEncIDs(addRootObjDatas)
		mods.sceneEnclosureIDMap = sceneEnclosureIDMap

		if objData.properties.addedObjects then
			for parentID,addedObjs in pairs(modsData.addedObjects) do
				local parentAddObjData = objDataIDMap[parentID]
				if parentAddObjData then
					if not parentAddObjData.children then
						parentAddObjData.rawset("children", {})
					end
					local parentEnc = parentAddObjData.enclosure
					for i,addedObjData in ipairs(addedObjs) do
						local addObjData = makeAddObjData(scene, addedObjData, parentEnc, localFilepath, isChildSceneObj)
						table.insert(parentAddObjData.children, addObjData)
					end
				else
					print("didn't find parent data for ID: "..parentID.." for added scene objects.")
				end
			end
		end
		properties = mods
	else
		properties = makeAddPropDatas(objData.properties, localFilepath, isChildSceneObj)
	end
	local isSelected = false
	if objData.children then -- ChildScene won't have children saved as such.
		children = {}
		for i,child in ipairs(objData.children) do
			table.insert(children, makeAddObjData(scene, child, enclosure, localFilepath, isChildSceneObj))
		end
	end
	return AddObjData(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
end

local function loadSceneFile(filepath)
	local file, errMsg = io.open(filepath, "r")
	if not file then
		print(errMsg)
		editor.messageBox(errMsg, "Import Failed: Error opening file")
		return
	end

	local str = file:read("*a")
	file:close()

	local isSuccess, result = pcall(loadstring, str)
	if not isSuccess then
		print(result)
		editor.messageBox("Error loading contents of file as lua code: "..tostring(result), "Import Failed: Error loading as lua")
		return
	end

	local isSuccess, data = pcall(result)
	if not isSuccess then
		print(data)
		editor.messageBox(tostring(data), "Import Failed: Error executing loaded lua code")
		return
	end

	if type(data) ~= "table" then
		editor.messageBox("Loaded lua code returns a '"..type(data).."' value instead of a table.", "Import Failed: Invalid scene file")
		return
	end

	if not data.isSceneFile then
		editor.messageBox("Lua module is not flagged as a scene file.", "Import Failed: Invalid scene file")
		return
	end
	return data
end

function M.import(filepath, options, parentEnc, scene, isChildSceneObj)
	options = options or {}
	print("IMPORT: "..filepath, scene)
	if parentEnc then  assert(scene, "Import - No scene given. Must also give a scene if a parent enclosure is given.")  end

	local data = loadSceneFile(filepath)
	if not data then  return  end

	local addObjDatas = {}
	local _, filename = fileUtil.splitFilepath(filepath)
	if not parentEnc then  print("   creating new scene") scene = scenes.create(filename, filepath)  end
	local relFilepathFolder = filepath

	local useProjectPaths
	if data.properties then
		for i,prop in ipairs(data.properties) do
			if prop.name == "useProjectLocalPaths" then
				useProjectPaths = prop.value
			end
		end
	end
	if useProjectPaths then
		local projectFolder = fileUtil.findProject(filepath, config.projectFileExtension)
		if not projectFolder then
			local startFolder = fileUtil.splitFilepath(filepath)
			local msg = "This scene is flagged to use project-local paths, "..
				"but we couldn't find the project file that it's associated with.\n\n"..
				"Searched all folders from '"..startFolder.."' and up.\n\n"..
				"Will try to interpret paths as scene-local."
			editor.messageBox(msg, "Import Warning: Failed to find project")
		else
			relFilepathFolder = projectFolder
			requirePath.prepend(projectFolder) -- Need to do this before loading other properties & objects.
		end
	end

	if not parentEnc then
		scene.lastUsedExporter = data.lastUsedExporter
		if data.lastExportFilepath then
			scene.lastExportFilepath = fileUtil.resolveRelativePath(relFilepathFolder, data.lastExportFilepath)
		end
	end

	local scenePropDatas

	if data.properties then
		scenePropDatas = makeAddPropDatas(data.properties, relFilepathFolder)
		if scenePropDatas and not parentEnc then
			-- Add scene properties to new scene.
			local enclosure = scene.enclosure
			local obj = enclosure[1]
			for i,propData in ipairs(scenePropDatas) do
				if obj:hasProperty(propData.name) then
					obj:setProperty(propData)
				else
					propFn.addProperty(enclosure, propData)
				end
			end
		end
	end

	-- Just need to add the objects at the base level, any children will be added along with.
	for i,objData in ipairs(data) do
		if not objData.class then
			editor.messageBox("Error parsing objects: No object class property found.", "Import Failed: Invalid object")
			return
		end
		local parentEnc = parentEnc or scene.enclosure
		local isSuccess, result = pcall(makeAddObjData, scene, objData, parentEnc, relFilepathFolder, isChildSceneObj)
		if not isSuccess then
			print(result)
			editor.messageBox("Error creating command args for creating scene objects: "..tostring(result), "Import Failed: Invalid object")
			return
		else
			table.insert(addObjDatas, result)
		end
	end

	if not parentEnc then
		objectFn.addObjects(scene, addObjDatas)
	end

	return scene, addObjDatas, scenePropDatas
end

return M
