
local signals = require "core.signals"
local propFn = require "core.commands.functions.property-functions"
local propCmd = require "core.commands.property-commands"
local PropData = require "core.commands.data.PropData"

-- removeSamePropertyFromMultiple(caller, enclosures, name)

local Script = require "core.objects.properties.Script"

local function addShapeDrawingScript(caller, enclosures)
	local oneWasSelected = false
	local scriptPath = love.filesystem.getRealDirectory("core/objects/scripts/drawn-shape.lua")
	scriptPath = scriptPath .. "/core/objects/scripts/drawn-shape.lua"
	local propName = "drawScript"
	for i,enclosure in ipairs(enclosures) do
		local propData = PropData(propName, scriptPath, Script)
		local enc, name, wasSelected = propFn.addProperty(enclosure, propData)
		oneWasSelected = oneWasSelected or wasSelected
	end
	if oneWasSelected then
		local scene = enclosures[1][1].tree
		signals.send("selected objects modified", caller, scene)
	end
	return caller, enclosures, propName
end

return {
	addShapeDrawingScript = { addShapeDrawingScript, propCmd.removeSamePropertyFromMultiple[1] }
}
