
local M = {}

-- Save and load functions below

M.projectFileExtension = ".project"

M.userConfigFilename = "user-config.lua"

M.winWidth = 800
M.winHeight = 600
M.windowSettings = {
	vsync = 0,
	resizable = true,
	display = 1,
}
M.isWindowMaximized = false
M.winDecorationOX = 0 -- Edit your user config with these
M.winDecorationOY = 0 -- if your window is offset on restart.

M.lastOpenFolder = nil
M.lastSaveFolder = nil
M.lastExportFolder = nil
M.lastFontPropFolder = nil
M.lastImagePropFolder = nil
M.lastFilePropFolder = nil

M.zoomRate = 0.2

M.translateSnapIncrement = 8
M.rotateSnapIncrement = 15
M.roundAllPropsTo = 0.001
M.gridPower = 2
M.gridEmphasizeEvery = 4

M.selectedHighlightColor = {0.9, 0.5, 0.0, 0.9}
M.highlightLineWidth = 2
M.highlightPadding = -1 -- Half of line width, so outer edge of line matches bounds.

M.parentLineColor = {0, 1, 1, 0.05}
M.parentLineLenFrac = 0.92
M.parentLineArrowAngle = 0.4
M.parentLineArrowLength = 25

local fileUtil = require "core.lib.file-util"

local function getUserConfigPath()
	local dir = fileUtil.splitFilepath(love.filesystem.getSource().."/")
	return dir .. M.userConfigFilename
end

function M.load()
	local filepath = getUserConfigPath()
	print("Checking for user config file at: "..filepath)
	local userConfig = fileUtil.loadLuaFromAbsolutePath(filepath)
	if userConfig then
		for k,v in pairs(userConfig) do
			M[k] = v
		end
		print("   user config loaded.")
	else
		print("   not found.")
	end
end

function M.storeWindowPos()
	local win = M.windowSettings
	win.x, win.y, win.display = love.window.getPosition()
	win.x = win.x - M.winDecorationOX
	win.y = win.y - M.winDecorationOY
end

local extraSaveFunctions = {}

function M.subscribeToSave(fn)
	table.insert(extraSaveFunctions, fn)
end

function M.unsubscribeFromSave(fn)
	for i,f in ipairs(extraSaveFunctions) do
		if f == fn then  return table.remove(extraSaveFunctions, i)  end
	end
end

local objToString = require "core.philtre.lib.object-to-string"

function M.save()
	local filepath = getUserConfigPath()
	print("Saving user config file at: "..filepath)
	local file, errMsg = io.open(filepath, "w")
	if file then
		local userConfig = {}
		userConfig.winWidth = M.winWidth
		userConfig.winHeight = M.winHeight
		M.storeWindowPos() -- No callback for window -move-, so grab it now.
		userConfig.windowSettings = M.windowSettings
		userConfig.isWindowMaximized = love.window.isMaximized()
		userConfig.winDecorationOX = M.winDecorationOX
		userConfig.winDecorationOY = M.winDecorationOY
		userConfig.lastOpenFolder = M.lastOpenFolder
		userConfig.lastSaveFolder = M.lastSaveFolder
		userConfig.lastExportFolder = M.lastExportFolder
		userConfig.lastFontPropFolder = M.lastFontPropFolder
		userConfig.lastImagePropFolder = M.lastImagePropFolder
		userConfig.lastFilePropFolder = M.lastFilePropFolder
		userConfig.translateSnapIncrement = M.translateSnapIncrement

		local contentStr = objToString(userConfig)

		for i,fn in ipairs(extraSaveFunctions) do
			local isFnSuccess, errMsg = pcall(fn, userConfig)
			if not isFnSuccess then
				print("   Error in plugin save function: "..tostring(errMsg))
				print("   Will attempt to continue with other save functions.")
			end
			-- Even if fn errors, attempt to continue in case it set things before the error.
			local isObjToStringSuccess, result = pcall(objToString, userConfig)
			if not isObjToStringSuccess then
				print("   Error stringifying user-config after plugin save function: "..tostring(result))
				print("   Will save config up to this point.")
				if i < #extraSaveFunctions then
					print("      Remaining "..#extraSaveFunctions-i.." save functions will not be called.")
				else
					print("      This was the last save function. All others ran successfully.")
				end
				break
			else
				contentStr = result
			end
		end

		file:write("return "..contentStr.."\n")
		file:close()
		print("   saved config.")
	else
		print("   failed: "..errMsg)
	end
end

return M
