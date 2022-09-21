
local Property = require(GetRequireFolder(...) .. "Property")
local File = Property:extend()

File.name = "file"
File.typeName = "file"
File.WidgetClass = require("core.ui.widgets.properties.File")
File.defaultValue = ""

_G.propClassList:add(File, File.typeName)

function File.isValid(self, value)
	if value == "" then
		return true, value
	end
	local file, errMsg = io.open(value, "r")
	if file then
		file:close()
		return true, value
	else
		return false, nil, errMsg
	end
end

return File
