
local Dropdown = gui.Column:extend()
Dropdown.className = "Dropdown"

local Ruu = require "ui.ruu.ruu"
local Button = require "ui.widgets.Button"
local MenuButtonTheme = require "ui.widgets.themes.MenuButtonTheme"

local spacing = 1
local pad = 2
local width = Button.width + pad*2

 -- item = { text=, fn=, args= }
function Dropdown.set(self, x, y, items, focusedIndex)
	self.initFocusIndex = focusedIndex or 1
	local height = #items * (Button.height + spacing) - spacing + pad*2

	local fnt = MenuButtonTheme.font
	local maxTextWidth = 0
	for i,item in ipairs(items) do
		local w = fnt:getWidth(item.text)
		if w >= maxTextWidth then  maxTextWidth = w  end
	end
	local width = maxTextWidth + pad*4 + 16

	Dropdown.super.set(self, spacing, false, -1, width, height, "NW", "NW")
	self:pad(pad, pad)
	self.layer = "dropdown"

	-- Adjust position so the dropdown fits on screen.
	local winW, winH = love.graphics.getDimensions()
	local minX, minY = 0, 0
	local maxX, maxY = winW - width, winH - height
	x = math.max(minX, math.min(x, maxX))
	y = math.max(minY, math.min(y, maxY))
	x, y = math.floor(x), math.floor(y)
	self:setPos(x, y)

	self.items = items
	self.ruu = Ruu()
	self.children = {}
	for i,item in ipairs(items) do
		self:addButtonObject(item.text)
	end
end

function Dropdown.init(self)
	-- Initialize Ruu stuff.
	local wgtMap = {}
	for i,btn in ipairs(self.children) do
		local wgt = self.ruu:Button(btn, self.confirm, MenuButtonTheme)
		btn.widget = wgt
		wgt:args(self, btn, wgt, self.items[i])
		table.insert(wgtMap, { wgt })
	end
	self.ruu:mapNeighbors(wgtMap)
	self.ruu:setFocus(self.children[self.initFocusIndex].widget)

	Dropdown.super.init(self)
	Input.enable(self)
end

function Dropdown.final(self)
	Input.disable(self)
end

function Dropdown.addButtonObject(self, btnText)
	local btn = Button(btnText, self.w - pad*2):mode("fill")
	btn.layer = "dropdown"
	btn.text.layer = "dropdown text"
	table.insert(self.children, btn)
end

function Dropdown.confirm(self, btn, wgt, item)
	self:close()
	if item.fn then
		item.fn(unpack(item.args))
	end
end

function Dropdown.close(self)
	self.tree:remove(self)
end

function Dropdown.input(self, action, value, change, ...)
	self.ruu:input(action, value, change, ...)
	if action == Ruu.CLICK and change == 1 then
		if not self.ruu.hoveredWgts[1] then
			self:close()
		end
	elseif action == Ruu.CANCEL and change == 1 then
		self:close()
	end
	return true
end

function Dropdown.draw(self)
	local w, h = self.w, self.h
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("line", -w/2-0.5, -h/2-0.5, w+1, h+1)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)
end

return Dropdown
