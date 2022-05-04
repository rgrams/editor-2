
local _basePath = (...):gsub("Image$", "")
local Property = require(_basePath .. "Property")

local Image = Property:extend()

local fileUtil = require "lib.file-util"

local imageCache = {}

Image.type = "image"
Image.name = "image"
Image.displayName = "Image"
Image.DEFAULT_VALUE = false

-- NOTE: property `value` is the filepath. Store the actual image separately.

function Image.isValid(self, filepath)
	local image = imageCache[filepath] or fileUtil.loadImageFromAbsolutePath(filepath)
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

function Image.getDiff(self)
	local curVal = self:getValue()
	if curVal and curVal ~= self.DEFAULT_VALUE then -- `nil` and `false` considered equal
		return curVal
	end
end

return Image
