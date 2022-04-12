
local selectionCommands = require "commands.selection-commands"

local commands = {}

for k,v in pairs(selectionCommands) do
	commands[k] = v
end

return commands
