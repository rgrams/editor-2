
-- A list of all scenes being edited, with some scene-management methods.

local M = {}

local Selection = require "core.Selection"
local History = require "core.philtre.lib.commands"
local signals = require "core.signals"
local fileUtil = require "core.lib.file-util"
local requirePath = require "core.require-path"
local config = require "core.config"

local layers = { "default", "images" }
local defaultLayer = "default"
local commands = require "core.commands.all"
local PropData = require "core.commands.data.PropData"

----------  Define EditorScene class (so scene can have properties)  ----------
local EditorObject = require "core.objects.EditorObject"
local EditorScene = SceneTree:extend()
EditorScene:implements(EditorObject, "skip")

function EditorScene.set(self, layers, defaultLayer)
	SceneTree.set(self, layers, defaultLayer)

	self.tree = self -- For commands, they get the tree to pass to update signals.

	-- From EditorObject.set:
	self.isSelected = true -- So signals will be sent to update properties panel.
	self.isHovered = false
	self.AABB = {}
	self.properties = {}
	self.propertyMap = {}
	self:initProperties()
end

function EditorScene.initProperties(self)
	local Bool = require("core.objects.properties.Bool")
	self:addProperty(PropData("useProjectLocalPaths", false, Bool, false, true))
end

function EditorScene.propertyWasSet(self, name, value, property)
	EditorObject.propertyWasSet(self, name, value, property)
	if name == "useProjectLocalPaths" and value == true and self.filepath then
		-- Note: Won't have a filepath if it's never been saved.
		local projectFolder = fileUtil.findProject(self.filepath, config.projectFileExtension)
		if projectFolder then  requirePath.prepend(projectFolder)  end
	end
end
----------  -  ----------

function M.create(name, filepath)
	local scene = EditorScene(layers, defaultLayer)
	scene.enclosure = { scene }
	scene.selection = Selection(scene)
	scene.selfSelection = Selection(scene)
	scene.selfSelection:add(scene.enclosure)
	scene.history = History(commands)
	scene.isDirty = false
	scene.filepath = filepath
	scene.name = name or "Untitled"
	scene.camX, scene.camY, scene.camZoom = 0, 0, 1
	return scene
end

function M.add(scene, sender, isNotActive)
	table.insert(M, scene)
	signals.send("scene added", sender, scene)
	if not isNotActive then
		M.setActive(scene)
	end
end

function M.remove(scene, sender)
	for i=1,#M do
		if M[i] == scene then
			table.remove(M, i)
			signals.send("scene removed", sender, scene)
			-- If this scene was the active one, activate another scene.
			if M.active == scene then
				if M[i-1] then
					M.setActive(M[i-1])
				elseif M[i] then
					M.setActive(M[i])
				end
			end
		end
	end
	-- If last scene is removed, create a new empty scene.
	if #M == 0 then
		M.add( M.create() )
	end
end

function M.getIndex(scene)
	for i=1,#M do
		if M[i] == scene then
			return i
		end
	end
end

function M.setActive(scene, sender)
	M.active = scene
	signals.send("active scene changed", sender, scene)
	_G.shouldRedraw = true
end

return M
