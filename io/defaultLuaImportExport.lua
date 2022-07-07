
local M = {}

local objToStr = require "philtre.lib.object-to-string"
local fileUtil = require "lib.file-util"
local classList = _G.objClassList
local propClassList = _G.propClassList

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
		if omitUnmod and prop.isNonRemovable and prop:isAtDefault() then
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
			data.properties = copyPropertyData(child, omitUnmod, filepath)
			if child.children then
				data.children = copyChildrenData(child.children, options, filepath)
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
		print(errMsg)
		return
	end

	options = options or M.defaultOptions
	local data = copyChildrenData(scene.children, options, filepath)
	data.isSceneFile = true
	if #scene.properties > 0 then
		data.properties = copyPropertyData(scene, options.omitUnmodifiedBuiltins, filepath)
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

local function makeAddPropArgs(obj, filepath)
	local properties = {}
	for i,prop in ipairs(obj.properties) do
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

local function makeAddObjArgs(caller, scene, obj, parentEnclosure, filepath)
	local Class = classList:get(obj.class)
	local enclosure = {}
	local properties = makeAddPropArgs(obj, filepath)
	local isSelected = false
	local children
	if obj.children then
		children = {}
		for i,child in ipairs(obj.children) do
			table.insert(children, makeAddObjArgs(caller, scene, child, enclosure, filepath))
		end
	end
	return { caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children }
end

function M.import(scene, filepath, options)
	options = options or {}
	print("----  IMPORT  ----")
	print("   "..filepath)
	local file, errMsg = io.open(filepath, "r")
	if not file then
		print("Error opening file", errMsg)
		return
	end

	local str = file:read("*a")
	file:close()

	local isSuccess, result = pcall(loadstring, str)
	if not isSuccess then
		print("Error loading contents of file as lua code", result)
		return
	end

	local isSuccess, data = pcall(result)
	if not isSuccess then
		print("Error executing loaded lua code: "..tostring(data))
		return
	end

	if not data.isSceneFile then
		print("Lua module is not flagged as a scene file.")
		return
	end

	local addArgsList = {}
	local addPropsList
	local caller = false

	if data.properties then
		addPropsList = makeAddPropArgs(data, filepath)
	end

	-- Just need to add the objects at the base level, any children will be added along with.
	for i,obj in ipairs(data) do
		if not obj.class then
			print("   Error parsing objects: No object class property found.")
			return
		end
		local isSuccess, result = pcall(makeAddObjArgs, caller, scene, obj, false, filepath)
		if not isSuccess then
			print("   Error creating command args for creating scene objects: "..tostring(result)..".")
			return
		else
			table.insert(addArgsList, result)
		end
	end

	return addArgsList, addPropsList
end

return M
