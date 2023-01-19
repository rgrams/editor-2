
local BaseClass = gui.Row:extend()
BaseClass.className = "BaseClass"

local style = require "core.ui.style"
local listRemove = require("core.lib.list").remove

BaseClass.font = style.buttonFont
BaseClass.labelColor = style.propertyTextColor
BaseClass.spacing = 2
BaseClass.width = 100
BaseClass.height = 26

function BaseClass.set(self, name, value, PropClass, propObj)
	BaseClass.super.set(self, self.spacing, false, -1, self.width, self.height)
	self:setMode("fill", "none")
	self.layer = "gui"
	self.propertyName = name
	self.propertyObj = propObj
	self.propertyClass = PropClass

	self.label = gui.Text(name, self.font, self.labelWidth or self.width, "W", "W", "left")
	self.label:setPos(2)
	self.label.color = self.labelColor
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

local objToStr = require "core.philtre.lib.object-to-string"

function BaseClass.ruuInput(wgt, depth, action, value, change)
	if action == "delete" and change == 1 then -- Deleting the property.
		local self = wgt.object
		editor.PropertyPanel:deleteProperty(self.propertyName, self.selection, self)
	elseif action == "right click" and change == 1 then -- For debugging -- TODO: Put info in tooltip.
		local self = wgt.object
		local prop = self.propertyObj
		print("right click on property widget", prop, prop.id)
		print("   default value: ", objToStr(prop.defaultValue))
		print("   isAtDefault: ", prop:isAtDefault())
	end
end

function BaseClass.initRuu(self, ruu, navList, baseWgtNavList)
	self.ruu = ruu
	self.widgetNavList = navList
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	table.insert(baseWgtNavList, self.panel)
	self.widgets = {}
	return self.panel
end

function BaseClass.registerWidget(self, wgt) -- Add to keyboard navigation lists.
	if not self.firstWidget then  self.firstWidget = wgt  end
	self.widgets[wgt] = true
	table.insert(self.widgetNavList, wgt)
	return wgt
end

--[[ Example for inheriting class:
function SubClass.initRuu(self, ruu, ...)
	SubClass.super.initRuu(self, ruu, ...)
	self.wgt = self.field:initRuu(self.ruu, self.onConfirm)
	self:registerWidget(self.wgt, self, self.wgt)
end
--]]

-- Destroy our Ruu widgets & remove them from parent's lists for keyboard navigation.
function BaseClass.destroyRuu(self, navList, baseWgtNavList)
	self.ruu:destroy(self.panel)
	listRemove(baseWgtNavList, self.panel)
	local widgets = self.widgets
	for i=#navList,1,-1 do
		local wgt = navList[i]
		if widgets[wgt] then
			widgets[wgt] = nil
			self.ruu:destroy(wgt)
			table.remove(navList, i)
			if not next(widgets) then
				break
			end
		end
	end
end

function BaseClass.isFocused(self)
	if self.ruu then
		if self.panel.isFocused then  return true  end
		for widget in pairs(self.widget) do
			if widget.isFocused then  return true  end
		end
	end
end

function BaseClass.focusFirstWidget(self)
	if self.ruu then  self.ruu:setFocus(self.firstWidget or self.panel)  end
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
