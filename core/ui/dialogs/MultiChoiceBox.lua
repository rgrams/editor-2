
local DialogBox = require "core.ui.dialogs.DialogBox"
local MultiChoiceBox = DialogBox:extend()

local Button = require "core.ui.widgets.Button"
local Dropdown = require "core.ui.widgets.Dropdown"

local dropdownWidth = 350

function MultiChoiceBox.set(self, choices, callback, title, msg, x, y)
	self.choices = choices
	self.callback = callback
	self.msg = msg
	-- TODO: Adjust size to fit msg if it exists.
	self.choice = choices[1]
	MultiChoiceBox.super.set(self, title, x, y)
end

function MultiChoiceBox.addContent(self, contentBox)
	-- TODO: Add textNode for msg if it exists.

	-- Generate dropdown items array.
	local items = {}
	for i,choice in ipairs(self.choices) do
		items[i] = { text = choice, fn = self.choiceSelected, args = { self, choice } }
	end
	self.dropdownItems = items

	-- Add dropdown button.
	self.dropdownBtn = Button(self.choices[1], dropdownWidth, "center")
	self.dropdownBtn:initRuu(self.ruu, self.dropdownBtnPressed, self)
	contentBox.children = { self.dropdownBtn }
end

function MultiChoiceBox.addButtons(self, buttonBox)
	self.cancelBtn = Button("Cancel", nil, "center")
	self.cancelBtn:setPivot("E"):setPos(-15, 0)
	self.cancelBtn:initRuu(self.ruu, self.cancel, self)

	self.okBtn = Button("OK", nil, "center")
	self.okBtn:setPivot("W"):setPos(15, 0)
	self.okBtn:initRuu(self.ruu, self.okBtnPressed, self)

	buttonBox.children = { self.cancelBtn, self.okBtn }
end

function MultiChoiceBox.init(self)
	MultiChoiceBox.super.init(self)

	-- map buttons.
	local map = { self.dropdownBtn.widget, self.cancelBtn.widget, self.okBtn.widget }
	self.ruu:mapNextPrev(map)
	self.ruu:setFocus(self.dropdownBtn.widget)
end

function MultiChoiceBox.close(self)
	MultiChoiceBox.super.close(self)
	self.callback(self.choice)
end

function MultiChoiceBox.cancel(self)
	self.choice = nil
	self:close()
end

local function getChoiceIndex(self, choice)
	for i,v in ipairs(self.choices) do
		if v == choice then
			return i
		end
	end
end

function MultiChoiceBox.dropdownBtnPressed(self)
	local btn = self.dropdownBtn
	local x, y = btn:toWorld(-btn.w/2, -btn.h/2)
	local focusedIndex = getChoiceIndex(self, self.choice)
	local dropdown = Dropdown(x, y, self.dropdownItems, focusedIndex)
	dropdown:setSize(dropdownWidth, nil, true)
	local guiRoot = self.tree:get("/Window")
	self.tree:add(dropdown, guiRoot)
end

function MultiChoiceBox.choiceSelected(self, choice)
	self.choice = choice
	self.dropdownBtn.text.text = choice
end

function MultiChoiceBox.okBtnPressed(self)
	self:close()
end

return MultiChoiceBox
