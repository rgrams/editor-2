
-- (Mostly) Empty theme class to inherit from so none of the basic callbacks will be missing.

local Class = require "philtre.modules.base-class"
local EmptyTheme = Class:extend()

function EmptyTheme.setValue(color, val)
	color[1], color[2], color[3] = val, val, val
end

function EmptyTheme.init(self, themeData)
	self.object = themeData
end

function EmptyTheme.hover(self)  end
function EmptyTheme.unhover(self)  end
function EmptyTheme.focus(self, isKeyboard)  end
function EmptyTheme.unfocus(self, isKeyboard)  end
function EmptyTheme.press(self, mx, my, isKeyboard)  end
function EmptyTheme.release(self, dontFire, mx, my, isKeyboard)  end

function EmptyTheme.draw(self)  end

return EmptyTheme
