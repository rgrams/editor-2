
local Window = gui.Node:extend()
Window.className = "Window"

local sceneLoader = require "core.lib.scene.editor-scene-loader"
local uiScene = new.scene("core.ui.ui-scene")

function Window.set(self)
	local w, h = love.graphics.getDimensions()
	Window.super.set(self, w, h, "NW", "C", "fill")
	self.layer = "gui"
	sceneLoader.addScene(uiScene, self)
end

return Window
