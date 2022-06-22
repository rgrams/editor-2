
local objectFn = require "commands.functions.object-functions"
local objectCmd = require "commands.object-commands"
local signals = require "signals"

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local String = require "objects.properties.String"

local function addPhysicsShapeProperties(caller, enclosures)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args
		args = { objectFn.addProperty(caller, enclosure, Bool, "sensor", false) }
		table.insert(undoArgList, args)
		args = { objectFn.addProperty(caller, enclosure, Float, "friction", 0.2) }
		table.insert(undoArgList, args)
		args = { objectFn.addProperty(caller, enclosure, Float, "density", 1) }
		table.insert(undoArgList, args)
		args = { objectFn.addProperty(caller, enclosure, Float, "restitution", 0) }
		table.insert(undoArgList, args)
		args = { objectFn.addProperty(caller, enclosure, String, "categories", "") }
		table.insert(undoArgList, args)
		args = { objectFn.addProperty(caller, enclosure, String, "mask", "") }
		table.insert(undoArgList, args)

		oneWasSelected = oneWasSelected or args[4]
	end
	if oneWasSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, undoArgList, oneWasSelected
end

local function removePhysicsShapeProperties(caller, enclosures)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args
		args = { objectFn.removeProperty(caller, enclosure, "sensor") }
		table.insert(undoArgList, args)
		args = { objectFn.removeProperty(caller, enclosure, "friction") }
		table.insert(undoArgList, args)
		args = { objectFn.removeProperty(caller, enclosure, "density") }
		table.insert(undoArgList, args)
		args = { objectFn.removeProperty(caller, enclosure, "restitution") }
		table.insert(undoArgList, args)
		args = { objectFn.removeProperty(caller, enclosure, "categories") }
		table.insert(undoArgList, args)
		args = { objectFn.removeProperty(caller, enclosure, "mask") }
		table.insert(undoArgList, args)

		oneWasSelected = oneWasSelected or args[6]
	end
	if oneWasSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, undoArgList, oneWasSelected
end

local removePropertyFromMultiple = objectCmd.removePropertyFromMultiple[1]
local addPropertyToMultiple = objectCmd.addPropertyToMultiple[1]

return {
	addPhysicsShapeProperties = { addPhysicsShapeProperties, removePropertyFromMultiple },
	removePhysicsShapeProperties = { removePhysicsShapeProperties, addPropertyToMultiple },
}
