
function GetRequireFolder(path)
	-- Just strip off the last set of non-dot characters.
	return path:gsub("[^%.]+$", "")
end
