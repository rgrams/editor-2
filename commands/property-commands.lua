
local propFn = require "commands.functions.property-functions"
local signals = require "signals"

local function setProperty(caller, ...)
	local _, enclosure, name, oldValue, oneWasSelected = propFn.setProperty(caller, ...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, name, oldValue, oneWasSelected
end

local function setSamePropertyOnMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.setSamePropertyOnMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function setMultiPropertiesOnMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.setMultiPropertiesOnMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function offsetVec2PropertyOnMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.offsetVec2PropertyOnMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function addProperty(caller, ...)
	local _, enclosure, name, oneWasSelected = propFn.addProperty(caller, ...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, name, oneWasSelected
end

local function removeProperty(caller, ...)
	local _, enclosure, Class, name, value, oneWasSelected = propFn.removeProperty(caller, ...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, Class, name, value, oneWasSelected
end

local function addSamePropertyToMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.addSamePropertyToMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function addPropertyToMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.addPropertyToMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function removeSamePropertyFromMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.removeSamePropertyFromMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function removePropertyFromMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.removePropertyFromMultiple(caller, ...)
	if oneWasSelected then
		local enclosure = undoArgList[1][2]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

return {
	setProperty = { setProperty, setProperty },
	setSamePropertyOnMultiple = { setSamePropertyOnMultiple, setMultiPropertiesOnMultiple },
	setMultiPropertiesOnMultiple = { setMultiPropertiesOnMultiple, setMultiPropertiesOnMultiple },
	offsetVec2PropertyOnMultiple = { offsetVec2PropertyOnMultiple, setMultiPropertiesOnMultiple },
	addProperty = { addProperty, removeProperty },
	removeProperty = { removeProperty, addProperty },
	addPropertyToMultiple = { addPropertyToMultiple, removePropertyFromMultiple },
	addSamePropertyToMultiple = { addSamePropertyToMultiple, removePropertyFromMultiple },
	removeSamePropertyFromMultiple = { removeSamePropertyFromMultiple, addPropertyToMultiple },
	removePropertyFromMultiple = { removePropertyFromMultiple, addPropertyToMultiple },
}
