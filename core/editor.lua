
-- Editor namespace for plugins to use.
-- Set as global `editor` in main.lua.

local M = {}

local MessageBox = require "core.ui.dialogs.MessageBox"
local MultiChoiceBox = require "core.ui.dialogs.MultiChoiceBox"

-- Object references. Set in love.load and UI.set.
M.Tree = nil   -- Editor SceneTree
M.Window = nil
M.UI = nil
M.Viewport = nil
M.PropertyPanel = nil

function M.messageBox(msg, title, x, y)
	local msgBox = MessageBox(msg, title, x, y)
	M.Tree:add(msgBox, M.Window)
end

-- WARNING: `msg` currently ignored.
function M.multipleChoiceBox(choices, callback, title, msg, x, y)
	local box = MultiChoiceBox(choices, callback, title, msg, x, y)
	M.Tree:add(box, M.Window)
end

local function errStr(fnName, ...)
	local str = "editor."..fnName.."("
	local args = {...}
	for i,arg in ipairs(args) do
		str = str .. "'"..tostring(arg).."', "
	end
	if #args > 0 then  str = str:sub(1, -3)  end
	return str .. ") - "
end

local actions = {}

function M.registerAction(name, fn)
	if actions[name] then
		print(errStr("registerAction", name, "...") .. "Overwriting existing action.")
	end
	actions[name] = fn
end

function M.unregisterAction(name, fn)
	if actions[name] == fn then
		actions[name] = nil
	else
		if actions[name] then
			error(errStr("unregisterAction", name, fn) .. "Registered action function does not match.")
		else
			error(errStr("unregisterAction", name, "...") .. "No action registered with that name.")
		end
	end
end

function M.runAction(name, ...)
	local fn = actions[name]
	if fn then
		fn(...)
	else
		error(errStr("runAction", name) .. "No action registered with that name.")
	end
end

-- TODO:
function M.addActionToMenu(name, menu, args, text)
	assert(actions[name], errStr("addActionToMenu", name, menu, "...") .. "No action registered with that name.")
	text = text or name
	local menuItem = { text = text, fn = actions[name], args = args }
	-- TODO: Get menu list (check if it exists)
	--       Add item to menu.
	--          Add another argument for placement. ('before', 'after', index)
	--             A table of arguments?
end

local inputMaps = {}

-- Called by context objects (UI, Viewport, PropertyPanel) when they are initialized.
function M._registerInputContext(context)
	local map = { _doActionOnKeyRepeat = {} }
	inputMaps[context] = map
	return map
end

function M.bindActionToInput(name, input, context, doActionOnKeyRepeat)
	assert(actions[name], errStr("bindActionToInput", name, "...") .. "No action registered with that name.")
	context = context or M.UI
	local map = inputMaps[context]
	assert(map, errStr("bindActionToInput", name, input, context) .. "No input map found for context object.")
	map[input] = name
	map._doActionOnKeyRepeat[input] = doActionOnKeyRepeat
end

function M.unBindActionFromInput(name, input, context)
	context = context or M.UI
	local map = inputMaps[context]
	assert(map, errStr("bindActionToInput", name, input, context) .. "No input map found for context object.")
	if actions[name] and map[input] then
		assert(map[input] == name, errStr("bindActionToInput", name, input, context) .. "Bound action doesn't match the action-name given.")
	end
	map[input] = nil
	map._doActionOnKeyRepeat[input] = nil
end

function M.handleInputsForMap(inputMap, action, value, change, rawChange, isRepeat, ...)
	if (change == 1) or (isRepeat and inputMap._doActionOnKeyRepeat[action]) then
		local editorAction = inputMap[action]
		if editorAction then  return M.runAction(editorAction)  end
	end
end

-- M.makePluginObject()
-- M.removePluginObject()

return M
