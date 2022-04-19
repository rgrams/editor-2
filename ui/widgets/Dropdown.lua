
local Dropdown = gui.Column:extend()
Dropdown.className = "Dropdown"

local Ruu = require "ui.ruu.ruu"
local Button = require "ui.widgets.Button"

local spacing = 1
local pad = 2
local width = Button.width + pad*2

function Dropdown.set(self, x, y, returnFn, btnTexts)
	local height = #btnTexts * (Button.height + spacing) - spacing + pad*2
	Dropdown.super.set(self, spacing, false, -1, width, height, "NW", "NW")
	self:pad(pad, pad)

	-- Adjust position so the dropdown fits on screen.
	local winW, winH = love.graphics.getDimensions()
	local minX, minY = 0, 0
	local maxX, maxY = winW - width, winH - height
	x = math.max(minX, math.min(x, maxX))
	y = math.max(minY, math.min(y, maxY))
	self:setPos(x, y)

	self.returnFn = returnFn
	self.ruu = Ruu()
	self.children = {}
	for i,text in ipairs(btnTexts) do
		self:addButtonObject(text)
	end
end

function Dropdown.init(self)
	Dropdown.super.init(self)

	-- Initialize Ruu stuff.
	local wgtMap = {}
	for i,btn in ipairs(self.children) do
		local wgt = self.ruu:Button(btn, self.buttonClicked)
		btn.widget = wgt
		wgt:args(self, btn, wgt)
		table.insert(wgtMap, { wgt })
	end
	self.ruu:mapNeighbors(wgtMap)
	self.ruu:setFocus(self.children[1].widget)

	Input.enable(self)
end

function Dropdown.final(self)
	Input.disable(self)
end

function Dropdown.addButtonObject(self, btnText)
	local btn = Button(btnText)
	table.insert(self.children, btn)
end

function Dropdown.buttonClicked(self, btn, wgt)
	self:confirm(btn.text.text)
end

function Dropdown.confirm(self, text)
	self:close()
	if self.returnFn then
		self.returnFn(text)
	end
end

function Dropdown.close(self)
	self.tree:remove(self)
end

function Dropdown.input(self, action, value, change, ...)
	self.ruu:input(action, value, change, ...)
	if action == Ruu.CLICK and change == 1 then
		if not self.ruu.hoveredWidgets[1] then
			self:close()
		end
	elseif action == Ruu.CANCEL and change == 1 then
		self:close()
	end
	return true
end

function Dropdown.draw(self)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
end

return Dropdown
