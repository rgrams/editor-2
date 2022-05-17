
local Property = require(GetRequireFolder(...) .. "Property")
local Image = Property:extend()

local fileUtil = require "lib.file-util"

local imageCache = {}

Image.name = "image"
Image.className = "image"
Image.WidgetClass = require("ui.widgets.properties.File")
Image.DEFAULT_VALUE = false

_G.propClassList:add(Image, Image.className)

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
	if self.obj.setImage then
		self.obj:setImage(image)
	end
end

function Image.isAtDefault(self)
	local curVal = self:getValue()
	return curVal and curVal ~= self.DEFAULT_VALUE -- `nil` and `false` considered equal
end

return Image
