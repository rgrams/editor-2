
local script = {}

local config = require "core.config"
local PropData = require "core.commands.data.PropData"
local EditorObject = require "core.objects.EditorObject"
local Circle = require "core.objects.EditorCircle"
local Rectangle = require "core.objects.EditorRectangle"
local Polygon = require "core.objects.EditorPolygon"
local Float = require "core.objects.properties.Property"
local Bool = require "core.objects.properties.Bool"
local Vec2 = require "core.objects.properties.Vec2"
local Color = require "core.objects.properties.Color"

local function drawHover(self)
	local oldLineStyle = love.graphics.getLineStyle()
	love.graphics.setLineStyle("rough")

	local pad = 2
	local w, h = self.hitWidth + pad*2, self.hitHeight + pad*2
	local ox, oy = self.hitOX or 0, self.hitOY or 0
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("line", ox - w/2, oy - h/2, w, h)

	love.graphics.setLineStyle(oldLineStyle)
end

local function drawAxes(self)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)
end

local function circleDraw(self)
	love.graphics.setLineStyle("smooth")

	local r = self.radius
	local segments = self:getProperty("segments")
	local lineWidth = self:getProperty("lineWidth")
	local isFilled = self:getProperty("isFilled")
	local color = self:getProperty("color")

	love.graphics.push()
	love.graphics.rotate(-math.pi/2) -- Orient low-poly circles pointing up.

	love.graphics.setLineWidth(lineWidth)
	love.graphics.setColor(color)
	do
		local r = r
		if not isFilled then  r = r - lineWidth/2  end -- Lines are -inside- radius.
		love.graphics.circle(isFilled and "fill" or "line", 0, 0, r, segments)
	end
	love.graphics.setLineWidth(1)

	if self.isHovered then  drawHover(self)  end

	love.graphics.pop()

	drawAxes(self)

	EditorObject.drawParentChildLines(self)

	love.graphics.setLineStyle("rough")
end

local function rectangleDraw(self)
	love.graphics.setBlendMode("alpha")
	love.graphics.setLineStyle("smooth")

	local lineWidth = self:getProperty("lineWidth")
	local isFilled = self:getProperty("isFilled")
	local color = self:getProperty("color")
	local rx = self:getProperty("roundX")
	local ry = self:getProperty("roundY")
	local seg = self:getProperty("roundSegments")

	love.graphics.setLineWidth(lineWidth)
	love.graphics.setColor(color)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	if not isFilled then
		hw, hh = hw - lineWidth/2, hh - lineWidth/2 -- Lines are -inside- bounds.
	end
	love.graphics.rectangle(isFilled and "fill" or "line", -hw, -hh, hw*2, hh*2, rx, ry, seg)
	love.graphics.setLineWidth(1)

	if self.isHovered then  drawHover(self)  end

	drawAxes(self)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

local function polygonDraw(self)
	love.graphics.setLineStyle("smooth")

	local lineWidth = self:getProperty("lineWidth")
	local isFilled = self:getProperty("isFilled")
	local color = self:getProperty("color")

	local verts = self:getProperty("vertices")
	local isLoop = self:getProperty("isLoop")
	local vertCount = #verts/2

	if self.isHovered then  drawHover(self)  end

	drawAxes(self)

	love.graphics.setColor(color)
	love.graphics.setLineWidth(lineWidth)

	if isLoop and vertCount >= 3 then
		-- NOTE: Polygon line will be centered on verts, not inside (because that seemed excessively complex).
		love.graphics.polygon(isFilled and "fill" or "line", verts)
	elseif vertCount >= 2 then
		love.graphics.line(verts)
	elseif vertCount == 1 then
		love.graphics.circle("fill", verts[1], verts[2], 1, 8)
	end

	love.graphics.setLineWidth(1)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

function script.editor_script_added(self, name, filepath, scr)
	if scr ~= script then  return  end -- Don't care about other scripts being added.
	self._oldDraw = self.draw
	local color = { 1, 1, 1, 1 }
	if self:is(Circle) then
		local scale = { x = 1, y = 1 }
		self:addProperty(PropData("angle", nil, Float))
		self:addProperty(PropData("scale", scale, Vec2, scale))
		self:addProperty(PropData("skew", nil, Vec2))
		self:addProperty(PropData("segments", 24, Float, 24))
		self:addProperty(PropData("lineWidth", 1, Float, 1, true))
		self:addProperty(PropData("isFilled", true, Bool, true))
		self:addProperty(PropData("color", color, Color, color))
		self.draw = circleDraw
	elseif self:is(Rectangle) then
		self:addProperty(PropData("skew", nil, Vec2))
		self:addProperty(PropData("lineWidth", 1, Float, 1))
		self:addProperty(PropData("isFilled", true, Bool, true))
		self:addProperty(PropData("color", color, Color, color))
		self:addProperty(PropData("roundX", 0, Float))
		self:addProperty(PropData("roundY", 0, Float))
		self:addProperty(PropData("roundSegments", 2, Float, 2))
		self.draw = rectangleDraw
	elseif self:is(Polygon) then
		self:addProperty(PropData("lineWidth", 1, Float, 1))
		self:addProperty(PropData("isFilled", true, Bool, true))
		self:addProperty(PropData("color", color, Color, color))
		self.draw = polygonDraw
	end
end

function script.editor_script_removed(self, name, filepath, scr)
	if scr ~= script then  return  end -- Don't care about other scripts being removed.
	self.draw = self._oldDraw
	if self:is(Circle) then
		self:removeProperty("angle")
		self:removeProperty("scale")
		self:removeProperty("skew")
		self:removeProperty("segments")
		self:removeProperty("lineWidth")
		self:removeProperty("isFilled")
		self:removeProperty("color")
	elseif self:is(Rectangle) then
		self:removeProperty("skew")
		self:removeProperty("lineWidth")
		self:removeProperty("isFilled")
		self:removeProperty("color")
		self:removeProperty("roundX")self:removeProperty("lineWidth")
		self:removeProperty("isFilled")
		self:removeProperty("color")
		self:removeProperty("roundY")
		self:removeProperty("roundSegments")
	elseif self:is(Polygon) then
		self:removeProperty("lineWidth")
		self:removeProperty("isFilled")
		self:removeProperty("color")
	end
end

return script
