
local M = {}

local urfs = require "core.lib.urfs"

function M.requireModulesInFolder(folderPath) -- path should include trailing slash
	local requireFolderPath = folderPath:gsub("[\\/]", ".")
	for i,filename in ipairs(love.filesystem.getDirectoryItems(folderPath)) do
		local info = love.filesystem.getInfo(folderPath..filename)
		if info and info.type == "file" and filename:sub(-4) == ".lua" then
			require(requireFolderPath..filename:sub(1, -5))
		end
	end
end

local folderPattern = "[^\\/]+[\\/]"

function M.getRelativePath(from, to)
	from = from:gsub("^[\\/]", "") -- Cut off starting \ or / if it exists.
	to = to:gsub("^[\\/]", "")
	local fromFolder = M.splitFilepath(from)
	local i1, i2 = string.find(to, fromFolder, nil, true)
	if i1 and i1 == 1 then
		return string.sub(to, i2+1)
	else
		local _to = to
		local foldersUp = 0
		for folder in string.gmatch(fromFolder, folderPattern) do
			local i1, i2 = string.find(_to, folder, nil, true)
			if i1 and i1 == 1 then
				_to = string.sub(_to, i2+1)
			else
				foldersUp = foldersUp + 1
			end
		end
		local upStr = string.rep("../", foldersUp)
		_to = upStr .. _to
		return _to
	end
end

local upFolderPattern = "%.%.[\\/]"

function M.resolveRelativePath(from, relPath)
	local fromFolder = M.splitFilepath(from)
	if string.find(relPath, "^"..upFolderPattern) then
		local foldersUp
		relPath, foldersUp = string.gsub(relPath, upFolderPattern, "")
		for i=1,foldersUp do
			fromFolder = string.gsub(fromFolder, "[^\\/]+[\\/]$", "")
		end
	end
	return fromFolder .. relPath
end

-- Returns folder, filename, extension (extension can be nil, dot is included)
function M.splitFilepath(path)
	if string.find(path, "%.[^%.][^%.]-$") then
		return string.match(path, "(.-)([^\\/]-)(%.?[^%.\\/]*)$")
	else
		return string.match(path, "(.-)([^\\/]-)$")
	end
end

function M.toRequirePath(filepath)
	return filepath:gsub("[\\/]", "."):gsub("%.lua", "")
end

function M.loadLuaFromAbsolutePath(path)
	local isSuccess, result = pcall(dofile, path)
	if isSuccess then
		return result
	else
		return false, result
	end
end

function M.loadFontFromAbsolutePath(path, size)
	local file, error = io.open(path, "rb")
	if error then
		print(error)
		return false
	end
	local _, filename, ext = M.splitFilepath(path)
	ext = ext or ".ttf"
	filename = (filename ~= "" and filename or "new") .. ext
	local fileData, error = love.filesystem.newFileData(file:read("*a"), filename)
	file:close()
	if not error then
		local isSuccess, result = pcall(love.font.newTrueTypeRasterizer, fileData, size)
		if not isSuccess then
			print("Error generating rasterizer from file:\n   "..result)
		else
			local isSuccess, result = pcall(love.graphics.newFont, result, size)
			if not isSuccess then
				print("Error loading font from rasterizer:\n   "..result)
			else
				return result
			end
		end
	else
		print("Error reading file:\n   "..error)
	end
	return false
end

function M.loadImageFromAbsolutePath(path)
	local file, error = io.open(path, "rb")
	if error then
		print(error)
		return false
	end
	local _, filename, ext = M.splitFilepath(path)
	ext = ext or ".jpg"
	filename = (filename ~= "" and filename or "new") .. ext
	local fileData, error = love.filesystem.newFileData(file:read("*a"), filename)
	file:close()
	if not error then
		local isSuccess, result = pcall(love.graphics.newImage, fileData)
		if not isSuccess then
			print("Error generating image from file:\n   "..result)
		else
			return result
		end
	else
		print("Error reading file:\n   "..error)
	end
	return false
end

function M.goUp(from, foldersUp)
	local path = M.splitFilepath(from)
	for i=1,foldersUp or 1 do
		local i1, i2 = path:find("[\\/][^\\/]+[\\/]?$")
		if i1 then
			path = path:sub(1, i1)
		else
			break
		end
	end
	return path
end

-- Returns folder, filename (or nil).
function M.findProject(sceneFilepath, projectFileExtension)
	local sourceFolder = love.filesystem.getSource()
	local fromFolder = M.splitFilepath(sceneFilepath)
	while true do
		local mountPoint = "_searchFolder/"
		if fromFolder == sourceFolder then  mountPoint = ""  end
		local oldMountPoint = urfs.getMountPoint(fromFolder)
		if oldMountPoint then  urfs.unmount(fromFolder)  end
		if not urfs.mount(fromFolder, mountPoint) then
			print("      urfs.mount failed with folder: '"..tostring(fromFolder).."'.")
			return
		end
		for i,path in ipairs(love.filesystem.getDirectoryItems(mountPoint)) do
			local _, _, extension = M.splitFilepath(path)
			if extension == projectFileExtension then
				local fullPath = mountPoint .. path
				if love.filesystem.getInfo(fullPath).type == "file" then
					urfs.unmount(fromFolder, mountPoint)
					if oldMountPoint then  urfs.mount(fromFolder, oldMountPoint)  end
					return fromFolder, path
				end
			end
		end
		urfs.unmount(fromFolder, mountPoint)
		if oldMountPoint then  urfs.mount(fromFolder, oldMountPoint)  end
		if #fromFolder <= 1 then
			return
		end
		fromFolder = M.goUp(fromFolder)
	end
end

return M
