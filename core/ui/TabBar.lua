
local TabBar = gui.Row:extend()
TabBar.className = "TabBar"

local scenes = require "core.scenes"
local signals = require "core.signals"
local Tab = require "core.ui.widgets.Tab"
local PanelTheme = require "core.ui.widgets.themes.PanelTheme"
local tabFont = new.font(unpack(Tab.font))
local maxTabTitleWidth = Tab.width - Tab.closeBtnWidth + 3

local spacing = 2
local width = 100
local height = 24

function TabBar.set(self, ruu)
	TabBar.super.set(self, spacing, false, -1, width, height)
	self:setMode("fill", "none")
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self, PanelTheme)
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
	local tab = Tab(TabBar.getTrimmedText(text))
	self.tree:add(tab, self)

	local closeWgt = tab.closeBtn:initRuu(self.ruu, self.tabCloseBtnPressed)

	local wgt = tab:initRuu(self.ruu, self.tabBtnPressed, self)
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

function TabBar.getTrimmedText(text)
	local t = text:sub(1, 16)
	while tabFont:getWidth(t) > maxTabTitleWidth do
		t = t:sub(1, -2)
	end
	return t
end

function TabBar.setTabText(self, scene, text)
	for i,wgt in ipairs(self.tabWidgets) do
		if wgt.scene == scene then
			wgt.object.text.text = text
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
	local widget = self.widget
	if widget then
		widget.theme.draw(widget, self)
	end
end

return TabBar
