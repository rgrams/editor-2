
local function addObject(scene, Class, enclosure, properties, isSelected)
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

local function deleteObject(scene, enclosure)
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

local function addObjects(scene, argsList)
	local enclosures = {}
	for i,args in ipairs(argsList) do
		local _,enclosure = addObject(scene, unpack(args))
		table.insert(enclosures, enclosure)
	end
	return scene, enclosures
end

local function deleteObjects(scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local _, Class, enc, prop, isSelected = deleteObject(scene, enclosure)
		table.insert(undoArgs, { Class, enc, prop, isSelected })
	end
	return scene, undoArgs
end

local function setProperty(enclosure, name, ...)
	local object = enclosure[1]
	local oldValues = { object:getProperty(name) }
	object:setProperty(name, ...)
	return enclosure, name, unpack(oldValues)
end

return {
	addObject = { addObject, deleteObject },
	deleteObject = { deleteObject, addObject },
	addObjects = { addObjects, deleteObjects },
	deleteObjects = { deleteObjects, addObjects },
	setProperty = { setProperty, setProperty },
}
