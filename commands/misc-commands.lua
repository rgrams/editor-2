
local signals = require "signals"
local propFn = require "commands.functions.property-functions"
local propCmd = require "commands.property-commands"

-- removeSamePropertyFromMultiple(caller, enclosures, name)

local Script = require "objects.properties.Script"

local function addShapeDrawingScript(caller, enclosures)
	local oneWasSelected = false
	local scriptPath = love.filesystem.getRealDirectory("objects/scripts/drawn-shape.lua")
	scriptPath = scriptPath .. "/objects/scripts/drawn-shape.lua"
	local propName = "drawScript"
	for i,enclosure in ipairs(enclosures) do
		local enc, name, wasSelected = propFn.addProperty(enclosure, Script, propName, scriptPath)
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
