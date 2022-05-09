
local M = {}

function M.add(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	if properties then
		for name,value in pairs(properties) do
			object:setProperty(name, value)
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

	return scene, enclosure
end

local function deleteChildren(scene, children, isSimulation)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local args = { M.delete(scene, object.enclosure, isSimulation) }
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

function M.delete(scene, enclosure, isSimulation)
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
	local children = deleteChildren(scene, object.children, isSimulation)
	if not isSimulation then
		object.tree:remove(object)
	end
	return scene, Class, enclosure, properties, isSelected, parentEnclosure, children
end

function M.copy(scene, enclosures)
	local isSimulation = true
	local clipboardData = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { M.delete(scene, enclosure, isSimulation) }
		table.insert(clipboardData, args)
	end
	return clipboardData
end

function M.addToMultiple(scene, parentEnclosures, Class, properties, isSelected, children)
	local newEnclosures = {}
	for i,parentEnclosure in ipairs(parentEnclosures) do
		local _, enc = M.add(scene, Class, {}, properties, isSelected, parentEnclosure, children)
		table.insert(newEnclosures, enc)
	end
	return scene, newEnclosures
end

function M.addObjects(scene, argsList)
	local enclosures = {}
	for i,args in ipairs(argsList) do
		local _,enclosure = M.add(unpack(args))
		table.insert(enclosures, enclosure)
	end
	return scene, enclosures
end

-- Copy to new tables and insert new enclosures and new scene-tree.
function M.copyPasteDataFor(scene, parentEnclosure, childArgList)
	local newArgList = {}
	for i,args in ipairs(childArgList) do
		local newEnclosure = {}
		local newArgs = {}
		newArgs[1] = scene           -- [1] scene
		newArgs[2] = args[2]         -- [2] Class
		newArgs[3] = newEnclosure    -- [3] enclosure
		newArgs[4] = args[4]         -- [4] properties
		newArgs[5] = args[5]         -- [5] isSelected
		newArgs[6] = parentEnclosure -- [6] parentEnclosure
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
	if not parentEnclosures then -- Add to scene root.
		local _, newEnc = M.addObjects(scene, copiedArgsList)
		newEnclosures = newEnc
	else
		newEnclosures = {}
		for i,parentEnclosure in ipairs(parentEnclosures) do
			local argsList = i == 1 and copiedArgsList or M.copyPasteDataFor(scene, parentEnclosure, copiedArgsList)
			M.copyPasteDataFor(scene, parentEnclosure, argsList)
			local _, newEnc = M.addObjects(scene, argsList)
			for _,enclosure in ipairs(newEnc) do
				table.insert(newEnclosures, enclosure)
			end
		end
	end
	return scene, newEnclosures
end

function M.setProperty(enclosure, name, value)
	local object = enclosure[1]
	local oldValue = object:getProperty(name)
	object:setProperty(name, value)
	return enclosure, name, oldValue
end

function M.setSamePropertyOnMultiple(enclosures, name, value)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(enclosure, name, value) }
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList
end

function M.setMultiPropertiesOnMultiple(argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.setProperty(unpack(args)) }
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList
end

function M.offsetVec2PropertyOnMultiple(enclosures, name, dx, dy)
	dx, dy = dx or 0, dy or 0
	local undoArgList = {}
	for _,enclosure in ipairs(enclosures) do
		local object = enclosure[1]
		local oldValue = object:getProperty(name)
		local newValue = { x = oldValue.x + dx, y = oldValue.y + dy }
		object:setProperty(name, newValue)
		local undoArgs = { enclosure, name, oldValue }
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList
end

function M.addProperty(enclosure, Class, name)
	name = enclosure[1]:addProperty(Class, name) -- `name` can be nil and the class default is used.
	return enclosure, name
end

function M.removeProperty(enclosure, name)
	local obj = enclosure[1]
	local property = obj:getPropertyObj()
	local Class = getmetatable(property)
	obj:removeProperty(name)
	return enclosure, Class, name
end

function M.addSamePropertyToMultiple(enclosures, Class, name)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.addProperty(enclosure, Class, name) }
		undoArgList[i] = undoArgs
	end
	return undoArgList
end

function M.addPropertyToMultiple(argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.addProperty(unpack(args)) }
		undoArgList[i] = undoArgs
	end
	return undoArgList
end

function M.removePropertyFromMultiple(argList)
	local undoArgList = {}
	for i,args in ipairs(argList) do
		local undoArgs = { M.removeProperty(unpack(args)) }
		undoArgList[i] = undoArgs
	end
	return undoArgList
end

return M
