
local propFn = require "commands.functions.property-functions"
local propCmd = require "commands.property-commands"
local signals = require "signals"

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local String = require "objects.properties.String"

local function addPhysicsShapeProperties(caller, enclosures)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args
		args = { propFn.addProperty(enclosure, Bool, "sensor", false) }
		table.insert(undoArgList, args)
		args = { propFn.addProperty(enclosure, Float, "friction", 0.2) }
		table.insert(undoArgList, args)
		args = { propFn.addProperty(enclosure, Float, "density", 1) }
		table.insert(undoArgList, args)
		args = { propFn.addProperty(enclosure, Float, "restitution", 0) }
		table.insert(undoArgList, args)
		args = { propFn.addProperty(enclosure, String, "categories", "") }
		table.insert(undoArgList, args)
		args = { propFn.addProperty(enclosure, String, "mask", "") }
		table.insert(undoArgList, args)

		oneWasSelected = oneWasSelected or args[3]
	end
	if oneWasSelected then
		local scene = enclosures[1][1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local function removePhysicsShapeProperties(caller, enclosures)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local args
		args = { propFn.removeProperty(enclosure, "sensor") }
		table.insert(undoArgList, args)
		args = { propFn.removeProperty(enclosure, "friction") }
		table.insert(undoArgList, args)
		args = { propFn.removeProperty(enclosure, "density") }
		table.insert(undoArgList, args)
		args = { propFn.removeProperty(enclosure, "restitution") }
		table.insert(undoArgList, args)
		args = { propFn.removeProperty(enclosure, "categories") }
		table.insert(undoArgList, args)
		args = { propFn.removeProperty(enclosure, "mask") }
		table.insert(undoArgList, args)

		oneWasSelected = oneWasSelected or args[5]
	end
	if oneWasSelected then
		local scene = enclosures[1][1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, undoArgList, oneWasSelected
end

local removePropertyFromMultiple = propCmd.removePropertyFromMultiple[1]
local addPropertyToMultiple = propCmd.addPropertyToMultiple[1]

return {
	addPhysicsShapeProperties = { addPhysicsShapeProperties, removePropertyFromMultiple },
	removePhysicsShapeProperties = { removePhysicsShapeProperties, addPropertyToMultiple },
}
