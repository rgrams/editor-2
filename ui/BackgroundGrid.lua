
local BackgroundGrid = Object:extend()
BackgroundGrid.className = "BackgroundGrid"

-- local fnt = require "theme.fonts"
local config = require "config"

local fnt = { "assets/font/OpenSans-Regular.ttf", 12 }

local gridColor = config.gridColor
local emphasizeColor = config.bigGridColor
local numberColor = config.gridNumberColor
local yAxisColor = config.yAxisColor
local xAxisColor = config.xAxisColor

local maxGridLines = 48

function BackgroundGrid.set(self)
	BackgroundGrid.super.set(self)
	self.layer = "background"
	self.font = new.font(unpack(fnt))
end

local function nextLargerPower(x, base)
	if x < 1 then
		return 0
	else
		return math.ceil(math.log(x)/math.log(base))
	end
end

local function roundUpToPower(x, base)
	return math.pow(base, nextLargerPower(x, base))
end

function BackgroundGrid.draw(self)
	local vp = Camera.current.vp
	local w_lt, w_top = Camera.current:screenToWorld(vp.x, vp.y)
	local w_rt, w_bot = Camera.current:screenToWorld(vp.w, vp.h)
	local w_w, w_h = w_rt - w_lt, w_bot - w_top

	local snapIncr = config.translateSnapIncrement
	local scale = 1 / Camera.current.zoom

	local minSize = math.max(w_w, w_h) / maxGridLines
	local n = roundUpToPower(minSize / snapIncr, config.gridPower)
	local s = snapIncr * n -- Grid cell world-size.
	local pad = s / 12 -- Number text padding/offset

	-- Grid-increment bounds.
	local lt, rt = math.floor(w_lt / s), math.ceil(w_rt / s)
	local top, bot = math.floor(w_top / s), math.ceil(w_bot / s)

	love.graphics.setLineWidth(scale)
	love.graphics.setFont(self.font)

	local emphasizeEvery = config.gridEmphasizeEvery

	-- Vertical lines
	for x=lt,rt do
		if x % emphasizeEvery ~= 0 then
			love.graphics.setColor(gridColor)
		else
			love.graphics.setColor(numberColor)
			love.graphics.print(x*s, x*s + pad, pad, 0, scale) -- ( text, x, y, r, sx)
			love.graphics.print(x*s, x*s + pad, w_bot - 24*scale - pad, 0, scale)
			love.graphics.setColor(emphasizeColor)
		end
		love.graphics.line(x*s, top*s, x*s, bot*s)
	end

	-- Horizontal lines
	for y=top,bot do
		if y % emphasizeEvery ~= 0 then
			love.graphics.setColor(gridColor)
		else
			love.graphics.setColor(numberColor)
			love.graphics.print(y*s, pad, y*s + pad, 0, scale) -- ( text, x, y, r, sx)
			love.graphics.print(y*s, w_lt + pad, y*s + pad, 0, scale)
			love.graphics.setColor(emphasizeColor)
		end
		love.graphics.line(lt*s, y*s, rt*s, y*s)
	end

	-- Draw origin axis lines.
	love.graphics.setColor(yAxisColor)
	love.graphics.line(0, w_top, 0, w_bot)
	love.graphics.setColor(xAxisColor)
	love.graphics.line(w_lt, 0, w_rt, 0)

	love.graphics.setLineWidth(1)
end

return BackgroundGrid
