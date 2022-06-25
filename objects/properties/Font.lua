
local Property = require(GetRequireFolder(...) .. "Property")
local Font = Property:extend()

local fileUtil = require "lib.file-util"

Font.name = "font"
Font.typeName = "font"
Font.WidgetClass = require("ui.widgets.properties.Font")
Font.defaultValue = { "", 12 }

_G.propClassList:add(Font, Font.typeName)

-- NOTE: property `value` is the filepath. Store the actual font separately.

local fontLoader = fileUtil.loadFontFromAbsolutePath

function Font.getDefaultValue(self)
	local def = self.defaultValue
	return { def[1], def[2] }
end

function Font.isValid(self, filepath, size)
	filepath = filepath or self.value[1]
	size = size or self.value[2] -- UI Widget does the size == number validation.
	local font
	if filepath ~= "" then
		font = new.custom("font", fontLoader, filepath, size)
	end
	return true, font, filepath, size
end

function Font.setValue(self, value)
	local isValid, font, filepath, size, errMsg = self:isValid(value[1], value[2])
	if not isValid then
		return errMsg
	end
	self:_setValidValue(font, filepath, size)
end

function Font._setValidValue(self, font, filepath, size)
	self.font = font
	self.value[1] = filepath
	self.value[2] = size
end

function Font.copyValue(self)
	return { self.value[1], self.value[2] }
end

function Font.isAtDefault(self)
	local cur, def = self.value, self.defaultValue
	return cur[1] == def[1] and cur[2] == def[2]
end

return Font
