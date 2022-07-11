local M = {}

local objToStr = require "philtre.lib.object-to-string"
local fileUtil = require "lib.file-util"

_G.exporterList:add(M, "lua export for runtime")

local indent = "\t"

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

local function writePropertyData(child, omitUnmod, filepath)
	for _,prop in ipairs(child.properties) do
		if omitUnmod and prop.isNonRemovable and prop:isAtDefault() then
			-- skip
		else
			local name = prop.name
			local value = getPropExportValue(prop, filepath)
			write(name.." = "..objToStr(value)..",\n")
		end
	end
end

local function writeChildrenData(children, options, filepath)
	local output = {}
	local omitUnmod = options.omitUnmodifiedBuiltins
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			write("{\n")
			addIndent()

			local Class = getmetatable(child)
			write("class = \""..Class.displayName.."\",\n")
			writePropertyData(child, omitUnmod, filepath)

			if child.children and child.children.maxn > 0 then
				write("children = {\n")
				addIndent()
				writeChildrenData(child.children, options, filepath)
				removeIndent()
				write("}\n")
			end

			removeIndent()
			write("},\n")
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

	_file = file
	resetIndent()
	options = options or M.defaultOptions

	write("return {\n")
	addIndent()

	write("objects = {\n")
	addIndent()
	writeChildrenData(scene.children, options, filepath)
	removeIndent()
	write("},\n")

	-- TODO: write scene properties.
	-- data.isSceneFile = true
	-- if #scene.properties > 0 then
		-- data.properties = copyPropertyData(scene, options.omitUnmodifiedBuiltins, filepath)
	-- end

	removeIndent()
	write("}\n")
	file:close()
end

return M
