
local propFn = require "core.commands.functions.property-functions"
local propCmd = require "core.commands.property-commands"
local PropData = require "core.commands.data.PropData"
local signals = require "core.signals"

local Float = require "core.objects.properties.Property"
local Bool = require "core.objects.properties.Bool"
local String = require "core.objects.properties.String"

local propNames = { "sensor", "friction", "density", "restitution", "categories", "mask"}

local addPropDatas = {
	PropData("sensor", false, Bool),
	PropData("friction", 0.2, Float),
	PropData("density", 1, Float),
	PropData("restitution", 0, Float),
	PropData("categories", "", String),
	PropData("mask", "", String),
}

local function addPhysicsShapeProperties(caller, enclosures)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		for _,propData in ipairs(addPropDatas) do
			local args = { propFn.addProperty(enclosure, propData) }
			table.insert(undoArgList, args)
		end
		oneWasSelected = oneWasSelected or enclosure[1].isSelected
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
		for _,propName in ipairs(propNames) do
			local args = { propFn.removeProperty(enclosure, propName) }
			table.insert(undoArgList, args)
		end
		oneWasSelected = oneWasSelected or enclosure[1].isSelected
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
