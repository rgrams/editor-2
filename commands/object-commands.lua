
local Obj = require "commands.functions.object-functions"

local function deleteObjects(caller, scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { Obj.delete(caller, scene, enclosure) }
		table.insert(undoArgs, args)
	end
	return caller, scene, undoArgs
end

local function cut(caller, scene, enclosures)
	local _, _, undoArgs = deleteObjects(caller, scene, enclosures)
	_G.scene_clipboard = undoArgs
	return caller, scene, undoArgs
end

return {
	addObject = { Obj.add, Obj.delete },
	deleteObject = { Obj.delete, Obj.add },
	addObjects = { Obj.addObjects, deleteObjects },
	deleteObjects = { deleteObjects, Obj.addObjects },
	addObjectToMultiple = { Obj.addToMultiple, deleteObjects },
	setProperty = { Obj.setProperty, Obj.setProperty },
	setSamePropertyOnMultiple = { Obj.setSamePropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
	setMultiPropertiesOnMultiple = { Obj.setMultiPropertiesOnMultiple, Obj.setMultiPropertiesOnMultiple },
	offsetVec2PropertyOnMultiple = { Obj.offsetVec2PropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
	cut = { cut, Obj.addObjects },
	paste = { Obj.paste, deleteObjects },
	addProperty = { Obj.addProperty, Obj.removeProperty },
	removeProperty = { Obj.removeProperty, Obj.addProperty },
	addPropertyToMultiple = { Obj.addPropertyToMultiple, Obj.removePropertyFromMultiple },
	addSamePropertyToMultiple = { Obj.addSamePropertyToMultiple, Obj.removePropertyFromMultiple },
	removeSamePropertyFromMultiple = { Obj.removeSamePropertyFromMultiple, Obj.addPropertyToMultiple },
	removePropertyFromMultiple = { Obj.removePropertyFromMultiple, Obj.addPropertyToMultiple },
}
