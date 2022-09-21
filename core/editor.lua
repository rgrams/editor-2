
-- Editor namespace for plugins to use.
-- Set as global `editor` in main.lua.

local M = {}

local MessageBox = require "core.ui.dialogs.MessageBox"
local MultiChoiceBox = require "core.ui.dialogs.MultiChoiceBox"

M.tree = nil   -- Editor SceneTree reference. set in love.load
M.window = nil -- 'Window' object reference. set in love.load

function M.messageBox(msg, title, x, y)
	local msgBox = MessageBox(msg, title, x, y)
	M.tree:add(msgBox, M.window)
end

-- WARNING: `msg` currently ignored.
function M.multipleChoiceBox(choices, callback, title, msg, x, y)
	local box = MultiChoiceBox(choices, callback, title, msg, x, y)
	M.tree:add(box, M.window)
end

-- M.registerAction()
-- M.unregisterAction()
-- M.runAction()
-- M.makePluginObject()
-- M.removePluginObject()

return M
