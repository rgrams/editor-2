
io.stdout:setvbuf("no")

require "run"
require "philtre.init"
require "philtre.lib.math-patch"
require "lib.GetRequireFolder" -- Global function.
_G.gui = require "philtre.objects.gui.all"
_G.vec2 = require "philtre.lib.vec2xy"
_G.scene_clipboard = nil

local config = require "config"
local fileUtil = require "lib.file-util"

do -- Load user config.
	local dir = fileUtil.splitFilepath(love.filesystem.getSource().."/")
	local filepath = dir .. config.userConfigFilename
	print("Checking for user config file at: "..filepath)
	local userConfig = fileUtil.loadLuaFromAbsolutePath(filepath)
	if userConfig then
		for k,v in pairs(userConfig) do
			config[k] = v
		end
		print("   user config loaded.")
	else
		print("   not found.")
	end
end

local modkeys = require "modkeys"
_G.Input = require "input"

local IndexedList = require "lib.IndexedList"
_G.objClassList = IndexedList()
_G.propClassList = IndexedList()
_G.exporterList = IndexedList()

_G.editor = require "editor"

local scenes = require "scenes"
local editorTree
local window

local screenRect = gui.Rect(0, 0, love.graphics.getDimensions())

local layers = {
	world = { "default", "background" },
	gui = { "dropdown text", "dropdown", "gui text", "gui", "viewport" },
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

	love.graphics.setLineStyle("rough")

	local config = require "config"
	love.graphics.setBackgroundColor(config.viewportBackgroundColor)

	-- Load property classes.
	requireModulesInFolder("objects/properties/")

	-- Load editor object classes.
	requireModulesInFolder("objects/")

	-- Load exporters.
	requireModulesInFolder("io/")

	editorTree = SceneTree(layers, defaultLayer)

	editorTree:add( Camera(0, 0, 0, {800,600}, "expand view") )
	window = editorTree:add( require("ui.Window")() )

	_G.editor.tree = editorTree
	_G.editor.window = window

	-- Add default editing scene.
	scenes.add( scenes.create() )
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
		editorTree.draw_order:clear("guiDebug")
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
					{ "image", filepath },
					{ "pos", { x = x, y = y } }
				}
				scene.history:perform("addObject", false, scene, Class, {}, properties)
				_G.shouldRedraw = true
				return
			end
		end
	end
	local ui = editorTree:get("/Window/UI")
	ui:openScene(file:getFilename())
end

function love.quit()
	-- Save user config.

	local dir = fileUtil.splitFilepath(love.filesystem.getSource().."/")
	local filepath = dir .. config.userConfigFilename
	print("Saving user config file at: "..filepath)
	local file, errMsg = io.open(filepath, "w")
	if file then
		local userConfig = {}
		userConfig.lastOpenFolder = config.lastOpenFolder
		userConfig.lastSaveFolder = config.lastSaveFolder
		userConfig.lastExportFolder = config.lastExportFolder
		userConfig.lastFontPropFolder = config.lastFontPropFolder
		userConfig.lastFilePropFolder = config.lastFilePropFolder

		local objToString = require "philtre.lib.object-to-string"
		file:write("return "..objToString(userConfig).."\n")
		file:close()
		print("   saved config.")
	else
		print("   failed: "..errMsg)
	end
end
