
local Obj = require "commands.functions.object-functions"

local function deleteObjects(scene, enclosures)
	local undoArgs = {}
	for i,enclosure in ipairs(enclosures) do
		local args = { Obj.delete(scene, enclosure) }
		table.insert(undoArgs, args)
	end
	return scene, undoArgs
end

local function cut(scene, enclosures)
	local _, undoArgs = deleteObjects(scene, enclosures)
	_G.scene_clipboard = undoArgs
	return scene, undoArgs
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
	paste = { Obj.paste, deleteObjects }
}
