
local Property = require(GetRequireFolder(...) .. "Property")
local Script = Property:extend()

local fileUtil = require "lib.file-util"

local scriptCache = {}

Script.name = "script"
Script.typeName = "script"
Script.WidgetClass = require("ui.widgets.properties.File")
Script.defaultValue = ""

_G.propClassList:add(Script, Script.typeName)

-- NOTE: property `value` is the filepath. Store the actual script separately.

function Script.isValid(self, filepath)
	local script
	if filepath == "" then
		return true, nil
	elseif filepath then
		script = scriptCache[filepath] or fileUtil.loadLuaFromAbsolutePath(filepath)
		if script then
			scriptCache[filepath] = script
			return true, script
		end
	end
	return false, nil
end

function Script.setValue(self, filepath)
	local isValid, script, errMsg = self:isValid(filepath)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(filepath, script)
end

function Script._setValidValue(self, filepath, script)
	self.oldPath = self.value
	self.oldScript = self.script -- So objects can remove it when changed.
	self.value = filepath
	self.script = script
end

return Script
