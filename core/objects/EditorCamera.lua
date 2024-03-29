
local EditorObject = require "core.objects.EditorObject"
local EditorCamera = EditorObject:extend()
EditorCamera.className = "EditorCamera"
EditorCamera.displayName = "Camera"

EditorCamera.hitWidth = 800
EditorCamera.hitHeight = 600

_G.objClassList:add(EditorCamera, EditorCamera.displayName)

local style = require "core.ui.style"
local id = require "core.lib.id"
local PropData = require "core.commands.data.PropData"

local Float = require "core.objects.properties.Property"
local Bool = require "core.objects.properties.Bool"
local Vec2 = require "core.objects.properties.Vec2"
local String = require "core.objects.properties.String"
local ScaleMode = require "core.objects.properties.Enum_CamScaleMode"

function EditorCamera.initProperties(self)
	self:addProperty(PropData("id", id.new(), String, nil, true))
	self:addProperty(PropData("name", nil, String, nil, true))
	self:addProperty(PropData("pos", nil, Vec2, nil, true))
	self:addProperty(PropData("angle", nil, Float, nil, true))
	self:addProperty(PropData("viewArea", { x=800, y=600 }, Vec2, nil, true))
	self:addProperty(PropData("scaleMode", nil, ScaleMode, nil, true))
	self:addProperty(PropData("fixedAspect", false, Bool, nil, true))
	self:addProperty(PropData("isActive", true, Bool, nil, true))
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
	love.graphics.setColor(style.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(style.yAxisColor)
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
