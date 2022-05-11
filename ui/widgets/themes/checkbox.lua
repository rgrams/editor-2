
local defaultTheme = require("ui.ruu.defaultTheme").Button
local theme = defaultTheme:extend()

function theme.init(self, themeData)
	theme.super.init(self, themeData)
	self.object.isChecked = self.isChecked
end

function theme.release(self, dontFire, mx, my, isKeyboard)
	theme.super.release(self, dontFire, mx, my, isKeyboard)
	self.object.isChecked = self.isChecked
end

function theme.setChecked(self, isChecked)
	self.object.isChecked = self.isChecked
end

return theme
