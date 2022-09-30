
local Toolbar = gui.Row:extend()

local config = require "core.config"
local InputField = require "core.ui.widgets.InputField"
local PanelTheme = require "core.ui.widgets.themes.PanelTheme"
local InputFieldTheme = require "core.ui.widgets.themes.InputFieldTheme"

local spacing = 2
local width = 100
local height = 26

function Toolbar.set(self, ruu)
	Toolbar.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self:pad(4, 1)
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self, PanelTheme)
	self.children =  {}

	-- TODO: wrap this all into a labeled inputField class. (just a Node as root)
	local snapIncr = config.translateSnapIncrement
	local font = { "core/assets/font/OpenSans-Semibold.ttf", 12 }
	local snapLabel = gui.Text("snap to:", font, 50, "NW", "NW")
	snapLabel:setPos(0, 3)
	snapLabel.color[4] = 0.5
	table.insert(self.children, snapLabel)
	local snapField = InputField(snapIncr, 40)
	table.insert(self.children, snapField)
	snapField:anchor("NW"):pivot("NW")
	local snapWgt = self.ruu:InputField(snapField, self.snapIncrementSet, snapIncr, InputFieldTheme)
	snapWgt:args(self, snapWgt)
end

function Toolbar.snapIncrementSet(self, wgt)
	local value = tonumber(wgt.text)
	if not value then  return true  end
	config.translateSnapIncrement = value
end

function Toolbar.draw(self)
	local widget = self.widget
	if widget then
		widget.theme.draw(widget, self)
	end
end

return Toolbar
