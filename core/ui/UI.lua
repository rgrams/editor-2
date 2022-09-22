
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

	local vpCol = gui.Column(0, false, -1, 100, 100, "C", "C", "fill")
	vpCol.name = "VPColumn"
	vpCol.isGreedy = true
	vpCol.children = {
		TabBar(self.ruu),
		Viewport(self.ruu),
	}

	local mainRow = gui.Row(0, false, -1, 50, 50, "C", "C", "fill")
	mainRow.name = "MainRow"
	mainRow.isGreedy = true
	mainRow.children = {
		vpCol,
		ResizeHandle("/Window/UI/MainRow/PropertyPanel"),
		PropertyPanel(self.ruu)
	}

	self.children = {
		Toolbar(self.ruu),
		mainRow,
	}

	mainRow.children[2]:initRuu(self.ruu)

	self.propertyPanel = mainRow.children[3]

	self.scripts = { updateSceneTitleScript }

	_G.editor.UI = self
	_G.editor.Viewport = vpCol.children[2]
	_G.editor.PropertyPanel = self.propertyPanel
end

function UI.init(self)
	UI.super.init(self)
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

	if isRepeat and self.inputMap._callOnRepeat[action] then
		local editorAction = self.inputMap[action]
		if editorAction then  return editor.runAction(editorAction)  end
	elseif change == 1 then
		local editorAction = self.inputMap[action]
		if editorAction then  return editor.runAction(editorAction)  end
	end
end

return UI