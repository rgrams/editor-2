local M = {}

local objToStr = require "philtre.lib.object-to-string"
local fileUtil = require "lib.file-util"
local config = require "config"
local ChildScene = require "objects.ChildScene"

_G.exporterList:add(M, "lua export for runtime")

local indent = "\t"

local isLuaKeyword = {
	["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
	["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
	["function"] = true, ["goto"] = true, ["if"] = true, ["in"] = true,
	["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
	["repeat"] = true, ["return"] = true, ["then"] = true,
	["true"] = true, ["until"] = true, ["while"] = true
}

-- Temp variables for each export.
local _file
local _curIndentLvl = 0
local _curIndent = ""

local function resetIndent()
	_curIndentLvl = 0
	_curIndent = ""
end

local function addIndent()
	_curIndentLvl = _curIndentLvl + 1
	_curIndent = indent:rep(_curIndentLvl)
end

local function removeIndent()
	_curIndentLvl = _curIndentLvl - 1
	_curIndent = indent:rep(_curIndentLvl)
end

local function write(str)
	_file:write(_curIndent .. str)
end

local function validKeyStr(k)
	if isLuaKeyword[k] then  return '["' .. k .. '"]'  end
	local t = type(k)
	if t == "number" then  return "[" .. k .. "]"
	elseif t == "string" then
		if string.match(k, "^[%a_][%w_]*") then  return k
		else  return '["' .. k .. '"]'  end
	end
	return k
end

local function openBlock(key)
	if key then  write(validKeyStr(key) .. " = {\n")
	else         write("{\n")  end
	addIndent()
end

local function closeBlock(omitComma)
	removeIndent()
	if omitComma then  write("}\n")
	else               write("},\n")  end
end

M.defaultOptions = {
	omitUnmodifiedBuiltins = true
}

local Float = require "objects.properties.Property"
local String = require "objects.properties.String"
local Vec2 = require "objects.properties.Vec2"
local split = require "lib.string-split"

local function writePropExportValue(prop, filepath)
	local val = prop:copyValue()
	local name = prop.name
	local propType = prop.typeName
	if name == "scene" and propType == "file" then
		if val ~= "" then
			local origVal = val
			val = fileUtil.getRelativePath(filepath, val)
			local _, _, ext = fileUtil.splitFilepath(val)
			if ext == ".lua" then
				val = fileUtil.toRequirePath(val)

				-- If the child-scene has a last-export-path, export that as well.
				-- WARNING: Assumes all filepaths are project-relative.
				local sceneModule = fileUtil.loadLuaFromAbsolutePath(origVal)
				if sceneModule and sceneModule.lastExportFilepath then
					local exPath = sceneModule.lastExportFilepath
					exPath = fileUtil.toRequirePath(exPath)
					write("exportedScene = "..objToStr(exPath)..",\n")
				end
			end
		end
	elseif propType == "file" or propType == "image" or propType == "script" then
		if val ~= "" then
			val = fileUtil.getRelativePath(filepath, val)
			local _, _, ext = fileUtil.splitFilepath(val)
			if ext == ".lua" then
				val = fileUtil.toRequirePath(val)
			end
		end
	elseif propType == "font" then
		if val[1] ~= "" then
			val[1] = fileUtil.getRelativePath(filepath, val[1])
		end
	elseif (name == "categories" or name == "mask") and prop:is(String) then
		if val == "" then  return  end
		val = split(val, ", ")
	elseif (name == "pos" or name == "scale" or name == "skew") and prop:is(Vec2) then
		local key1, key2
		if name == "pos" then  key1, key2 = "x", "y"
		elseif name == "scale" then  key1, key2 = "sx", "sy"
		elseif name == "skew" then  key1, key2 = "kx", "ky"  end
		write(key1.." = "..val.x..", "..key2.." = "..val.y..",\n")
		return
	elseif name == "angle" and prop:is(Float) then
		val = math.rad(val)
	end
	write(name.." = "..objToStr(val)..",\n")
end

local function writePropertyData(child, omitUnmod, filepath, isSceneObj)
	local nonBuiltinProps
	for _,prop in ipairs(child.properties) do
		if prop.isClassBuiltin then
			if not (omitUnmod and prop:isAtDefault(isSceneObj and prop.sceneDefault)) then
				writePropExportValue(prop, filepath)
			end
		elseif not (isSceneObj and prop.isNonRemovable and prop:isAtDefault(prop.sceneDefault)) then
			nonBuiltinProps = nonBuiltinProps or {}
			table.insert(nonBuiltinProps, prop)
		end
	end
	if nonBuiltinProps then
		openBlock("properties")
		for _,prop in ipairs(nonBuiltinProps) do
			writePropExportValue(prop, filepath)
		end
		closeBlock()
	end
end

local function hasSceneModifications(obj, omitUnmod)
	for _,prop in ipairs(obj.properties) do
		if not (omitUnmod and prop.isNonRemovable and prop:isAtDefault(prop.sceneDefault)) then
			return true
		end
	end
end

local function writeChildrenData(children, options, filepath)
	local output = {}
	local omitUnmod = options.omitUnmodifiedBuiltins
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			openBlock()

			local Class = getmetatable(child)
			write("class = \""..Class.displayName.."\",\n")
			writePropertyData(child, omitUnmod, filepath)

			if Class == ChildScene then
				openBlock("sceneObjProperties")
				for id,enclosure in pairs(child.sceneObjectIDMap) do
					local obj = enclosure[1]
					if hasSceneModifications(obj, omitUnmod) then
						openBlock(id)
						writePropertyData(obj, omitUnmod, filepath, true)
						closeBlock()
					end
				end
				closeBlock()
			else
				if child.children and child.children.maxn > 0 then
					openBlock("children")
					writeChildrenData(child.children, options, filepath)
					closeBlock(true)
				end
			end

			closeBlock()
		end
	end
	return output
end

function M.export(scene, filepath, options)
	print("----  EXPORT - LUA  ----")
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

	_file = file
	resetIndent()
	options = options or M.defaultOptions

	write("return {\n")
	addIndent()

	write("isSceneFile = true,\n")

	if #scene.properties > 0 then
		local omitUnmod = false
		writePropertyData(scene, omitUnmod, relFilepathFolder)
	end

	openBlock("objects")
	writeChildrenData(scene.children, options, relFilepathFolder)
	closeBlock()

	closeBlock(true)
	file:close()
end

return M
