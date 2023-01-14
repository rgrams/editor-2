
-- Same as InputField, except it aligns text to -right- end when not in focus.

local InputField = require(GetRequireFolder(...) .. "InputField")
local FilepathField = InputField:extend()

-- Only modifying Ruu theme, not object class itself.
local Theme = InputField.theme:extend()
FilepathField.theme = Theme

-- Called from widget whenever text is changed.
function Theme.updateText(self)
	self.textObj.text = self.text
	Theme.updateTotalTextWidth(self)
	if self.isFocused then
		Theme.updateCursorPos(self)
	else
		local visibleOX = Theme.getCharXOffset(self, #self.text)
		Theme.scrollCharOffsetIntoView(self, visibleOX)
	end
end

function Theme.unfocus(self, isKeyboard)
	Theme.super.super.unfocus(self, isKeyboard)
	self.cursorObj:setVisible(false)
	self.selectionObj:setVisible(false)
	local visibleOX = Theme.getCharXOffset(self, #self.text)
	Theme.scrollCharOffsetIntoView(self, visibleOX)
end

return FilepathField
