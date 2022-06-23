
local M = {}

local objToStr = require "philtre.lib.object-to-string"
local classList = _G.objClassList
local propClassList = _G.propClassList

M.defaultOptions = {
	omitUnmodifiedBuiltins = true
}

local function copyChildrenData(children, options)
	local output = {}
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			-- Copy object data:
			local data = {}
			local Class = getmetatable(child)
			data.class = Class.displayName
			for _,property in ipairs(child.properties) do
				if options.omitUnmodifiedBuiltins and child.isBuiltinProperty[property.name] and property:isAtDefault() then
					-- skip
				else
					data[property.name] = {
						value = property:getValue(),
						type = property.typeName
					}
				end
			end
			if child.children then
				data.children = copyChildrenData(child.children, options)
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
	local data = copyChildrenData(scene.children, options)
	data.isSceneFile = true
	local str = "return " .. objToStr(data) .. "\n"
	file:write(str)

	file:close()
end

local function makeAddObjArgs(caller, scene, obj, parentEnclosure)
	local Class = classList:get(obj.class)
	local enclosure = {}
	local properties = {}
	for name,value in pairs(obj) do
		if name ~= "class" and name ~= "children" then
			local property = value
			local propertyClass = propClassList:get(property.type)
			properties[name] = { property.value, propertyClass }
		end
	end
	local isSelected = false
	local children
	if obj.children then
		children = {}
		for i,child in ipairs(obj.children) do
			table.insert(children, makeAddObjArgs(caller, scene, child, enclosure))
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

	-- if not data.isSceneFile then
		-- print("Lua module is not flagged as a scene file.")
		-- return
	-- end

	local addArgsList = {}
	local caller = false

	-- Just need to add the objects at the base level, any children will be added along with.
	for i,obj in ipairs(data) do
		if not obj.class then
			print("   Error parsing objects: No object class property found.")
			return
		end
		table.insert(addArgsList, makeAddObjArgs(caller, scene, obj, false))
	end

	return addArgsList
end

return M
