
local signals = require "signals"
local objectFn = require "commands.functions.object-functions"
local objectCmd = require "commands.object-commands"

-- removeSamePropertyFromMultiple(caller, enclosures, name)

local Script = require "objects.properties.Script"

local function addShapeDrawingScript(caller, enclosures)
	local oneWasSelected = false
	local scriptPath = love.filesystem.getRealDirectory("objects/scripts/drawn-shape.lua")
	scriptPath = scriptPath .. "/objects/scripts/drawn-shape.lua"
	print(scriptPath)
	local propName = "drawScript"
	for i,enclosure in ipairs(enclosures) do
		local _, _, _, wasSelected = objectFn.addProperty(caller, enclosure, Script, propName, scriptPath)
		oneWasSelected = oneWasSelected or wasSelected
	end
	if oneWasSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosures, propName
end

return {
	addShapeDrawingScript = { addShapeDrawingScript, objectCmd.removeSamePropertyFromMultiple[1] }
}
