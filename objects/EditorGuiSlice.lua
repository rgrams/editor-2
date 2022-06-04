
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiSlice = EditorGuiNode:extend()
EditorGuiSlice.className = "EditorGuiSlice"

EditorGuiSlice.displayName = "GUI Slice"

_G.objClassList:add(EditorGuiSlice, EditorGuiSlice.displayName)

local Image = require "objects.properties.Image"
local Vec4 = require "objects.properties.Vec4"
local Color = require "objects.properties.Color"

EditorGuiNode.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
	skew = true,
	pivot = true,
	anchor = true,
	modeX = true,
	modeY = true,
	pad = true,
	image = true,
	color = true,
	margins = true,
}

EditorGuiSlice.updateScale = gui.Slice.updateScale
EditorGuiSlice.updateInnerSize = gui.Slice.updateInnerSize

function EditorGuiSlice.set(self)
	EditorGuiSlice.super.set(self)
	self.margins = { lt = 2, rt = 2, top = 2, bot = 2 }
	self.designMargins = { lt = 2, rt = 2, top = 2, bot = 2 }
	self.color = { 1, 1, 1, 1 }
	self.blendMode = "alpha"
	self.innerQuadW, self.innerQuadH = self.w - 4, self.h - 4
end

function EditorGuiSlice.initProperties(self)
	EditorGuiSlice.super.initProperties(self)
	self:addProperty(Image, "image")
	self:addProperty(Color, "color")
	self:addProperty(Vec4, "margins", { 2, 2, 2, 2 }, true)
	local margins = self:getPropertyObj("margins")
	margins.wgtFieldLabels = { "lt", "tp", "rt", "bt" }
end

function EditorGuiSlice.propertyWasSet(self, name, value, property)
	EditorGuiSlice.super.propertyWasSet(self, name, value, property)
	if name == "image" then
		self.image = property.image
		self:updateQuads()
		self:updateInnerSize()
	elseif name == "color" then
		self.color = property:getValue()
	elseif name == "margins" then
		local m = self.margins
		local m2 = property:getValue()
		m.lt, m.top, m.rt, m.bot = m2[1], m2[2], m2[3], m2[4]
		self:updateQuads()
		self:updateInnerSize()
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
end

return EditorGuiSlice
