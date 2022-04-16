
local UI = gui.Row:extend()
UI.className = "UI"

local Ruu = require "ui.ruu.ruu"
local Viewport = require "ui.Viewport"
local PropertyPanel = require "ui.PropertyPanel"
local scenes = require "scenes"

function UI.set(self)
	local w, h = love.graphics.getDimensions()
	UI.super.set(self, 0, false, -1, w, h, "C", "C", "fill")
	self.layer = "gui"

	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})

	self.widget = self.ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput

	self.children = {
		Viewport(self.ruu),
		PropertyPanel(self.ruu)
	}

	self.propertyPanel = self.children[2]
end

function UI.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat)
	if action == "undo" and (change == 1 or isRepeat) then
		scenes.active.history:undo()
		wgt.object.propertyPanel:updateProperties(scenes.active.selection)
	elseif action == "redo" and (change == 1 or isRepeat) then
		scenes.active.history:redo()
		wgt.object.propertyPanel:updateProperties(scenes.active.selection)
	end
end

function UI.init(self)
	UI.super.init(self)
	Input.enable(self)
end

function UI.final(self)
	Input.disable(self)
end

function UI.input(self, action, value, change, ...)
	self.ruu:input(action, value, change, ...)
end

return UI
