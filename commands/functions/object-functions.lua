
local M = {}

function M.add(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	if properties then
		for name,values in pairs(properties) do
			object:setProperty(name, unpack(values))
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

local function deleteChildren(scene, children)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local args = { M.delete(scene, object.enclosure) }
			table.insert(undoArgs, args)
		end
	end
	return undoArgs
end

function M.delete(scene, enclosure)
	local object = enclosure[1]
	local Class = getmetatable(object)
	local properties = object:getModifiedProperties() or false
	local isSelected = object.isSelected
	if isSelected then
		scene.selection:remove(enclosure)
	end
	local parentEnclosure = object.parent.enclosure or false
	local children = deleteChildren(scene, object.children)
	object.tree:remove(object)
	return scene, Class, enclosure, properties, isSelected, parentEnclosure, children
end

function M.setProperty(enclosure, name, ...)
	local object = enclosure[1]
	local oldValues = { object:getProperty(name) }
	object:setProperty(name, ...)
	return enclosure, name, unpack(oldValues)
end

function M.setSamePropertyOnMultiple(enclosures, name, ...)
	local undoArgList = {}
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(enclosure, name, ...) }
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

function M.offsetPropertyOnMultiple(enclosures, name, ...)
	local deltas = { ... }
	local undoArgList = {}
	for _,enclosure in ipairs(enclosures) do
		local object = enclosure[1]
		local oldValues = { object:getProperty(name) }
		local newValues = {}
		for i,oldValue in ipairs(oldValues) do
			newValues[i] = oldValue + deltas[i]
		end
		object:setProperty(name, unpack(newValues))
		local undoArgs = oldValues
		table.insert(undoArgs, 1, name)
		table.insert(undoArgs, 1, enclosure) -- { enclosure, name, ... }
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList
end

return M
