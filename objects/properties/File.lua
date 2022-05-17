
local Property = require(GetRequireFolder(...) .. "Property")
local File = Property:extend()

File.widgetName = "file"
File.className = "file"
File.name = "file"
File.DEFAULT_VALUE = ""

_G.propClassList:add(File, File.className)

function File.isValid(self, value)
	local file, errMsg = io.open(value, "r")
	if file then
		file:close()
		return true, value
	else
		return false, nil, errMsg
	end
end

return File
