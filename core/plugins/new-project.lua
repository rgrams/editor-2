
local NewProjectDialog = require(GetRequireFolder(...) .. "NewProjectDialog")
local urfs = require "core.lib.urfs"
local config = require "core.config"

local function makeNewProject(title, folder)
	print("Creating new project...")
	print("    title:", title)
	print("   folder:", folder)
	local oldWriteDir = urfs.getWriteDir()

	urfs.setWriteDir(folder)
	love.filesystem.createDirectory(title)
	local projectFolder = folder..title.."/"
	urfs.setWriteDir(projectFolder)
	love.filesystem.write(title..config.projectFileExtension, "")
	love.filesystem.write("main.lua", "")
	love.filesystem.write(
		"conf.lua",
		"function love.conf(t)\n\tt.window.resizable = true\nend\n"
	)

	urfs.setWriteDir(oldWriteDir)
end

local function newProject()
	local dialog = editor.Tree:add(NewProjectDialog(makeNewProject), editor.Window)
end

Input.bind("button", "ctrl shift n", "new project")
editor.registerAction("new project", newProject)
editor.bindActionToInput("new project", "new project")
