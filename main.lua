
require "philtre.init"
require "philtre.lib.math-patch"
_G.gui = require "philtre.objects.gui.all"
_G.vec2 = require "philtre.lib.vec2xy"
_G.scene_clipboard = nil

local modkeys = require "modkeys"
_G.Input = require "input"

local IndexedList = require "lib.IndexedList"
_G.objClassList = IndexedList()

local scenes = require "scenes"
local scene
local window

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

	-- Load editor object classes.
	for i,filename in ipairs(love.filesystem.getDirectoryItems("objects")) do
		local info = love.filesystem.getInfo("objects/"..filename)
		if info and info.type == "file" and filename:sub(-4) == ".lua" then
			require("objects."..filename:sub(1, -5))
		end
	end

	scene = SceneTree(layers, defaultLayer)

	scene:add(mod(Camera(0, 0, 0, {800,600}, "expand view"), {name="MyCamera"}))
	window = scene:add( require("ui.Window")() )

	-- Add default editing scene.
	local sceneLayers = { "default" }
	local sceneDefaultLayer = "default"
	local commands = require("commands.all")
	scenes.add( scenes.create(sceneLayers, sceneDefaultLayer, commands) )
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
		window:callRecursive("debugDraw", "guiDebug")
		scene:draw("guiDebug")
		scene.draw_order:clear("guiDebug")
	end
end

function love.resize(w, h)
	screenRect.w, screenRect.h = w, h
	window:allocate(screenRect)
end

function love.keypressed(key, scancode, isrepeat)
	modkeys.keypressed(key)
end

function love.keyreleased(key)
	modkeys.keyreleased(key)
end
