
-- A list of all scenes being edited, with some scene-management methods.

local M = {}

local Selection = require "Selection"
local History = require "philtre.lib.commands"
local signals = require "signals"

local layers = { "default" }
local defaultLayer = "default"
local commands = require("commands.all")
local SENDER = nil

function M.create(name, filepath)
	local scene = SceneTree(layers, defaultLayer)
	scene.selection = Selection(scene)
	scene.history = History(commands)
	scene.filepath = filepath
	scene.name = name or "Untitled"
	scene.properties = {}
	return scene
end

function M.add(scene, isNotActive)
	table.insert(M, scene)
	signals.send("scene added", SENDER, scene)
	if not isNotActive then
		M.setActive(scene)
	end
end

function M.remove(scene)
	for i=1,#M do
		if M[i] == scene then
			table.remove(M, i)
			signals.send("scene removed", SENDER, scene)
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

function M.setActive(scene)
	M.active = scene
	love.window.setTitle("Editor - " .. scene.name)
	signals.send("active scene changed", SENDER, scene)
	_G.shouldRedraw = true
end

return M
