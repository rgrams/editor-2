
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiSlice = EditorGuiNode:extend()
EditorGuiSlice.className = "EditorGuiSlice"
EditorGuiSlice.displayName = "GUI Slice"

_G.objClassList:add(EditorGuiSlice, EditorGuiSlice.displayName)

local PropData = require "core.commands.data.PropData"
local Image = require "core.objects.properties.Image"
local Vec4 = require "core.objects.properties.Vec4"
local Color = require "core.objects.properties.Color"

EditorGuiSlice.updateScale = gui.Slice.updateScale
EditorGuiSlice.updateInnerSize = gui.Slice.updateInnerSize

function EditorGuiSlice.set(self)
	EditorGuiSlice.super.set(self)
	self.margins = { lt = 2, rt = 2, top = 2, bot = 2 }
	self.designMargins = { lt = 2, rt = 2, top = 2, bot = 2 }
	self.color = { 1, 1, 1, 1 }
	self.blendMode = "alpha"
	self.innerQuadW, self.innerQuadH = self.w - 4, self.h - 4
	self.layer = "images"
end

function EditorGuiSlice.initProperties(self)
	EditorGuiSlice.super.initProperties(self)
	self:removeProperty("pad")
	self:addProperty(PropData("image", nil, Image, nil, true))
	self:addProperty(PropData("color", nil, Color, nil, true))
	self:addProperty(PropData("margins", { 2, 2, 2, 2 }, Vec4, nil, true))
	local margins = self:getPropertyObj("margins")
	margins.wgtFieldLabels = { "lt", "tp", "rt", "bt" }
end

local function updatePad(self)
	local pad = self:getPropertyObj("pad")
	if not pad or pad.typeName ~= "vec2" then
		local m = self.margins
		local oldX, oldY = self.padX, self.padY
		self.padX = (m.lt + m.rt)/2 -- Use slice margins for default padding.
		self.padY = (m.top + m.bot)/2
		if self.padX ~= oldX or self.padY ~= oldY then
			return true
		end
	end
end

function EditorGuiSlice.propertyWasSet(self, name, value, property)
	EditorGuiSlice.super.propertyWasSet(self, name, value, property)
	if name == "image" then
		self.image = property.image
		self:updateQuads()
		updatePad(self)
		if self:updateInnerSize(self.lastAlloc:unpack()) and self.tree then
			self:updateTransform()
			self:allocateChildren()
		end
	elseif name == "color" then
		self.color = property:getValue()
	elseif name == "margins" then
		local m = self.margins
		local m2 = property:getValue()
		m.lt, m.top, m.rt, m.bot = m2[1], m2[2], m2[3], m2[4]
		self:updateQuads()
		updatePad(self)
		if self:updateInnerSize(self.lastAlloc:unpack()) and self.tree then
			self:updateTransform()
			self:allocateChildren()
		end
	end
end

function EditorGuiSlice.updateQuads(self)
	if not self.image then  return  end

	local m = self.margins
	local imgW, imgH = self.image:getDimensions()

	local lt, top, rt, bot = 0, 0, imgW, imgH

	local innerLt, innerRt = lt + m.lt, rt - m.rt
	local innerTop, innerBot = top + m.top, bot - m.bot
	local innerW, innerH = imgW - m.lt - m.rt, imgH - m.top - m.bot
	self.innerQuadW, self.innerQuadH = innerW, innerH

	-- Make 4 corner quads.
	self.quadTl = new.quad(lt, top, m.lt, m.top, imgW, imgH)
	self.quadTr = new.quad(innerRt, top, m.rt, m.top, imgW, imgH)
	self.quadBl = new.quad(lt, innerBot, m.lt, m.bot, imgW, imgH)
	self.quadBr = new.quad(innerRt, innerBot, m.rt, m.bot, imgW, imgH)
	-- Make 4 edge quads.
	self.quadTop = new.quad(innerLt, top, innerW, m.top, imgW, imgH)
	self.quadBot = new.quad(innerLt, innerBot, innerW, m.bot, imgW, imgH)
	self.quadLt = new.quad(lt, innerTop, m.lt, innerH, imgW, imgH)
	self.quadRt = new.quad(innerRt, innerTop, m.rt, innerH, imgW, imgH)
	-- Make center quad.
	self.quadC = new.quad(innerLt, innerTop, innerW, innerH, imgW, imgH)
end

function EditorGuiSlice.draw(self)
	if self.image then
		gui.Slice.draw(self)
	else
		love.graphics.setColor(self.color)
		love.graphics.setLineStyle("smooth")
		love.graphics.line(-self.w*0.35, self.h*0.35, self.w*0.35, -self.h*0.35)
		love.graphics.setLineStyle("rough")
	end
	EditorGuiSlice.super.draw(self)

	love.graphics.setColor(0.7, 0.7, 0.7, 0.05)
	local w2, h2 = self.w/2, self.h/2
	local m = self.margins
	love.graphics.line(-w2+m.lt, -h2, -w2+m.lt, h2)
	love.graphics.line(w2-m.rt, -h2, w2-m.rt, h2)
	love.graphics.line(-w2, -h2+m.top, w2, -h2+m.top)
	love.graphics.line(-w2, h2-m.bot, w2, h2-m.bot)
end

return EditorGuiSlice
