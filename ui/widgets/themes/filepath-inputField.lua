
local defaultTheme = require("ui.ruu.defaultTheme").InputField

local theme = defaultTheme:extend()

-- Called from widget whenever text is changed.
function theme.updateText(self)
	self.textObj.text = self.text
	theme.updateTotalTextWidth(self)
	if self.isFocused then
		theme.updateCursorPos(self)
	else
		local visibleOX = theme.getCharXOffset(self, #self.text)
		theme.scrollCharOffsetIntoView(self, visibleOX)
	end
end

function theme.unfocus(self, isKeyboard)
	theme.super.super.unfocus(self, isKeyboard)
	self.cursorObj:setVisible(false)
	self.selectionObj:setVisible(false)
	local visibleOX = theme.getCharXOffset(self, #self.text)
	theme.scrollCharOffsetIntoView(self, visibleOX)
end

return theme
