
local UI = gui.Column:extend()
UI.className = "UI"

local Ruu = require "core.ui.ruu.ruu"
local Toolbar = require "core.ui.Toolbar"
local TabBar = require "core.ui.TabBar"
local Viewport = require "core.ui.Viewport"
local PropertyPanel = require "core.ui.PropertyPanel"
local ResizeHandle = require "core.ui.widgets.ResizeHandle"
local updateSceneTitleScript = require "core.ui.updateSceneTitle_script"

Ruu.isHoverAction["pan camera"] = true
Ruu.isHoverAction["right click"] = true

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, 0, false, -1, w, h, "C", "C", "fill")
	self.layer = "viewport"

	self.ruu = Ruu()
	self.ruu:registerLayers({"viewport", "gui"}) -- Bottom to top.

	self.widget = self.ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.scripts = { updateSceneTitleScript }
end

function UI.fromData(Class, data)
	return Class()
end

function UI.init(self)
	UI.super.init(self)

	local mainRow = self.children[2]
	local vpCol = mainRow.children[1]

	local toolbar = self.children[1]
	local tabBar = vpCol.children[1]
	local viewport = vpCol.children[2]
	local resizeHandle = mainRow.children[2]
	self.propertyPanel = mainRow.children[3]
	_G.editor.UI = self
	_G.editor.Viewport = viewport
	_G.editor.PropertyPanel = self.propertyPanel

	toolbar:initRuu(self.ruu)
	tabBar:initRuu(self.ruu)
	viewport:initRuu(self.ruu)
	resizeHandle:initRuu(self.ruu)
	self.propertyPanel:initRuu(self.ruu)

	self.inputMap = _G.editor._registerInputContext(self)
	Input.enable(self)
	self.ruu:mouseMoved(love.mouse.getPosition()) -- NOTE: Always gives 0, 0 :/
end

function UI.final(self)
	Input.disable(self)
end

function UI.input(self, action, value, change, rawChange, isRepeat, ...)
	local r = self.ruu:input(action, value, change, rawChange, isRepeat, ...)
	if r then  return r  end

	editor.handleInputsForMap(self.inputMap, action, value, change, rawChange, isRepeat, ...)
end

return UI
