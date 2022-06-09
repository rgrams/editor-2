
local EditorObject = require "objects.EditorObject"
local EditorPolygon = EditorObject:extend()
EditorPolygon.className = "EditorPolygon"

local config = require "config"

EditorPolygon.displayName = "Polygon"
EditorPolygon.hitWidth = 32
EditorPolygon.hitHeight = 32

_G.objClassList:add(EditorPolygon, EditorPolygon.displayName)

local Bool = require "objects.properties.Bool"

EditorPolygon.isBuiltinProperty = {
	name = true,
	pos = true,
	angle = true,
	scale = true,
	skew = true,
	isLoop = true,
}

function EditorPolygon.set(self)
	EditorPolygon.super.set(self)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	self.vertices = { -hw, hh, 0, -hh, hw, hh }
end

function EditorPolygon.initProperties(self)
	EditorPolygon.super.initProperties(self)
	self:addProperty(Bool, "isLoop", true, true)
end

function EditorPolygon.getVertPos(self, i)
	local ix = i*2 - 1
	local verts = self.vertices
	return verts[ix], verts[ix+1]
end

function EditorPolygon.setVertPos(self, i, x, y)
	local ix = i*2 - 1
	local verts = self.vertices
	verts[ix], verts[ix+1] = x, y
end

function EditorPolygon.insertVert(self, i, x, y)
	local ix = i*2 - 1
	table.insert(self.vertices, ix, y)
	table.insert(self.vertices, ix, x)
end

function EditorPolygon.deleteVert(self, i)
	local ix = i*2 - 1
	local oldX = table.remove(self.vertices, ix)
	local oldY = table.remove(self.vertices, ix)
	return oldX, oldY
end

function EditorPolygon.draw(self)
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.polygon("fill", self.vertices)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	love.graphics.polygon("line", self.vertices)

	self:drawParentChildLines()
end

return EditorPolygon
