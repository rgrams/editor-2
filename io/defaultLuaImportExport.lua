
local M = {}

local objToStr = require "philtre.lib.object-to-string"
local objectFn = require "commands.functions.object-functions"
local classList = require "objects.class-list"

local function copyChildrenData(children)
	local output = {}
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			-- Copy object data:
			local data = {}
			local Class = getmetatable(child)
			data.class = Class.displayName
			for _,property in ipairs(child.properties) do
				data[property.name] = property:getValue()
			end
			if child.children then
				data.children = copyChildrenData(child.children)
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

	options = options or {}
	local data = copyChildrenData(scene.children, options)
	local str = "return " .. objToStr(data) .. "\n"
	file:write(str)

	file:close()
end

local function makeAddObjArgs(scene, obj, parentEnclosure)
	local Class = classList.get(obj.class)
	local enclosure = {}
	local properties = {}
	for name,value in pairs(obj) do
		if name ~= "class" and name ~= "children" then
			properties[name] = value
		end
	end
	local isSelected = false
	local children
	if obj.children then
		children = {}
		for i,child in ipairs(obj.children) do
			table.insert(children, makeAddObjArgs(scene, child, enclosure))
		end
	end
	return { scene, Class, enclosure, properties, isSelected, parentEnclosure, children }
end

function M.import(scene, filepath, options)
	options = options or {}
	print("----  IMPORT  ----")
	print("   "..filepath)
	local file, errMsg = io.open(filepath, "r")
	if not file then
		print("error", errMsg)
		return
	end

	local str = file:read("*a")
	file:close()

	local isSuccess, result = pcall(loadstring, str)
	if not isSuccess then
		print(result)
		return
	end
	local data = result()

	local argsList = {}

	-- Just need to add the objects at the base level, any children will be added along with.
	for i,obj in ipairs(data) do
		table.insert(argsList, makeAddObjArgs(scene, obj, false))
	end

	local existingEnclosures = {}
	for i,child in ipairs(scene.children) do
		table.insert(existingEnclosures, child.enclosure)
	end
	scene.history:perform("deleteObjects", scene, existingEnclosures)

	scene.history:perform("addObjects", scene, argsList)
	-- objectFn.addObjects(scene, argsList)
end

return M
