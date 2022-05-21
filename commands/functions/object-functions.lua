
local M = {}

function M.add(caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	if properties then
		for name,data in pairs(properties) do
			local value = data[1]
			if not object:hasProperty(name) then
				local PropertyClass = data[2]
				object:addProperty(PropertyClass, name, value)
			else
				object:setProperty(name, value)
			end
		end
	end

	scene:add(object, parentEnclosure and parentEnclosure[1])

	if children then
		for i,childData in ipairs(children) do
			M.add(unpack(childData))
		end
	end

	if isSelected then
		scene.selection:add(enclosure)
	end

	return caller, scene, enclosure
end

local function deleteChildren(caller, scene, children, isSimulation)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local args = { M.delete(caller, scene, object.enclosure, isSimulation) }
			table.insert(undoArgs, args)
		end
	end
	return undoArgs
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

function M.delete(caller, scene, enclosure, isSimulation)
	local object = enclosure[1]
	local Class = getmetatable(object)
	local properties = object:getModifiedProperties() or false
	local isSelected = object.isSelected
	if isSelected and not isSimulation then
		scene.selection:remove(enclosure)
	end
	if not object.parent then
		print("obj.delete - object has no parent", object)
	end
	local parentEnclosure = object.parent.enclosure or false
	local children = deleteChildren(caller, scene, object.children, isSimulation)
	if not isSimulation then
		object.tree:remove(object)
	end
	return caller, scene, Class, enclosure, properties, isSelected, parentEnclosure, children
end

function M.deleteObjects(caller, scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(caller, scene, enclosure) }
		table.insert(undoArgs, args)
	end
	return caller, scene, undoArgs
end

function M.copy(scene, enclosures)
	local isSimulation = true
	local clipboardData = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(false, scene, enclosure, isSimulation) }
		table.insert(clipboardData, args)
	end
	return clipboardData
end

function M.addToMultiple(caller, scene, parentEnclosures, Class, properties, isSelected, children)
	local newEnclosures = {}
	for i,parentEnclosure in ipairs(parentEnclosures) do
		local _, scn, enc = M.add(caller, scene, Class, {}, properties, isSelected, parentEnclosure, children)
		table.insert(newEnclosures, enc)
	end
	return caller, scene, newEnclosures
end

function M.addObjects(caller, scene, argsList)
	local enclosures = {}
	for i,args in ipairs(argsList) do
		local _, scn, enc = M.add(unpack(args))
		table.insert(enclosures, enc)
	end
	return caller, scene, enclosures
end

-- Copy to new tables and insert new enclosures and new scene-tree.
function M.copyPasteDataFor(caller, scene, parentEnclosure, childArgList)
	local newArgList = {}
	for i,args in ipairs(childArgList) do
		local newEnclosure = {}
		local newArgs = {}
		newArgs[1] = caller          -- [1] caller
		newArgs[2] = scene           -- [2] scene
		newArgs[3] = args[3]         -- [3] Class
		newArgs[4] = newEnclosure    -- [4] enclosure
		newArgs[5] = args[5]         -- [5] properties
		newArgs[6] = args[6]         -- [6] isSelected
		newArgs[7] = parentEnclosure -- [7] parentEnclosure
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
	if not parentEnclosures then -- Add to scene root.
		local _, scn, newEncs = M.addObjects(caller, scene, copiedArgsList)
		newEnclosures = newEncs
	else
		newEnclosures = {}
		for i,parentEnclosure in ipairs(parentEnclosures) do
			local argsList = i == 1 and copiedArgsList or M.copyPasteDataFor(caller, scene, parentEnclosure, copiedArgsList)
			M.copyPasteDataFor(caller, scene, parentEnclosure, argsList)
			local _, scn, newEncs = M.addObjects(caller, scene, argsList)
			for _,enclosure in ipairs(newEncs) do
				table.insert(newEnclosures, enclosure)
			end
		end
	end
	return caller, scene, newEnclosures
end

function M.setProperty(caller, enclosure, name, value)
	local object = enclosure[1]
	local property = object:getPropertyObj(name)
	local oldValue
	if property then
		oldValue = property:copyValue()
		object:setProperty(name, value)
	end
	return caller, enclosure, name, oldValue
end

function M.setSamePropertyOnMultiple(caller, enclosures, name, value)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(caller, enclosure, name, value) }
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList
end

function M.setMultiPropertiesOnMultiple(caller, argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.setProperty(unpack(args)) }
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList
end

function M.offsetVec2PropertyOnMultiple(caller, enclosures, name, dx, dy)
	dx, dy = dx or 0, dy or 0
	local undoArgList = {}
	for _,enclosure in ipairs(enclosures) do
		local object = enclosure[1]
		local oldValue = object:getProperty(name)
		local newValue = { x = oldValue.x + dx, y = oldValue.y + dy }
		object:setProperty(name, newValue)
		local undoArgs = { caller, enclosure, name, oldValue }
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList
end

function M.addProperty(caller, enclosure, Class, name, value)
	assert(name, "object-functions.addProperty - `name` can not be nil.")
	local obj = enclosure[1]
	if not Class or obj:getPropertyObj(name) then
		return caller, enclosure, name
	end
	name = enclosure[1]:addProperty(Class, name, value) -- `name` can be nil and the class default is used.
	return caller, enclosure, name
end

function M.removeProperty(caller, enclosure, name)
	local obj = enclosure[1]
	local property = obj:getPropertyObj(name)
	if not property then
		return caller, enclosure
	end
	local value = property:getValue()
	local Class = getmetatable(property)
	obj:removeProperty(name)
	return caller, enclosure, Class, name, value
end

function M.addSamePropertyToMultiple(caller, enclosures, Class, name, value)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.addProperty(caller, enclosure, Class, name, value) }
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList
end

function M.addPropertyToMultiple(caller, argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.addProperty(unpack(args)) }
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList
end

function M.removeSamePropertyFromMultiple(caller, enclosures, name)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.removeProperty(caller, enclosure, name) }
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList
end

function M.removePropertyFromMultiple(caller, argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.removeProperty(unpack(args)) }
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList
end

return M
