
local BaseClass = gui.Row:extend()
BaseClass.className = "BaseClass"

BaseClass.font = { "assets/font/OpenSans-Semibold.ttf", 15 }
BaseClass.spacing = 2
BaseClass.width = 100
BaseClass.height = 26

function BaseClass.set(self, name, value, PropClass)
	BaseClass.super.set(self, self.spacing, false, -1, self.width, self.height)
	self:mode("fill", "none")
	self.layer = "gui"
	self.propertyName = name

	self.label = gui.Text(name, self.font, self.labelWidth or self.width, "W", "W", "left")
	self.label:setPos(2)
	self.label.color = { 0.6, 0.6, 0.6, 1 }
	self.label.isGreedy = true
	self.children = { self.label }

	self.value = value

	-- Inheriting classes will create widget objects and insert them into children table.
	-- self.field = InputField(self.value)
	-- table.insert(self.children, self.field)
end

function BaseClass.setSelection(self, selection)
	self.selection = selection
end

function BaseClass.ruuInput(wgt, depth, action, value, change)
	-- Deleting the property.
	if action == "delete" and change == 1 then
		local self = wgt.object
		if not self.selection then
			print("Error: PropertyWidget["..self.className.."].delete - No selection known.")
		else
			local scene = self.selection.scene
			local cmd = "removeSamePropertyFromMultiple"
			local enclosures = self.selection:copyList()
			scene.history:perform(cmd, enclosures, self.propertyName)
			local propertyPanel = self.tree:get("/Window/UI/PropertyPanel")
			propertyPanel:updateProperties(self.selection)
		end
	end
end

function BaseClass.onConfirm(self, wgt)
	if wgt.text == wgt.oldText then
		return
	end
	local value = tonumber(wgt.text)
	if not value then
		return true -- Reject input.
	end
	if not self.selection then
		print("Error: PropertyWidget[BaseClass].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		scene.history:perform(cmd, enclosures, self.propertyName, value)
	end
end

function BaseClass.initRuu(self, ruu, navList)
	self.ruu = ruu
	self.widgetNavList = navList
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	self.widgets = {}
end

function BaseClass.addWidget(self, wgt)
	self.widgets[wgt] = true
	table.insert(self.widgetNavList, wgt)
	return wgt
end

--[[ Example for inheriting class:
function SubClass.initRuu(self, ruu, navList)
	SubClass.super.initRuu(self, ruu, navList)
	self.wgt = self.ruu:InputField(self.field, self.onConfirm, self.value)
	self:addWidget(self.wgt, self, self.wgt)
end
--]]

function BaseClass.destroyRuu(self, navList)
	self.ruu:destroy(self.panel) -- Panel is not in navigation navList.
	for i=#navList,1,-1 do
		local wgt = navList[i]
		if self.widgets[wgt] then
			self.widgets[wgt] = nil
			self.ruu:destroy(wgt)
			table.remove(navList, i)
			if not next(self.widgets) then
				break
			end
		end
	end
end

function BaseClass.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return BaseClass
