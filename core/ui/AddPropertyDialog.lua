
local AddPropDialog = gui.Column:extend()

local Ruu = require "core.ui.ruu.ruu"
local Button = require "core.ui.widgets.Button"
local InputField = require "core.ui.widgets.InputField"
local Dropdown = require "core.ui.widgets.Dropdown"
local PanelTheme = require "core.ui.widgets.themes.PanelTheme"
local style = require "core.ui.style"

local spacing = 2

function AddPropDialog.set(self, callback, callbackArgs)
	AddPropDialog.super.set(self, spacing, false, nil, 400, 125)
	self.callback = callback
	self.callbackArgs = callbackArgs
	self:setPad(4, 4)
	self.children = {
		gui.Text("Add Property", style.titleFont, 250, "C", "C", "center", "fill"),
		gui.Node(10, 10),
		gui.Row(4, nil, nil, 100, 25):setPad(4, 0):setMode("fill"),
		gui.Node(10, 20),
		gui.Node(100, 25):setMode("fill")
	}
	self.children[1].color = style.titleTextColor
	local inputRow = self.children[3]
	local btnRow = self.children[5]
	self.inputFld = InputField("propertyName", 325)
	self.typeBtn = Button("float", 50, "center")
	inputRow.children = {
		self.inputFld,
		self.typeBtn,
	}
	self.cancelBtn = Button("Cancel", nil, "center"):setPivot("E"):setAnchor("C"):setPos(-4, 0)
	self.OKBtn = Button("OK", nil, "center"):setPivot("W"):setAnchor("C"):setPos(4, 0)
	btnRow.children = {
		self.cancelBtn,
		self.OKBtn,
	}
	self.layer = "gui"
	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})
	self.widget = self.ruu:Panel(self, PanelTheme)

	local inputWgt = self.inputFld:initRuu(self.ruu, self.inputConfirmed)
	inputWgt:args(self, inputWgt)
	local typeWgt = self.typeBtn:initRuu(self.ruu, self.typeBtnPressed)
	typeWgt:args(self, typeWgt)

	local cancelWgt = self.cancelBtn:initRuu(self.ruu, self.cancelBtnPressed, self)
	local OKWgt = self.OKBtn:initRuu(self.ruu, self.OKBtnPressed, self)

	self.wgtMap = { inputWgt, typeWgt, cancelWgt, OKWgt }
	self.ruu:mapNextPrev(self.wgtMap)

	self.typeDropdownItems = { -- item = { text=, fn=, args= }
		{ text = "float", fn = self.setType, args = {self, "float" } },
		{ text = "bool", fn = self.setType, args = {self, "bool" } },
		{ text = "vec2", fn = self.setType, args = {self, "vec2" } },
		{ text = "color", fn = self.setType, args = {self, "color" } },
		{ text = "string", fn = self.setType, args = {self, "string" } },
		{ text = "file", fn = self.setType, args = {self, "file" } },
		{ text = "script", fn = self.setType, args = {self, "script" } },
		{ text = "font", fn = self.setType, args = {self, "font" } },
		{ text = "object", fn = self.setType, args = {self, "object" } },
	}
end

function AddPropDialog.init(self)
	AddPropDialog.super.init(self)
	self.ruu:setFocus(self.inputFld.widget)
	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0) -- TODO: For some reason this doesn't work?
	Input.enable(self)
end

function AddPropDialog.final(self)
	Input.disable(self)
end

function AddPropDialog.close(self)
	self.tree:remove(self)
end

function AddPropDialog.confirm(self)
	local propType = self.typeBtn.text.text
	local propName = self.inputFld.widget.text
	self:close()
	if self.callback then
		local args = self.callbackArgs or {}
		table.insert(args, propType)
		table.insert(args, propName)
		self.callback(unpack(args))
	end
end

function AddPropDialog.input(self, action, value, change, ...)
	if action == Ruu.CANCEL and change == 1 then
		self:close()
	end
	self.ruu:input(action, value, change, ...)
	return true
end

function AddPropDialog.inputConfirmed(self, wgt)
	if wgt.isFocused then
		self:confirm()
	end
end

function AddPropDialog.typeBtnPressed(self, wgt)
	local btn = wgt.object
	local x, y = btn:toWorld(-btn.w/2, -btn.h/2)
	local dropdown = Dropdown(x, y, self.typeDropdownItems)
	local guiRoot = self.tree:get("/Window")
	self.tree:add(dropdown, guiRoot)
end

function AddPropDialog.setType(self, typeName)
	self.typeBtn.text.text = typeName
end

function AddPropDialog.cancelBtnPressed(self)
	self:close()
end

function AddPropDialog.OKBtnPressed(self)
	self:confirm()
end

function AddPropDialog.draw(self)
	local widget = self.widget
	if widget then
		widget.theme.draw(widget, self)
	end
end

return AddPropDialog
