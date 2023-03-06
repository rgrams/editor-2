
local Toolbar = gui.Row:extend()

local config = require "core.config"
local style = require "core.ui.style"
local InputField = require "core.ui.widgets.InputField"
local Checkbox = require "core.ui.widgets.Checkbox"
local PanelTheme = require "core.ui.widgets.themes.PanelTheme"

local spacing = 4
local width = 100
local height = 26

local labelFont = { "core/assets/font/OpenSans-Semibold.ttf", 12 }

-- TODO: wrap this all into a labeled inputField class. (just a Node as root)
local function addLabel(text, childList, w)
	local label = gui.Text(text, labelFont, w or 50, "NW", "NW"):setPos(0, 3)
	label.color = style.textColor
	table.insert(childList, label)
	return label
end

local function addField(text, childList, w)
	local field = InputField(text, w or 40):setAnchor("NW"):setPivot("NW")
	table.insert(childList, field)
	return field
end

local function addCheckbox(childList)
	local cb = Checkbox()
	table.insert(childList, cb)
	return cb
end

function Toolbar.set(self)
	Toolbar.super.set(self, spacing, false, -1, width, height)
	self:setMode("fill", "none")
	self:setPad(4, 1)
	self.layer = "gui"
	self.children =  {}

	addLabel("snap to: ", self.children)
	self.snapField = addField(config.translateSnapIncrement, self.children)
	addLabel("snap mode: ", self.children, 65)
	self.snapModeBox = addCheckbox(self.children)
end

function Toolbar.fromData(Class, data)
	return Class()
end

function Toolbar.initRuu(self, ruu)
	self.ruu = ruu
	self.widget = ruu:Panel(self, PanelTheme)
	local snapWgt = self.snapField:initRuu(self.ruu, self.snapIncrementSet)
	snapWgt:args(self, snapWgt)
	local snapCheckWgt = self.snapModeBox:initRuu(self.ruu, self.snapModeSet, config.snapModeEnabled)
	snapCheckWgt:args(self, snapCheckWgt)
end

function Toolbar.snapIncrementSet(self, wgt)
	local value = tonumber(wgt.text)
	if not value then  return true  end
	config.translateSnapIncrement = value
end

function Toolbar.snapModeSet(self, wgt)
	config.snapModeEnabled = wgt.isChecked
end

function Toolbar.draw(self)
	local widget = self.widget
	if widget then
		widget.theme.draw(widget, self)
	end
end

return Toolbar
