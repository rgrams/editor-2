
local M = {}

local id = require "lib.id"
local StringProp = require "objects.properties.String"

function M.add(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	if properties then
		object:applyModifiedProperties(properties)
	end

	scene:add(object, parentEnclosure and parentEnclosure[1])

	local oneWasSelected = isSelected

	if children then
		for i,childData in ipairs(children) do
			local scn, enc, wasSelected = M.add(unpack(childData))
			oneWasSelected = oneWasSelected or wasSelected
		end
	end

	if isSelected then
		scene.selection:add(enclosure)
	end

	return scene, enclosure, oneWasSelected
end

local function deleteChildren(scene, children, isSimulation)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local oneWasSelected = false

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local args = { M.delete(scene, object.enclosure, false, isSimulation) }
			oneWasSelected = oneWasSelected or args[8]
			table.insert(undoArgs, args)
		end
	end
	return undoArgs, oneWasSelected
end

local function dictContainsAncestor(dict, obj)
	local p = obj.parent
	while not dict[p] do
		p = p.parent
		if not p then  return false  end
	end
	return true
end

-- Removes objects from the list if any of their ancestors are also in the list.
function M.removeDescendantsFromList(enclosures)
	local objDict = {} -- Make a dict of the objects to remove for quick checking.
	for i,enclosure in ipairs(enclosures) do
		objDict[enclosure[1]] = true
	end
	for i=#enclosures,1,-1 do
		local obj = enclosures[i][1]
		if dictContainsAncestor(objDict, obj) then
			table.remove(enclosures, i)
		end
	end
end

function M.delete(scene, enclosure, _oneWasSelected, isSimulation)
	local object = enclosure[1]
	local Class = getmetatable(object)
	local properties = object:getModifiedProperties() or false
	local isSelected = object.isSelected
	local oneWasSelected = isSelected
	if isSelected and not isSimulation then
		scene.selection:remove(enclosure)
	end
	if not object.parent then
		print("obj.delete - object has no parent", object)
	end
	local parentEnclosure = object.parent.enclosure or false
	local children, childWasSelected = deleteChildren(scene, object.children, isSimulation)
	oneWasSelected = oneWasSelected or childWasSelected
	if not isSimulation then
		local parent = object.parent
		object.tree:remove(object)
		object:call("wasRemoved", parent)
	end
	return scene, Class, enclosure, properties, isSelected, parentEnclosure, children, oneWasSelected
end

function M.deleteObjects(scene, enclosures)
	local undoArgs = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(scene, enclosure) }
		table.insert(undoArgs, args)
		oneWasSelected = oneWasSelected or args[8]
	end
	return scene, undoArgs, oneWasSelected
end

function M.copy(scene, enclosures)
	local isSimulation = true
	local clipboardData = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(scene, enclosure, false, isSimulation) }
		table.insert(clipboardData, args)
	end
	return clipboardData
end

function M.addToMultiple(scene, parentEnclosures, Class, properties, isSelected, children)
	local newEnclosures = {}
	local oneWasSelected = isSelected
	for i,parentEnclosure in ipairs(parentEnclosures) do
		local scn, enc, wasSelected = M.add(scene, Class, {}, properties, isSelected, parentEnclosure, children)
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(newEnclosures, enc)
	end
	return scene, newEnclosures, oneWasSelected
end

function M.addObjects(scene, argsList)
	local enclosures = {}
	local oneWasSelected = false
	for i,args in ipairs(argsList) do
		local scn, enc, wasSelected = M.add(unpack(args))
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(enclosures, enc)
	end
	return scene, enclosures, oneWasSelected
end

local function setNewIDProp(props)
	for i,prop in ipairs(props) do
		if prop[1] == "id" and prop[3] == StringProp then
			prop[2] = id.new()
			return props
		end
	end
	return props
end

-- Copy to new tables and insert new enclosures and new scene-tree.
function M.copyPasteDataFor(scene, parentEnclosure, childArgList)
	local newArgList = {}
	for i,args in ipairs(childArgList) do
		local newEnclosure = {}
		local newArgs = {}
		newArgs[1] = scene                 -- [1] scene
		newArgs[2] = args[2]               -- [2] Class
		newArgs[3] = newEnclosure          -- [3] enclosure
		newArgs[4] = setNewIDProp(args[4]) -- [4] properties
		newArgs[5] = false                 -- [5] isSelected
		newArgs[6] = parentEnclosure       -- [6] parentEnclosure
		local children = args[7]
		if children then
			newArgs[7] = M.copyPasteDataFor(scene, newEnclosure, children)
		end
		newArgList[i] = newArgs
	end
	return newArgList
end

-- WARNING: Clipboard argsList needs to be copied before it gets put into the history.
function M.paste(scene, parentEnclosures, copiedArgsList)
	local newEnclosures
	local oneWasSelected = false
	if not parentEnclosures then -- Add to scene root.
		local scn, newEncs, wasSelected = M.addObjects(scene, copiedArgsList)
		oneWasSelected = oneWasSelected or wasSelected
		newEnclosures = newEncs
	else
		newEnclosures = {}
		for i,parentEnclosure in ipairs(parentEnclosures) do
			local argsList = i == 1 and copiedArgsList or M.copyPasteDataFor(scene, parentEnclosure, copiedArgsList)
			M.copyPasteDataFor(scene, parentEnclosure, argsList)
			local scn, newEncs, wasSelected = M.addObjects(scene, argsList)
			oneWasSelected = oneWasSelected or wasSelected
			for _,enclosure in ipairs(newEncs) do
				table.insert(newEnclosures, enclosure)
			end
		end
	end
	return scene, newEnclosures, oneWasSelected
end

return M
