
local Obj = require "commands.functions.object-functions"

return {
	addObject = { Obj.add, Obj.delete },
	deleteObject = { Obj.delete, Obj.add },
	addObjects = { Obj.addObjects, Obj.deleteObjects },
	deleteObjects = { Obj.deleteObjects, Obj.addObjects },
	addObjectToMultiple = { Obj.addToMultiple, Obj.deleteObjects },
	setProperty = { Obj.setProperty, Obj.setProperty },
	setSamePropertyOnMultiple = { Obj.setSamePropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
	setMultiPropertiesOnMultiple = { Obj.setMultiPropertiesOnMultiple, Obj.setMultiPropertiesOnMultiple },
	offsetVec2PropertyOnMultiple = { Obj.offsetVec2PropertyOnMultiple, Obj.setMultiPropertiesOnMultiple },
	cut = { Obj.cut, Obj.addObjects },
	paste = { Obj.paste, Obj.deleteObjects },
	addProperty = { Obj.addProperty, Obj.removeProperty },
	removeProperty = { Obj.removeProperty, Obj.addProperty },
	addPropertyToMultiple = { Obj.addPropertyToMultiple, Obj.removePropertyFromMultiple },
	addSamePropertyToMultiple = { Obj.addSamePropertyToMultiple, Obj.removePropertyFromMultiple },
	removeSamePropertyFromMultiple = { Obj.removeSamePropertyFromMultiple, Obj.addPropertyToMultiple },
	removePropertyFromMultiple = { Obj.removePropertyFromMultiple, Obj.addPropertyToMultiple },
}
