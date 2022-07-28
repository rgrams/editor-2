
local propFn = require "commands.functions.property-functions"
local signals = require "signals"

local function setProperty(caller, ...)
	local enclosure, name, oldValue, oneWasSelected = propFn.setProperty(...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, name, oldValue, oneWasSelected
end

local function setSamePropertyOnMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.setSamePropertyOnMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function setMultiPropertiesOnMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.setMultiPropertiesOnMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function offsetVec2PropertyOnMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.offsetVec2PropertyOnMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function addProperty(caller, ...)
	local enclosure, name, oneWasSelected = propFn.addProperty(...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, name, oneWasSelected
end

local function removeProperty(caller, ...)
	local enclosure, Class, name, value, oneWasSelected = propFn.removeProperty(...)
	if oneWasSelected then
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosure, Class, name, value, oneWasSelected
end

local function addSamePropertyToMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.addSamePropertyToMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function addPropertyToMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.addPropertyToMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function removeSamePropertyFromMultiple(caller, ...)
	local undoArgList, oneWasSelected = propFn.removeSamePropertyFromMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
		local scene = enclosure[1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function removePropertyFromMultiple(caller, ...)
	local _, undoArgList, oneWasSelected = propFn.removePropertyFromMultiple(...)
	if oneWasSelected then
		local enclosure = undoArgList[1][1]
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
