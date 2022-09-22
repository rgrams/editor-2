
local scenes = require "core.scenes"
local objectFn = require "core.commands.functions.object-functions"

local function cut()
	local scene = scenes.active
	if scene then
		local selection = scene.selection
		if selection[1] then
			local enclosures = selection:copyList()
			objectFn.removeDescendantsFromList(enclosures)
			-- Don't want redo to set the clipboard, so just copy and then perform delete.
			_G.scene_clipboard = objectFn.copy(scene, enclosures)
			scene.history:perform("deleteObjects", editor.Viewport, scene, enclosures)
			return true
		end
	end
end

local function copy()
	local scene = scenes.active
	if scene then
		local selection = scene.selection
		if selection[1] then
			local enclosures = selection:copyList()
			objectFn.removeDescendantsFromList(enclosures)
			_G.scene_clipboard = objectFn.copy(scene, enclosures)
			return true
		end
	end
end

local function paste()
	local scene = scenes.active
	if scene then
		local selection = scene.selection
		if _G.scene_clipboard then
			local parentEnclosures = selection:copyList() or false
			local firstParent = parentEnclosures and parentEnclosures[1] or false
			-- Do NOT want to put the mutable clipboard table into the command history.
			local addObjDatas = objectFn.copyPasteDataFor(scene, firstParent, _G.scene_clipboard)
			scene.history:perform("paste", editor.Viewport, scene, parentEnclosures, addObjDatas)
			return true
		end
	end
end

editor.registerAction("cut", cut)
editor.registerAction("copy", copy)
editor.registerAction("paste", paste)

editor.bindActionToInput("cut", "cut", editor.Viewport)
editor.bindActionToInput("copy", "copy", editor.Viewport)
editor.bindActionToInput("paste", "paste", editor.Viewport, true)
