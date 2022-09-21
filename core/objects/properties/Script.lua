
local Property = require(GetRequireFolder(...) .. "Property")
local Script = Property:extend()

local fileUtil = require "core.lib.file-util"

local scriptCache = {}

Script.name = "script"
Script.typeName = "script"
Script.WidgetClass = require("core.ui.widgets.properties.File")
Script.defaultValue = ""

_G.propClassList:add(Script, Script.typeName)

-- NOTE: property `value` is the filepath. Store the actual script separately.

function Script.isValid(self, filepath)
	local script
	if filepath == "" then
		return true, nil
	elseif filepath then
		script = scriptCache[filepath]
		local errMsg
		if not script then
			script, errMsg = fileUtil.loadLuaFromAbsolutePath(filepath)
		end
		if script then
			scriptCache[filepath] = script
			return true, script
		else
			print(errMsg)
			editor.messageBox("Error loading script: "..tostring(errMsg), "Failed to load editor script")
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
