
local Property = require(GetRequireFolder(...) .. "Property")
local Script = Property:extend()

local fileUtil = require "lib.file-util"

local scriptCache = {}

Script.name = "script"
Script.typeName = "script"
Script.WidgetClass = require("ui.widgets.properties.File")
Script.DEFAULT_VALUE = ""

_G.propClassList:add(Script, Script.typeName)

-- NOTE: property `value` is the filepath. Store the actual script separately.

function Script.isValid(self, filepath)
	local script
	if filepath == "" then
		return true, nil
	elseif filepath then
		script = scriptCache[filepath] or fileUtil.loadScriptFromAbsolutePath(filepath)
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
	self.value = filepath
	self.script = script
end

function Script.isAtDefault(self)
	local curVal = self:getValue()
	return curVal ~= self.DEFAULT_VALUE
end

return Script