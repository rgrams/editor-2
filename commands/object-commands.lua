
local Obj = require "commands.functions.object-functions"

local function addObjects(scene, argsList)
	local enclosures = {}
	for i,args in ipairs(argsList) do
		local _,enclosure = Obj.add(scene, unpack(args))
		table.insert(enclosures, enclosure)
	end
	return scene, enclosures
end

local function deleteObjects(scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local _, Class, enc, prop, isSelected = Obj.delete(scene, enclosure)
		table.insert(undoArgs, { Class, enc, prop, isSelected })
	end
	return scene, undoArgs
end

return {
	addObject = { Obj.add, Obj.delete },
	deleteObject = { Obj.delete, Obj.add },
	addObjects = { addObjects, deleteObjects },
	deleteObjects = { deleteObjects, addObjects },
	setProperty = { Obj.setProperty, Obj.setProperty },
	setPropertyOnMultiple = { Obj.setPropertyOnMultiple, Obj.setPropertyOnMultiple },
	offsetPropertyOnMultiple = { Obj.offsetPropertyOnMultiple, Obj.setPropertyOnMultiple },
}
