
local EditorObject = require "objects.EditorObject"
local EditorCamera = EditorObject:extend()
EditorCamera.className = "EditorCamera"

EditorCamera.displayName = "Camera"

EditorCamera.hitWidth = 800
EditorCamera.hitHeight = 600

local config = require "config"
local id = require "lib.id"

_G.objClassList:add(EditorCamera, EditorCamera.displayName)

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local String = require "objects.properties.String"
local ScaleMode = require "objects.properties.Enum_CamScaleMode"

function EditorCamera.initProperties(self)
	self:addProperty(String, "id", id.new(), nil, true)
	self:addProperty(String, "name", nil, nil, true)
	self:addProperty(Vec2, "pos", nil, nil, true)
	self:addProperty(Float, "angle", nil, nil, true)
	self:addProperty(Vec2, "viewArea", { x=800, y=600}, nil, true)
	self:addProperty(ScaleMode, "scaleMode", nil, nil, true)
	self:addProperty(Bool, "fixedAspect", false, nil, true)
	self:addProperty(Bool, "isActive", true, nil, true)
end

function EditorCamera.getSizePropertyObj(self)
	return self:getPropertyObj("viewArea")
end

function EditorCamera.propertyWasSet(self, name, value, property)
	if name == "viewArea" then
		local val = self:getProperty("viewArea")
		self.hitWidth, self.hitHeight = val.x, val.y
		self:updateAABB()
		return
	end
	EditorCamera.super.propertyWasSet(self, name, value, property)
end

function EditorCamera.draw(self)
	love.graphics.setLineStyle("smooth")

	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2

	if self.isHovered then
		love.graphics.setColor(0, 0.5, 1, 0.01)
		love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2)
	end

	-- Draw axes.
	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	-- Draw little camera icon.
	local hiw = 32/2 * 0.8
	local hih = 32/3 * 0.8 / 2
	local len = hiw + hiw/2
	love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
	love.graphics.rectangle("line", -hiw, -hih, len, hih*2)
	love.graphics.line(-hiw+len, 0, hiw, -hih, hiw, hih, -hiw+len, 0)

	-- Draw view area.
	love.graphics.setColor(0, 0.5, 1, self.isHovered and 1 or 0.4)
	love.graphics.rectangle("line", -hw, -hh, hw*2, hh*2)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

return EditorCamera
