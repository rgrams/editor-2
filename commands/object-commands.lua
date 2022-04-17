
local Obj = require "commands.functions.object-functions"

local function addObjects(scene, argsList)
	local enclosures = {}
	for i,args in ipairs(argsList) do
		local _,enclosure = Obj.add(unpack(args))
		table.insert(enclosures, enclosure)
	end
	return scene, enclosures
end

local function deleteObjects(scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { Obj.delete(scene, enclosure) }
		table.insert(undoArgs, args)
	end
	return scene, undoArgs
end

return {
	addObject = { Obj.add, Obj.delete },
	deleteObject = { Obj.delete, Obj.add },
	addObjects = { addObjects, deleteObjects },
	deleteObjects = { deleteObjects, addObjects },
	addObjectToMultiple = { Obj.addToMultiple, deleteObjects },
	setProperty = { Obj.setProperty, Obj.setProperty },
	setSamePropertyOnMultiple = { Obj.setSamePropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
	setMultiPropertiesOnMultiple = { Obj.setMultiPropertiesOnMultiple, Obj.setMultiPropertiesOnMultiple },
	offsetPropertyOnMultiple = { Obj.offsetPropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
}
