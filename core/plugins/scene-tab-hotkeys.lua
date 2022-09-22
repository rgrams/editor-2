
local scenes = require "core.scenes"

local function nextTab()
	if #scenes > 1 then
		local index = scenes.getIndex(scenes.active)
		local nextIndex = ((index - 1 + 1) % #scenes) + 1
		scenes.setActive(scenes[nextIndex])
		return true
	end
end

local function prevTab()
	if #scenes > 1 then
		local index = scenes.getIndex(scenes.active)
		local prevIndex = ((index - 1 - 1) % #scenes) + 1
		scenes.setActive(scenes[prevIndex])
		return true
	end
end

local function closeTab()
	scenes.remove(scenes.active)
	return true
end

editor.registerAction("next tab", nextTab)
editor.registerAction("prev tab", prevTab)
editor.registerAction("close tab", closeTab)

editor.bindActionToInput("next tab", "next tab", editor.UI, true)
editor.bindActionToInput("prev tab", "prev tab", editor.UI, true)
editor.bindActionToInput("close tab", "close tab", editor.UI, true)
