
local M = {}

local objToStr = require "philtre.lib.object-to-string"
local fileUtil = require "lib.file-util"
local scenes = require "scenes"
local objectFn = require "commands.functions.object-functions"
local classList = _G.objClassList
local propClassList = _G.propClassList
local config = require "config"
local ChildScene = require "objects.ChildScene"

M.defaultOptions = {
	omitUnmodifiedBuiltins = true
}

local function getPropExportValue(prop, filepath)
	local val = prop:copyValue()
	local propType = prop.typeName
	if propType == "file" or propType == "image" or propType == "script" then
		if val ~= "" then
			val = fileUtil.getRelativePath(filepath, val)
		end
	elseif propType == "font" then
		if val[1] ~= "" then
			val[1] = fileUtil.getRelativePath(filepath, val[1])
		end
	end
	return val
end

local function copyPropertyData(child, omitUnmod, filepath)
	local properties = {}
	for _,prop in ipairs(child.properties) do
		if omitUnmod and prop.isNonRemovable and prop:isAtDefault(prop.sceneDefault) then
			-- skip
		else
			local pData = {
				name = prop.name,
				value = getPropExportValue(prop, filepath),
				type = prop.typeName
			}
			table.insert(properties, pData)
		end
	end
	return properties
end

local function copyChildrenData(children, options, filepath)
	local output = {}
	local omitUnmod = options.omitUnmodifiedBuiltins
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			-- Copy object data:
			local data = {}
			local Class = getmetatable(child)
			data.class = Class.displayName
			if Class == ChildScene then
				local childProperties = {}
				for id,enclosure in pairs(child.sceneObjectIDMap) do
					local obj = enclosure[1]
					local props = copyPropertyData(obj, omitUnmod, filepath)
					if #props > 0 then
						childProperties[id] = props
					end
				end
				-- TODO: Get deleted objects.
				--   Check each object in the ID map to see if it still exists.
				-- TODO: Get added objects.
				--   Loop recursively through all objects and store the ones that aren't in the ID map.
				local mods = {
					rootProperties = copyPropertyData(child, omitUnmod, filepath),
					childProperties = childProperties
				}
				data.properties = mods
			else
				data.properties = copyPropertyData(child, omitUnmod, filepath)
				if child.children then
					data.children = copyChildrenData(child.children, options, filepath)
				end
			end
			table.insert(output, data)
		end
	end
	return output
end

function M.export(scene, filepath, options)
	print("----  EXPORT  ----")
	print("   "..filepath)
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

local function getPropImportValue(val, name, Class, filepath)
	local propType = Class.typeName
	if propType == "file" or propType == "image" or propType == "script" then
		if val ~= "" and not isAbsPath(val) then
			val = fileUtil.resolveRelativePath(filepath, val)
		end
	elseif propType == "font" then
		if val[1] ~= "" and not isAbsPath(val[1]) then
			val[1] = fileUtil.resolveRelativePath(filepath, val[1])
		end
	end
	return val
end

-- Convert from data: { type=, name=, value= }
-- To : { name, value, Class }
-- And convert filepaths to global.
local function makeAddPropArgs(propDataList, filepath)
	local properties = {}
	for i,prop in ipairs(propDataList) do
		local PropertyClass = propClassList:get(prop.type)
		local name, value = prop.name, prop.value
		local propArgs = {
			name,
			getPropImportValue(value, name, PropertyClass, filepath),
			PropertyClass
		}
		table.insert(properties, propArgs)
	end
	return properties
end

local function makeAddObjArgs(caller, scene, objData, parentEnclosure, filepath)
	local Class = classList:get(objData.class)
	local enclosure = {}
	local properties
	if Class == ChildScene then
		local modsData = objData.properties
		local mods = {}
		if modsData.rootProperties then
			mods.rootProperties = makeAddPropArgs(modsData.rootProperties, filepath)
		end
		mods.childProperties = {}
		for id,propData in pairs(modsData.childProperties) do
			mods.childProperties[id] = makeAddPropArgs(propData, filepath)
		end
		properties = mods
	else
		properties = makeAddPropArgs(objData.properties, filepath)
	end
	local isSelected = false
	local children
	if objData.children then -- ChildScene won't have children saved as such.
		children = {}
		for i,child in ipairs(objData.children) do
			table.insert(children, makeAddObjArgs(caller, scene, child, enclosure, filepath))
		end
	end
	return { caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children }
end

function M.import(filepath, options, parentEnc)
	options = options or {}
	print("----  IMPORT  ----")
	print("   "..filepath)
	if parentEnc then
		assert(parentEnc[1].tree, "Import - Object in parent enclosure must be in a sceneTree already.")
	end
	local file, errMsg = io.open(filepath, "r")
	if not file then
		editor.messageBox(errMsg, "Import Failed: Error opening file")
		return
	end

	local str = file:read("*a")
	file:close()

	local isSuccess, result = pcall(loadstring, str)
	if not isSuccess then
		editor.messageBox("Error loading contents of file as lua code: "..tostring(result), "Import Failed: Error loading as lua")
		return
	end

	local isSuccess, data = pcall(result)
	if not isSuccess then
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

	local addArgsList = {}
	local addScenePropsList
	local caller = false

	local _, filename = fileUtil.splitFilepath(filepath)
	local scene
	if parentEnc then  scene = parentEnc[1].tree
	else  scene = scenes.create(filename, filepath)  end

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
		end
	end

	if not parentEnc then
		scene.lastUsedExporter = data.lastUsedExporter
		if data.lastExportFilepath then
			scene.lastExportFilepath = fileUtil.resolveRelativePath(relFilepathFolder, data.lastExportFilepath)
		end
	end

	if data.properties then
		addScenePropsList = makeAddPropArgs(data.properties, relFilepathFolder)
		if addScenePropsList then
			local enclosure = parentEnc or scene.enclosure
			local obj = enclosure[1]
			for i,prop in ipairs(addScenePropsList) do
				local name, value, Class = unpack(prop)
				if obj:hasProperty(name) then
					obj:setProperty(name, value)
				else
					objectFn.addProperty(caller, enclosure, Class, name, value)
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
		local isSuccess, result = pcall(makeAddObjArgs, caller, scene, objData, parentEnc, relFilepathFolder)
		if not isSuccess then
			editor.messageBox("Error creating command args for creating scene objects: "..tostring(result), "Import Failed: Invalid object")
			return
		else
			table.insert(addArgsList, result)
		end
	end

	objectFn.addObjects(caller, scene, addArgsList)

	return scene, addArgsList
end

return M
