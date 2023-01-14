
local style = {}

local color = require "core.lib.color"

style.fontSize = 15
style.fontRegular = "core/assets/font/OpenSans-Semibold.ttf"
style.fontLight = "core/assets/font/OpenSans-Regular.ttf"
style.baseColor = { 0.22, 0.22, 0.22, 1 }
style.textColor = color.lighten( color.invert(style.baseColor), 0.02 )
style.titleTextColor = color.lighten(style.textColor, 0.2)
style.dimTextColor = color.darken(style.textColor, 0.3)

style.focusLineColor = color.lighten(style.textColor, 0.2)
style.textSelectColor = { 0.16, 0.44, 0.78, 1 }
style.textCursorColor = color.lighten(style.textColor, 0.2)

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

style.viewportBackgroundColor = color.darken(style.baseColor, 0.12 )-- 0.1
local bgCol = style.viewportBackgroundColor
style.gridColor = color.alpha( color.lighten(bgCol, 0.2), 0.06 )--{ 0.3, 0.3, 0.3, 0.06 }
style.bigGridColor = color.alpha( color.lighten(bgCol, 0.2), 0.28 )--{ 0.3, 0.3, 0.3, 0.28 }
style.gridNumberColor = color.alpha( color.lighten(bgCol, 0.4), 0.5 )--{ 0.5, 0.5, 0.5, 0.5 }
style.xAxisColor = color.darken(style.dimTextColor, 0.1)--{ 0.8, 0.4, 0.4, 0.2 }
style.xAxisColor[4] = 0.2
style.xAxisColor[1] = style.xAxisColor[1] + 0.4
style.yAxisColor = color.darken(style.dimTextColor, 0.1)--{ 0.4, 0.8, 0.4, 0.2 }
style.yAxisColor[4] = 0.2
style.yAxisColor[2] = style.yAxisColor[2] + 0.4

style.propertyTextColor = color.darken(style.textColor, 0.2)

style.buttonColor = color.lighten(style.baseColor, 0.1)
style.buttonHoverColor = color.lighten(style.buttonColor, 0.03)
style.buttonPressColor = color.lighten(style.buttonColor, 0.18)
style.buttonTextColor = style.textColor
style.buttonTextHoverColor = color.lighten(style.buttonTextColor, 0.2)
style.buttonBevelLighten = 0.15
style.buttonBevelHoverLighten = 0.25
style.buttonBevelDarken = style.buttonBevelLighten
style.buttonBevelDepth = 2

style.checkboxBGColor = color.darken(style.panelColor, 0.7)

style.inputFieldColor = color.darken(style.panelColor, 0.04)
style.inputFieldHoverColor = color.darken(style.inputFieldColor, 0.03)
style.inputFieldPressColor = color.darken(style.inputFieldColor, 0.08)
style.inputFieldTextColor = style.buttonTextHoverColor
style.inputFieldBevelLighten = style.buttonBevelLighten
style.inputFieldBevelHoverLighten = 0.20
style.inputFieldBevelDarken = style.buttonBevelLighten

style.tabNormalCheckColor = color.lighten(style.buttonColor, 0.15)
style.tabHoverCheckColor = color.lighten(style.buttonHoverColor, 0.15)
style.tabNormalUncheckColor = color.darken(style.buttonColor, 0.06)
style.tabHoverUncheckColor = color.darken(style.buttonHoverColor, 0.06)
style.tabPressColor = style.buttonPressColor

style.tabTextNormalCheckColor = color.lighten(style.buttonTextColor, 0.17)
style.tabTextHoverCheckColor = style.buttonTextHoverColor
style.tabTextNormalUncheckColor = color.darken(style.buttonTextColor, 0.15)
style.tabTextHoverUncheckColor = color.darken(style.buttonTextHoverColor, 0.15)

style.tabCloseHoverCheckColor = color.lighten(style.tabHoverCheckColor, 0.09)
style.tabCloseHoverUncheckColor = color.lighten(style.tabHoverUncheckColor, 0.09)
style.tabCloseTextNormalCheckColor = color.darken(style.buttonTextColor, 0.05)
style.tabCloseTextNormalUncheckColor = color.darken(style.buttonTextColor, 0.3)

style.dropdownEdgeColor = { 0, 0, 0, 1 }
style.dropdownBGColor = color.darken(style.panelColor, 0.02)

style.menuButtonColor = color.darken(style.buttonColor, 0.12)
style.menuButtonHoverColor = style.buttonHoverColor
style.menuButtonPressColor = color.darken(style.buttonPressColor, 0.1)

style.resizeHandleColor = color.darken(style.panelColor, 0.05)
style.resizeHandleHoverColor = color.lighten(style.panelColor, 0.08)
style.resizeHandlePressColor = style.buttonPressColor

return style
