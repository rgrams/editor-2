
io.stdout:setvbuf("no")

require "core.run"
require "core.philtre.init"
require "core.philtre.lib.math-patch"
require "core.lib.GetRequireFolder" -- Global function.
_G.gui = require "core.philtre.objects.gui.all"
_G.vec2 = require "core.philtre.lib.vec2xy"
_G.scene_clipboard = nil

local config = require "core.config"
local fileUtil = require "core.lib.file-util"

config.load()

do -- Initialize window
	love.window.setMode(config.winWidth, config.winHeight, config.windowSettings)
	if config.isWindowMaximized then  love.window.maximize()  end
	love.window.setTitle("Editor")
end

local modkeys = require "core.modkeys"
_G.Input = require "core.input"

local IndexedList = require "core.lib.IndexedList"
_G.objClassList = IndexedList()
_G.propClassList = IndexedList()
_G.exporterList = IndexedList()

_G.editor = require "core.editor"

local scenes = require "core.scenes"
local editorTree
local window

local screenRect = gui.Alloc(0, 0, love.graphics.getDimensions())

local layers = {
	world = { "default", "background" },
	gui = { "dropdown text", "dropdown", "gui text", "gui", "viewport" },
	guiDebug = { "guiDebug" },
}
local defaultLayer = "default"

local guiDebugDrawEnabled = false

function love.load()
	math.randomseed(love.timer.getTime() * 10000)
	math.random()  math.random()  math.random()

	Input.init()
	Input.bind( require("core.input-bindings") )
	love.keyboard.setKeyRepeat(true)

	love.graphics.setLineStyle("rough")

	local style = require "core.ui.style"
	love.graphics.setBackgroundColor(style.viewportBackgroundColor)

	-- Load property classes.
	fileUtil.requireModulesInFolder("core/objects/properties/")

	-- Load editor object classes.
	fileUtil.requireModulesInFolder("core/objects/")

	-- Load exporters.
	fileUtil.requireModulesInFolder("core/io/")

	editorTree = SceneTree(layers, defaultLayer)

	editorTree:add( Camera(0, 0, 0, {800,600}, "expand view") )
	window = editorTree:add( require("core.ui.Window")() )

	_G.editor.Tree = editorTree
	_G.editor.Window = window

	-- Add default editing scene.
	scenes.add( scenes.create() )

	fileUtil.requireModulesInFolder("core/plugins/")
	fileUtil.requireModulesInFolder("user/plugins/")
end

function love.update(dt)
	if scenes.active then  scenes.active:update(dt)  end
	editorTree:update(dt)
end

function love.draw()
	local activeScene = scenes.active

	editorTree:updateTransforms()
	if activeScene then  activeScene:updateTransforms()  end
	Camera.current:applyTransform()
	if activeScene then  activeScene:draw()  end
	editorTree:draw("world")
	Camera.current:resetTransform()
	editorTree:draw("gui")

	if guiDebugDrawEnabled then
		window:callRecursive("debugDraw", "guiDebug")
		editorTree:draw("guiDebug")
		editorTree.drawOrder:clear("guiDebug")
	end
end

function love.resize(w, h)
	screenRect.w, screenRect.h = w, h
	window:allocate(screenRect:unpack())
	_G.shouldRedraw = true
	if not love.window.isMaximized() then
		config.winWidth, config.winHeight = w, h
		config.storeWindowPos()
	end
end

function love.keypressed(key, scancode, isRepeat)
	modkeys.keypressed(key, isRepeat)
end

function love.keyreleased(key)
	modkeys.keyreleased(key)
end

function love.filedropped(file)
	if scenes.active then
		local scene = scenes.active
		local filepath = file:getFilename()
		local _, _, ext = fileUtil.splitFilepath(filepath)
		if ext == ".png" or ext == ".jpg" then
			local image = fileUtil.loadImageFromAbsolutePath(filepath)
			if image then
				local Class = require "core.objects.EditorSprite"
				local x, y = Camera.current:screenToWorld(love.mouse.getPosition())
				local properties = {
					{ "image", filepath },
					{ "pos", { x = x, y = y } }
				}
				scene.history:perform("addObject", false, scene, Class, {}, properties)
				_G.shouldRedraw = true
				return
			end
		end
	end
	editor.runAction("open scene", file:getFilename())
end

function love.focus(hasFocus)
	if hasFocus then  _G.shouldRedraw = true  end
end

function love.quit()
	config.save()
end
