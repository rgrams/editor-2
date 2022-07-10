
-- Editor namespace for plugins to use.
-- Set as global `editor` in main.lua.

local M = {}

local MessageBox = require "ui.dialogs.MessageBox"

M.tree = nil   -- Editor SceneTree reference. set in love.load
M.window = nil -- 'Window' object reference. set in love.load

function M.messageBox(msg, title, x, y)
	local msgBox = MessageBox(msg, title, x, y)
	M.tree:add(msgBox, M.window)
end

-- M.multipleChoiceBox()
-- M.registerAction()
-- M.unregisterAction()
-- M.runAction()
-- M.makePluginObject()
-- M.removePluginObject()

return M
