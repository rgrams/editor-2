
-- A list of all scenes being edited, with some scene-management methods.

local M = {}

local Selection = require "Selection"
local History = require "philtre.lib.commands"
local signals = require "signals"

local layers = { "default" }
local defaultLayer = "default"
local commands = require("commands.all")

function M.create(name, filepath)
	local scene = SceneTree(layers, defaultLayer)
	scene.selection = Selection(scene)
	scene.history = History(commands)
	scene.isDirty = false
	scene.filepath = filepath
	scene.name = name or "Untitled"
	scene.properties = {}
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
