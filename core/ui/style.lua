
local style = {}

local color = require "core.lib.color"

style.fontSize = 15
style.fontRegular = "core/assets/font/OpenSans-Semibold.ttf"
style.fontLight = "core/assets/font/OpenSans-Regular.ttf"
style.baseColor = { 0.22, 0.22, 0.22, 1 }
local v = color.getValue(style.baseColor)
color.raise, color.lower = color.lighten, color.darken
if v > 0.4 then
	color.raise, color.lower = color.lower, color.raise
end
style.textColor = color.raise( color.invert(style.baseColor), 0.02 )
style.titleTextColor = color.raise(style.textColor, 0.2)
style.dimTextColor = color.lower(style.textColor, 0.3)

style.focusLineColor = color.raise(style.textColor, 0.2)
style.textSelectColor = { 0.16, 0.44, 0.78, 1 }
style.textCursorColor = color.raise(style.textColor, 0.2)

style.panelColor = style.baseColor
style.panelBevelLighten = 0.1
style.panelBevelDarken = 0.1
style.panelBevelDepth = 1

style.titleFont = { style.fontRegular, style.fontSize + 2 }
style.gridFont = { style.fontLight, style.fontSize - 3 }
style.inputFieldFont = { style.fontLight, style.fontSize - 1 }
style.menuButtonFont = { style.fontLight, style.fontSize - 2 }
style.textFont = { style.fontLight, style.fontSize - 2 } -- Messagebox message text.
style.tabFont = { style.fontRegular, style.fontSize - 2 }
style.propertySubLabelFont = { style.fontLight, style.fontSize - 3 }
style.buttonFont = { style.fontRegular, style.fontSize }

style.viewportBackgroundColor = color.lower(style.baseColor, 0.12 )-- 0.1
local bgCol = style.viewportBackgroundColor
style.gridColor = color.alpha( color.raise(bgCol, 0.2), 0.06 )--{ 0.3, 0.3, 0.3, 0.06 }
style.bigGridColor = color.alpha( color.raise(bgCol, 0.2), 0.28 )--{ 0.3, 0.3, 0.3, 0.28 }
style.gridNumberColor = color.alpha( color.raise(bgCol, 0.4), 0.5 )--{ 0.5, 0.5, 0.5, 0.5 }
style.xAxisColor = color.lower(style.dimTextColor, 0.1)--{ 0.8, 0.4, 0.4, 0.2 }
style.xAxisColor[4] = 0.2
style.xAxisColor[1] = style.xAxisColor[1] + 0.4
style.yAxisColor = color.lower(style.dimTextColor, 0.1)--{ 0.4, 0.8, 0.4, 0.2 }
style.yAxisColor[4] = 0.2
style.yAxisColor[2] = style.yAxisColor[2] + 0.4

style.propertyTextColor = color.lower(style.textColor, 0.2)

style.buttonColor = color.raise(style.baseColor, 0.1)
style.buttonHoverColor = color.raise(style.buttonColor, 0.03)
style.buttonPressColor = color.raise(style.buttonColor, 0.18)
style.buttonTextColor = style.textColor
style.buttonTextHoverColor = color.raise(style.buttonTextColor, 0.2)
style.buttonBevelLighten = 0.15
style.buttonBevelHoverLighten = 0.25
style.buttonBevelDarken = style.buttonBevelLighten
style.buttonBevelDepth = 2

style.checkboxBGColor = color.lower(style.panelColor, 0.7)

style.inputFieldColor = color.lower(style.panelColor, 0.04)
style.inputFieldHoverColor = color.lower(style.inputFieldColor, 0.03)
style.inputFieldPressColor = color.lower(style.inputFieldColor, 0.08)
style.inputFieldTextColor = style.buttonTextHoverColor
style.inputFieldBevelLighten = style.buttonBevelLighten
style.inputFieldBevelHoverLighten = 0.20
style.inputFieldBevelDarken = style.buttonBevelLighten

style.tabNormalCheckColor = color.raise(style.buttonColor, 0.15)
style.tabHoverCheckColor = color.raise(style.buttonHoverColor, 0.15)
style.tabNormalUncheckColor = color.lower(style.buttonColor, 0.06)
style.tabHoverUncheckColor = color.lower(style.buttonHoverColor, 0.06)
style.tabPressColor = style.buttonPressColor

style.tabTextNormalCheckColor = color.raise(style.buttonTextColor, 0.17)
style.tabTextHoverCheckColor = style.buttonTextHoverColor
style.tabTextNormalUncheckColor = color.lower(style.buttonTextColor, 0.15)
style.tabTextHoverUncheckColor = color.lower(style.buttonTextHoverColor, 0.15)

style.tabCloseHoverCheckColor = color.raise(style.tabHoverCheckColor, 0.09)
style.tabCloseHoverUncheckColor = color.raise(style.tabHoverUncheckColor, 0.09)
style.tabCloseTextNormalCheckColor = color.lower(style.buttonTextColor, 0.05)
style.tabCloseTextNormalUncheckColor = color.lower(style.buttonTextColor, 0.3)

style.dropdownEdgeColor = { 0, 0, 0, 1 }
style.dropdownBGColor = color.lower(style.panelColor, 0.02)

style.menuButtonColor = color.lower(style.buttonColor, 0.12)
style.menuButtonHoverColor = style.buttonHoverColor
style.menuButtonPressColor = color.lower(style.buttonPressColor, 0.1)

style.resizeHandleColor = color.lower(style.panelColor, 0.05)
style.resizeHandleHoverColor = color.raise(style.panelColor, 0.08)
style.resizeHandlePressColor = style.buttonPressColor

return style
