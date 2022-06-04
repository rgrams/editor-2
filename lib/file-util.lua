
local M = {}

-- Returns folder, filename, extension (extension can be nil, dot is included)
function M.splitFilepath(path)
	if string.find(path, "%.[^%.][^%.]-$") then
		return string.match(path, "(.-)([^\\/]-)(%.?[^%.\\/]*)$")
	else
		return string.match(path, "(.-)([^\\/]-)$")
	end
end

function M.loadScriptFromAbsolutePath(path)
	local isSuccess, result = pcall(dofile, path)
	if isSuccess then
		return result
	else
		print(result)
		return false
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

return M
