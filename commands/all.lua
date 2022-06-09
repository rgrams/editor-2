
local selectionCommands = require "commands.selection-commands"
local objectCommands = require "commands.object-commands"
local polygonCommands = require "commands.polygon-commands"

local commands = {}

for k,v in pairs(selectionCommands) do
	commands[k] = v
end
for k,v in pairs(objectCommands) do
	commands[k] = v
end
for k,v in pairs(polygonCommands) do
	commands[k] = v
end

return commands
