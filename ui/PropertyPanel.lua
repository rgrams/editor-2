
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

local scenes = require "scenes"
local signals = require "signals"
local PanelTheme = require "ui.widgets.themes.PanelTheme"
local AddPropertyDialog = require "ui.AddPropertyDialog"

local headerFont = { "assets/font/OpenSans-Semibold.ttf", 17 }
local propClass = _G.propClassList

local spacing = 2

function PropertyPanel.set(self, ruu)
	PropertyPanel.super.set(self, spacing, false, nil, 250, 600, "E", "E", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Text("Properties", headerFont, 250, "C", "C", "center", "fill"),
	}
	self.layer = "gui"
	self.ruu = ruu
	self.widget = self.ruu:Panel(self, PanelTheme)
	self.widget.ruuInput = self.ruuInput
	self.wgtMap = {}

	self.lastProps = {}
	self.wgtForProp = {}

	local signalFn = self.onSelectedObjectsModified
	signals.subscribe(self, signalFn, "selection changed", "selected objects modified")
	signals.subscribe(self, self.onActiveSceneChanged, "active scene changed")
end

function PropertyPanel.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat)
	if action == "add property" and change == 1 then
		if scenes.active then
			local self = wgt.object
			local guiRoot = self.tree:get("/Window")
			local dialog = AddPropertyDialog(self.addProperty, { self })
			self.tree:add(dialog, guiRoot)
			return true
		end
	end
end

function PropertyPanel.addProperty(self, propType, propName)
	local selection = scenes.active.selection
	local enclosures = selection:copyList()
	if not enclosures or not enclosures[1] then
		enclosures = scenes.active.selfSelection
	end
	local Class = propClass:get(propType)
	scenes.active.history:perform("addSamePropertyToMultiple", self, enclosures, Class, propName)
	self:updateProperties(selection) -- We'll ignore the signal from ourself, so manually update.
end

local function addPropertyWidget(self, selection, name, Class, value, obj)
	local object = Class.WidgetClass(name, value, Class, obj)
	self.wgtForProp[name] = object
	self.tree:add(object, self)
	object:setSelection(selection)
	object:initRuu(self.ruu, self.wgtMap)
end

local function destroyPropertyWidget(self, object)
	self.wgtForProp[object.propertyName] = nil
	object:destroyRuu(self.wgtMap)
	self.tree:remove(object)
end

local function getPropertyWidget(self, name, Class)
	local object = self.wgtForProp[name]
	if object and object.propertyClass == Class then
		return object
	end
end

local function removePropertyWidget(self, name, Class)
	local object = getPropertyWidget(self, name, Class)
	if object then  destroyPropertyWidget(self, object)  end
end

function PropertyPanel.onActiveSceneChanged(self, sender)
	self:updateProperties(scenes.active.selection)
end

function PropertyPanel.onSelectedObjectsModified(self, sender)
	if sender ~= self then
		self:updateProperties(scenes.active.selection)
	end
end

function PropertyPanel.updateProperties(self, selection)
	if not selection or not selection[1] then
		-- If nothing else is selected, pretend we've selected the scene itself.
		selection = scenes.active.selfSelection
	end

	-- Get list of properties that all objects have in common.
	-- Need properties and value.
	local votesForName = {} -- Lookup table by name.
	local classForName = {} -- Lookup table by name.
	local commonProperties = {} -- [1] = { Class= , obj=, name= , value= }, [2]...

	-- Copy property list from the first object.
	local firstObj = selection[1][1]
	for i,property in ipairs(firstObj.properties) do
		local Class, name = getmetatable(property), property.name
		local value = property:getValue()
		table.insert(commonProperties, { Class = Class, obj = property, name = name, value = value })
		votesForName[name] = 1
		classForName[name] = Class
	end

	for i,prop in ipairs(self.lastProps) do
		if not votesForName[prop.name] or classForName[prop.name] ~= prop.Class then
			removePropertyWidget(self, prop.name, prop.Class)
		end
	end

	-- Loop through all other objects to check which properties are shared.
	for objI=2,#selection do
		local enclosure = selection[objI]
		local obj = enclosure[1]
		-- Loop once and "vote" for properties that this object has.
		for i,property in ipairs(obj.properties) do
			local name = property.name
			local votes = votesForName[name]
			if votes and classForName[name] == getmetatable(property) then
				votesForName[name] = votes + 1
			end
		end
	end

	-- If not all objects "voted" for a property, remove it from the list.
	local requiredVotes = #selection
	for i,propData in ipairs(commonProperties) do
		if votesForName[propData.name] < requiredVotes then
			removePropertyWidget(self, propData.name, propData.Class)
		else
			local object = getPropertyWidget(self, propData.name, propData.Class)
			if not object then
				addPropertyWidget(self, selection, propData.name, propData.Class, propData.value, propData.obj)
			else
				object:updateValue(propData.value)
			end
		end
	end

	-- Update the selection reference on each widget so they don't modify the wrong scene.
	for name,obj in pairs(self.wgtForProp) do
		obj:setSelection(selection)
	end

	self:allocateChildren()
	self.ruu:mapNextPrev(self.wgtMap)
	self.lastProps = commonProperties
end

function PropertyPanel.draw(self)
	local widget = self.widget
	if widget then
		widget.wgtTheme.draw(widget, self)
	end
end

return PropertyPanel
