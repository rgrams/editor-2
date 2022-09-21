
local selectionCommands = require "core.commands.selection-commands"
local objectCommands = require "core.commands.object-commands"
local propertyCommands = require "core.commands.property-commands"
local polygonCommands = require "core.commands.polygon-commands"
local physicsCommands = require "core.commands.physics-commands"
local miscCommands = require "core.commands.misc-commands"

local commands = {}

for k,v in pairs(selectionCommands) do  commands[k] = v  end
for k,v in pairs(objectCommands) do  commands[k] = v  end
for k,v in pairs(propertyCommands) do  commands[k] = v  end
for k,v in pairs(polygonCommands) do  commands[k] = v  end
for k,v in pairs(physicsCommands) do  commands[k] = v  end
for k,v in pairs(miscCommands) do  commands[k] = v  end

return commands
