
local M = {}

function M.add(scene, Class, enclosure, properties, isSelected)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	if properties then
		for name,values in pairs(properties) do
			object:setProperty(name, unpack(values))
		end
	end

	scene:add(object)

	if isSelected then
		scene.selection:add(enclosure)
	end

	return scene, enclosure
end

function M.delete(scene, enclosure)
	local object = enclosure[1]
	local properties = object:getModifiedProperties() or false
	local isSelected = object.isSelected
	if isSelected then
		scene.selection:remove(enclosure)
	end
	object.tree:remove(object)
	local Class = getmetatable(object)
	return scene, Class, enclosure, properties, isSelected
end

function M.setProperty(enclosure, name, ...)
	local object = enclosure[1]
	local oldValues = { object:getProperty(name) }
	object:setProperty(name, ...)
	return enclosure, name, unpack(oldValues)
end

function M.setPropertyOnMultiple(argList)
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
