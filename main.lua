
require "philtre.init"
_G.gui = require "philtre.objects.gui.all"

local scene
local ui

local screenRect = gui.Rect(0, 0, love.graphics.getDimensions())

local layers = {
	world = { "default" },
	gui = { "gui text", "gui" },
	guiDebug = { "guiDebug" },
}
local defaultLayer = "default"

local guiDebugDrawEnabled = true

function love.load()
	math.randomseed(love.timer.getTime() * 10000)
	math.random()  math.random()  math.random()

	Input.init()
	Input.bind( require("input-bindings") )
	love.keyboard.setKeyRepeat(true)

	scene = SceneTree(layers, defaultLayer)

	ui = scene:add( require("ui.UI")() )

	scene:add(Camera(0, 0, 0, {800,600}, "expand view"))
end

function love.update(dt)
	scene:update(dt)
end

function love.draw()
	scene:updateTransforms()
	Camera.current:applyTransform()
	scene:draw("world")
	Camera.current:resetTransform()
	scene:draw("gui")

	if guiDebugDrawEnabled then
		ui:callRecursive("debugDraw", "guiDebug")
		scene:draw("guiDebug")
		scene.draw_order:clear("guiDebug")
	end
end

function love.resize(w, h)
	Camera.setAllViewports(0, 0, w, h)
	screenRect.w, screenRect.h = w, h
	ui:allocate(screenRect)
end
