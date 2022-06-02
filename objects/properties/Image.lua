
local Property = require(GetRequireFolder(...) .. "Property")
local Image = Property:extend()

local fileUtil = require "lib.file-util"

local imageCache = {}

Image.name = "image"
Image.typeName = "image"
Image.WidgetClass = require("ui.widgets.properties.File")
Image.defaultValue = ""

_G.propClassList:add(Image, Image.typeName)

-- NOTE: property `value` is the filepath. Store the actual image separately.

function Image.isValid(self, filepath)
	local image
	if filepath then -- Can be false.
		image = imageCache[filepath] or fileUtil.loadImageFromAbsolutePath(filepath)
	end
	if image then
		imageCache[filepath] = image
	end
	return true, image -- always valid, image can be nil
end

function Image.setValue(self, filepath)
	local isValid, image, errMsg = self:isValid(filepath)
	if not isValid then
		return errMsg
	end
	self:_setValidValue(filepath, image)
end

function Image._setValidValue(self, filepath, image)
	self.value = filepath
	self.image = image
end

function Image.isAtDefault(self)
	local curVal = self:getValue()
	return curVal ~= self.defaultValue
end

return Image
