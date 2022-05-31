
-- Just aligns text to right end when not in focus.

local InputFieldTheme = require(GetRequireFolder(...) .. "InputFieldTheme")
local FilepathFieldTheme = InputFieldTheme:extend()

-- Called from widget whenever text is changed.
function FilepathFieldTheme.updateText(self)
	self.textObj.text = self.text
	FilepathFieldTheme.updateTotalTextWidth(self)
	if self.isFocused then
		FilepathFieldTheme.updateCursorPos(self)
	else
		local visibleOX = FilepathFieldTheme.getCharXOffset(self, #self.text)
		FilepathFieldTheme.scrollCharOffsetIntoView(self, visibleOX)
	end
end

function FilepathFieldTheme.unfocus(self, isKeyboard)
	FilepathFieldTheme.super.super.unfocus(self, isKeyboard)
	self.cursorObj:setVisible(false)
	self.selectionObj:setVisible(false)
	local visibleOX = FilepathFieldTheme.getCharXOffset(self, #self.text)
	FilepathFieldTheme.scrollCharOffsetIntoView(self, visibleOX)
end

return FilepathFieldTheme
