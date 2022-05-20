
io.stdout:setvbuf("no")

require "run"
require "philtre.init"
require "philtre.lib.math-patch"
require "lib.GetRequireFolder" -- Global function.
_G.gui = require "philtre.objects.gui.all"
_G.vec2 = require "philtre.lib.vec2xy"
_G.scene_clipboard = nil

local modkeys = require "modkeys"
_G.Input = require "input"

local IndexedList = require "lib.IndexedList"
_G.objClassList = IndexedList()
_G.propClassList = IndexedList()

local scenes = require "scenes"
local scene
local window

local screenRect = gui.Rect(0, 0, love.graphics.getDimensions())

local layers = {
	world = { "default", "background" },
	gui = { "dropdown text", "dropdown", "gui text", "gui" },
	guiDebug = { "guiDebug" },
}
local defaultLayer = "default"

local guiDebugDrawEnabled = false

local function requireModulesInFolder(folderPath) -- path should include trailing slash
	local requireFolderPath = folderPath:gsub("[\\/]", ".")
	for i,filename in ipairs(love.filesystem.getDirectoryItems(folderPath)) do
		local info = love.filesystem.getInfo(folderPath..filename)
		if info and info.type == "file" and filename:sub(-4) == ".lua" then
			require(requireFolderPath..filename:sub(1, -5))
		end
	end
end

function love.load()
	math.randomseed(love.timer.getTime() * 10000)
	math.random()  math.random()  math.random()

	Input.init()
	Input.bind( require("input-bindings") )
	love.keyboard.setKeyRepeat(true)

	local config = require "config"
	love.graphics.setBackgroundColor(config.viewportBackgroundColor)

	-- Load property classes.
	requireModulesInFolder("objects/properties/")

	-- Load editor object classes.
	requireModulesInFolder("objects/")

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
	_G.shouldRedraw = true
end

function love.keypressed(key, scancode, isRepeat)
	modkeys.keypressed(key, isRepeat)
end

function love.keyreleased(key)
	modkeys.keyreleased(key)
end

local fileUtil = require "lib.file-util"

function love.filedropped(file)
	if scenes.active then
		local scene = scenes.active
		local filepath = file:getFilename()
		local _, _, ext = fileUtil.splitFilepath(filepath)
		if ext == ".png" or ext == ".jpg" then
			local image = fileUtil.loadImageFromAbsolutePath(filepath)
			if image then
				local Class = require "objects.EditorSprite"
				local x, y = Camera.current:screenToWorld(love.mouse.getPosition())
				local properties = {
					image = { filepath },
					pos = { { x = x, y = y } }
				}
				scene.history:perform("addObject", false, scene, Class, {}, properties)
				_G.shouldRedraw = true
				return
			end
		end
		local importer = require "io.defaultLuaImportExport"
		importer.import(scene, filepath)
		_G.shouldRedraw = true
	end
end
