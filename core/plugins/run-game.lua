
local scenes = require "core.scenes"
local config = require "core.config"
local fileUtil = require "core.lib.file-util"

local function runGame()
	local scene = scenes.active
	if scene then
		if not scene.filepath then
			editor.messageBox("Can't run the game for this scene, it hasn't been saved anywhere!", "Failed to run game")
		else
			local gameFolder
			if scene:getProperty("useProjectLocalPaths") then
				local projectFolder = fileUtil.findProject(scene.filepath, config.projectFileExtension)
				if not projectFolder then
					editor.messageBox("Can't find project for this scene: \n\n"..tostring(scene.filepath).."\n", "Failed to run game")
					return
				else
					gameFolder = projectFolder
				end
			else
				gameFolder = fileUtil.splitFilepath(scene.filepath)
			end
			print("   running game in folder: "..tostring(gameFolder))
			os.execute("love '"..gameFolder.."'")
		end
		return true
	end
end

editor.registerAction("run game", runGame)
editor.bindActionToInput("run game", "run game")
