
local scenes = require "core.scenes"
local signals = require "core.signals"

local function undo()
	local past = scenes.active.history.past
	local cmd = past[#past] -- { name, doArgs, undoArgs }
	if cmd then
		local undoArgs = cmd[3]
		undoArgs[1] = editor.UI -- Set caller to ourself.
		scenes.active.history:undo()
		signals.send("undo", editor.UI, cmd)
		return true
	end
end

local function redo()
	local future = scenes.active.history.future
	local cmd = future[#future]
	if cmd then
		local redoArgs = cmd[2]
		redoArgs[1] = editor.UI -- Set caller to ourself.
		scenes.active.history:redo()
		signals.send("redo", editor.UI, cmd)
		return true
	end
end


editor.registerAction("undo", undo)
editor.registerAction("redo", redo)
editor.bindActionToInput("undo", "undo", editor.UI, true)
editor.bindActionToInput("redo", "redo", editor.UI, true)
