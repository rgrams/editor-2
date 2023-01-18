
local NewProjectDialog = require(GetRequireFolder(...) .. "NewProjectDialog")
local urfs = require "core.lib.urfs"
local config = require "core.config"

local function getPlatformCopyCmd(source, dest)
	if love.system.getOS() == "Windows" then
		return ("xcopy '%s' '%s'"):format(source, dest)
	else
		return ("cp -r '%s' '%s'"):format(source, dest)
	end
end

local function readAll(filename)
	local f = io.open(filename, "r")
	local contents = f:read("*a")
	f:close()
	return contents
end

local function execute(command)
	local tmpOut = os.tmpname()
	local tmpErr = os.tmpname()
	local code = os.execute(command.." > "..tmpOut.." 2>"..tmpErr)
	local out = readAll(tmpOut)
	local err = readAll(tmpErr)
	os.remove(tmpOut)
	os.remove(tmpErr)
	if err and err ~= "" and code ~= 0 then
		return nil, err, out
	end
	return true, out
end

local function exec(command, activity)
	print(command)
	local isSuccess, errMsg, outMsg = execute(command)
	if not isSuccess then
		errMsg = errMsg:gsub("%s*$", "")
		local m = "Error while "..activity.." :\n'"..errMsg.."'"
		print(m)
		print("", outMsg)
		editor.messageBox(m.."\n\nAborting.", "Error Creating New Project")
	end
	return isSuccess
end

local function withoutTrailingSlash(path)
	return path:gsub("[\\/]$", "")
end

local function copyLocalGitRepo(source, dest, title, parentFolder)
	source = withoutTrailingSlash(source)
	dest = withoutTrailingSlash(dest)
	-- TODO: Check if git works. (Should be checked while dialog is open also.)
	-- TODO: Check if `source` is actually a git repo?
	if not exec(getPlatformCopyCmd(source, dest), "copying template repository") then  return  end
	if not exec("git -C '"..dest.."' checkout --orphan new", "checking out orphan branch") then  return  end
	if not exec("git -C '"..dest.."' add --all", "staging all files") then  return  end
	if not exec("git -C '"..dest.."' commit -m 'Initialize from project template'", "making new initial commit") then  return  end
	if not exec("git -C '"..dest.."' branch -M master", "overwriting master branch with new orphan branch") then  return end
	os.execute("git -C '"..dest.."' remote remove origin")
	if not exec("git -C '"..dest.."' gc --aggressive --prune=all", "pruning template git history") then  return end
	editor.messageBox("New project created at:\n"..dest, "Create New Project Successful")
end

local function copyRemoteGitRepo(source, dest, title, parentFolder)
	-- if not exec(("git clone --recursive --depth 1 '%s' '%s'"):format(source, dest), "cloning from online repository") then  return  end
	if not exec(("git clone --recursive --depth 1 --branch editor-minimal '%s' '%s'"):format(source, dest), "cloning from online repository") then  return  end
	if not exec("git -C '"..dest.."' commit --amend -m 'Initialize from project template'", "amending inital commit") then  return  end
	if not exec("git -C '"..dest.."' remote remove origin", "removing remote origin") then  return  end
	editor.messageBox("New project created at:\n"..dest, "Create New Project Successful")
end

local function createLoveMostlyEmpty(source, dest, title, parentFolder)
	urfs.setWriteDir(parentFolder)
	love.filesystem.createDirectory(title)
	urfs.setWriteDir(dest)
	love.filesystem.write(title..config.projectFileExtension, "")
	love.filesystem.write("main.lua", "")
	love.filesystem.write(
		"conf.lua",
		"function love.conf(t)\n\tt.window.resizable = true\nend\n"
	)
end

local function makeNewProject(title, parentFolder)
	print("Creating new project...")
	print("    title:", title)
	print("   folder:", parentFolder)
	local oldWriteDir = urfs.getWriteDir()
	config.lastOpenFolder = parentFolder

	local projectFolder = parentFolder..title

	createLoveMostlyEmpty(nil, projectFolder, title, parentFolder)

	-- local source = "../../Philtre Libraries/project-template"
	-- copyLocalGitRepo(source, projectFolder, title, parentFolder)

	-- local source = "git@github.com:rgrams/project-template.git"
	-- copyRemoteGitRepo(source, projectFolder, title, parentFolder)

	urfs.setWriteDir(oldWriteDir)
end

local function newProject()
	local dialog = editor.Tree:add(NewProjectDialog(makeNewProject), editor.Window)
end

Input.bind("button", "ctrl shift n", "new project")
editor.registerAction("new project", newProject)
editor.bindActionToInput("new project", "new project")
