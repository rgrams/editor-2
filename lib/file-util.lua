
local M = {}

-- Returns folder, filename, extension (extension can be nil, dot is included)
function M.splitFilepath(path)
	if string.find(path, "%.[^%.][^%.]-$") then
		return string.match(path, "(.-)([^\\/]-)(%.?[^%.\\/]*)$")
	else
		return string.match(path, "(.-)([^\\/]-)$")
	end
end

function M.loadImageFromAbsolutePath(path)
	local file, error = io.open(path, "rb")
	if error then
		print(error)
		return
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
end

return M
