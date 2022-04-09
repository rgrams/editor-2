
require "philtre.init"
_G.gui = require "philtre.objects.gui.all"

local scenes = require "scenes"
local scene
local ui

local screenRect = gui.Rect(0, 0, love.graphics.getDimensions())

local layers = {
	world = { "default", "background" },
	gui = { "gui text", "gui" },
	guiDebug = { "guiDebug" },
}
local defaultLayer = "default"

local guiDebugDrawEnabled = false

function love.load()
	math.randomseed(love.timer.getTime() * 10000)
	math.random()  math.random()  math.random()

	Input.init()
	Input.bind( require("input-bindings") )
	love.keyboard.setKeyRepeat(true)

	local config = require "config"
	love.graphics.setBackgroundColor(config.viewportBackgroundColor)

	scene = SceneTree(layers, defaultLayer)

	scene:add(mod(Camera(0, 0, 0, {800,600}, "expand view"), {name="MyCamera"}))
	ui = scene:add( require("ui.UI")() )

	scenes.add(SceneTree({"default"}, "default"))
end

function love.update(dt)
	if scenes.active then  scenes.active:update(dt)  end
	scene:update(dt)
end

function love.draw()
	scene:updateTransforms()
	if scenes.active then  scenes.active:updateTransforms()  end
	Camera.current:applyTransform()
	if scenes.active then  scenes.active:draw()  end
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
	screenRect.w, screenRect.h = w, h
	ui:allocate(screenRect)
end
