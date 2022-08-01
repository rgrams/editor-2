
local script = {}

local signals = require "signals"
local scenes = require "scenes"

local dirtyingSignals = {
	"objects added",
	"objects deleted",
	"selected objects modified",
	"export path modified",
}

local activeSceneChanged
local sceneModified
local sceneSaved
local undoRedoPerformed

function script.init(self)
	signals.subscribe(self, activeSceneChanged, "active scene changed")
	signals.subscribe(self, sceneModified, unpack(dirtyingSignals))
	signals.subscribe(self, sceneSaved, "file saved")
	signals.subscribe(self, undoRedoPerformed, "undo", "redo")
end

function script.final(self)
	signals.unsubscribe(self, activeSceneChanged, "active scene changed")
	signals.unsubscribe(self, sceneModified, unpack(dirtyingSignals))
	signals.unsubscribe(self, sceneSaved, "file saved")
	signals.unsubscribe(self, undoRedoPerformed, "undo", "redo")
end

local function updateTabText(self, scene)
	local tabBar = self.tree:get("/Window/UI/MainRow/VPColumn/TabBar")
	local title = tabBar.getTrimmedText(scene.name) .. (scene.isDirty and "*" or "")
	tabBar:setTabText(scene, title)
end

local function updateWindowTitle(scene)
	if scene == scenes.active then
		local title = "Editor - " .. scene.name
		if scene.isDirty then  title = title .. "*"  end
		love.window.setTitle(title)
	end
end

function activeSceneChanged(self, sender, signal, scene)
	updateWindowTitle(scene)
end

function sceneModified(self, sender, signal, scene)
	if not scene.isDirty then
		scene.isDirty = true
		updateTabText(self, scene)
		updateWindowTitle(scene)
	end
end

function sceneSaved(self, sender, signal, scene, filepath)
	scene.isDirty = false
	-- TODO: scene.savedHistoryPoint = scene.history.???
	updateTabText(self, scene)
	updateWindowTitle(scene)
end

function undoRedoPerformed(self, sender, signal, scene, cmd)
	-- TODO: Compare to scene.savedHistory point to see if the scene is dirty or not.
end

return script
