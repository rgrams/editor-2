
local TabBar = gui.Row:extend()
TabBar.className = "TabBar"

local scenes = require "scenes"
local signals = require "signals"
local Tab = require "ui.widgets.Tab"
local TabTheme = require "ui.widgets.themes.TabTheme"
local TabCloseButtonTheme = require "ui.widgets.themes.TabCloseButtonTheme"

local spacing = 2
local width = 100
local height = 26

function TabBar.set(self, ruu)
	TabBar.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.tabWidgets = {}
	signals.subscribe(self, self.onSceneAdded, "scene added")
	signals.subscribe(self, self.onSceneRemoved, "scene removed")
	signals.subscribe(self, self.onActiveSceneChanged, "active scene changed")
end

function TabBar.onSceneAdded(self, sender, signal, scene)
	if sender == self then  return  end
	self:addTab(scene.name, scene)
end

function TabBar.onSceneRemoved(self, sender, signal, scene)
	if sender == self then  return  end
	self:removeTab(scene)
end

function TabBar.onActiveSceneChanged(self, sender, signal, scene)
	if sender == self then  return  end
	for i,wgt in ipairs(self.tabWidgets) do
		if wgt.scene == scene then
			wgt:setChecked(true)
		end
	end
end

function TabBar.addTab(self, text, scene)
	local tab = Tab(text)
	self.tree:add(tab, self)

	local closeWgt = self.ruu:Button(tab.closeBtn, self.tabCloseBtnPressed, TabCloseButtonTheme)

	local wgt = self.ruu:RadioButton(tab, self.tabBtnPressed, false, TabTheme)
	wgt.scene = scene
	wgt.closeWgt = closeWgt -- Used in TabBar.removeTab()
	wgt:args(self, wgt)
	closeWgt:args(self, wgt)

	table.insert(self.tabWidgets, wgt)
	self.ruu:groupRadioButtons(self.tabWidgets)
	self:allocateChildren()
end

function TabBar.removeTab(self, scene)
	for i,wgt in ipairs(self.tabWidgets) do
		if wgt.scene == scene then
			table.remove(self.tabWidgets, i)
			local wasDeletedWgtFocused = wgt.isFocused or wgt.closeWgt.isFocused
			self.ruu:destroy(wgt.closeWgt)
			self.ruu:destroy(wgt)
			if wasDeletedWgtFocused then
				self.ruu:setFocus(self.widget)
			end
			self.ruu:groupRadioButtons(self.tabWidgets)
			self.tree:remove(wgt.object)
			self:allocateChildren()
			return
		end
	end
end

function TabBar.tabBtnPressed(self, wgt)
	wgt:setChecked(true)
	scenes.setActive(wgt.scene, self)
end

function TabBar.tabCloseBtnPressed(self, wgt)
	self:removeTab(wgt.scene)
	scenes.remove(wgt.scene, self)
end

function TabBar.draw(self)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	if self.widget.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		w, h = w - lineWidth, h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return TabBar
