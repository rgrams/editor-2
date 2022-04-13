
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

return {
	addObject = { addObject, deleteObject },
	deleteObject = { deleteObject, addObject },
}
