
local M = {}

local id = require "lib.id"
local StringProp = require "objects.properties.String"

function M.add(caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
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
			local _, scn, enc, wasSelected = M.add(unpack(childData))
			oneWasSelected = oneWasSelected or wasSelected
		end
	end

	if isSelected then
		scene.selection:add(enclosure)
	end

	return caller, scene, enclosure, oneWasSelected
end

local function deleteChildren(caller, scene, children, isSimulation)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local oneWasSelected = false

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local args = { M.delete(caller, scene, object.enclosure, false, isSimulation) }
			oneWasSelected = oneWasSelected or args[9]
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

function M.delete(caller, scene, enclosure, _oneWasSelected, isSimulation)
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
	local children, childWasSelected = deleteChildren(caller, scene, object.children, isSimulation)
	oneWasSelected = oneWasSelected or childWasSelected
	if not isSimulation then
		local parent = object.parent
		object.tree:remove(object)
		object:call("wasRemoved", parent)
	end
	return caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children, oneWasSelected
end

function M.deleteObjects(caller, scene, enclosures)
	local undoArgs = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(caller, scene, enclosure) }
		table.insert(undoArgs, args)
		oneWasSelected = oneWasSelected or args[9]
	end
	return caller, scene, undoArgs, oneWasSelected
end

function M.copy(scene, enclosures)
	local isSimulation = true
	local clipboardData = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(false, scene, enclosure, false, isSimulation) }
		table.insert(clipboardData, args)
	end
	return clipboardData
end

function M.addToMultiple(caller, scene, parentEnclosures, Class, properties, isSelected, children)
	local newEnclosures = {}
	local oneWasSelected = isSelected
	for i,parentEnclosure in ipairs(parentEnclosures) do
		local _, scn, enc, wasSelected = M.add(caller, scene, Class, {}, properties, isSelected, parentEnclosure, children)
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(newEnclosures, enc)
	end
	return caller, scene, newEnclosures, oneWasSelected
end

function M.addObjects(caller, scene, argsList)
	local enclosures = {}
	local oneWasSelected = false
	for i,args in ipairs(argsList) do
		local _, scn, enc, wasSelected = M.add(unpack(args))
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(enclosures, enc)
	end
	return caller, scene, enclosures, oneWasSelected
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
function M.copyPasteDataFor(caller, scene, parentEnclosure, childArgList)
	local newArgList = {}
	for i,args in ipairs(childArgList) do
		local newEnclosure = {}
		local newArgs = {}
		newArgs[1] = caller                -- [1] caller
		newArgs[2] = scene                 -- [2] scene
		newArgs[3] = args[3]               -- [3] Class
		newArgs[4] = newEnclosure          -- [4] enclosure
		newArgs[5] = setNewIDProp(args[5]) -- [5] properties
		newArgs[6] = false                 -- [6] isSelected
		newArgs[7] = parentEnclosure       -- [7] parentEnclosure
		local children = args[8]
		if children then
			newArgs[8] = M.copyPasteDataFor(caller, scene, newEnclosure, children)
		end
		newArgList[i] = newArgs
	end
	return newArgList
end

-- WARNING: Clipboard argsList needs to be copied before it gets put into the history.
function M.paste(caller, scene, parentEnclosures, copiedArgsList)
	local newEnclosures
	local oneWasSelected = false
	if not parentEnclosures then -- Add to scene root.
		local _, scn, newEncs, wasSelected = M.addObjects(caller, scene, copiedArgsList)
		oneWasSelected = oneWasSelected or wasSelected
		newEnclosures = newEncs
	else
		newEnclosures = {}
		for i,parentEnclosure in ipairs(parentEnclosures) do
			local argsList = i == 1 and copiedArgsList or M.copyPasteDataFor(caller, scene, parentEnclosure, copiedArgsList)
			M.copyPasteDataFor(caller, scene, parentEnclosure, argsList)
			local _, scn, newEncs, wasSelected = M.addObjects(caller, scene, argsList)
			oneWasSelected = oneWasSelected or wasSelected
			for _,enclosure in ipairs(newEncs) do
				table.insert(newEnclosures, enclosure)
			end
		end
	end
	return caller, scene, newEnclosures, oneWasSelected
end

return M
