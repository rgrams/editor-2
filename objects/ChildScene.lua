
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local ChildScene = EditorObject:extend()
ChildScene.className = "ChildScene"
ChildScene.displayName = "ChildScene"

ChildScene.hitWidth = 64
ChildScene.hitHeight = 64

local signals = require "signals"
local importer = require "io.defaultLuaImportExport"
local objectFn = require "commands.functions.object-functions"

_G.objClassList:add(ChildScene, ChildScene.displayName)

local File = require "objects.properties.File"

function ChildScene.initProperties(self)
	self.oldScenePath = ""
	self.sceneRootEnclosures = {}
	self:addProperty(File, "scene", "", false, true)
	ChildScene.super.initProperties(self)
end

local function removeOldSceneRootObjects(self)
	local scene = self.tree
	local enclosures = self.sceneRootEnclosures
	if #enclosures > 0 then
		local _, _, _, oneWasSelected = objectFn.deleteObjects(self, scene, enclosures)
		for i=#enclosures,1,-1 do
			enclosures[i] = nil
		end
		if oneWasSelected then
			signals.send("selection changed", self, scene)
		end
	end
end

local function addSceneObjects(self, scenePath)
	local _, addObjectArgs = importer.import(scenePath, nil, self.enclosure)
	return addObjectArgs
end

local function setPropertiesDefaultAndBuiltin(self, objects)
	for i=1,objects.maxn or #objects do
		local obj = objects[i]
		if obj then
			for _,property in ipairs(obj.properties) do
				property.isNonRemovable = true
				property.defaultValue = property:copyValue()
			end
			if obj.children then
				setPropertiesDefaultAndBuiltin(self, obj.children)
			end
		end
	end
end

local function loadScene(self, scenePath)
	if scenePath ~= self.oldScenePath then
		removeOldSceneRootObjects(self)
		self.oldScenePath = scenePath
		if scenePath ~= "" then
			local addObjectArgs = addSceneObjects(self, scenePath)
			local enclosures = self.sceneRootEnclosures
			local objects = {}
			for i,args in ipairs(addObjectArgs) do
				enclosures[i] = args[4] -- args = { caller, scene, Class, enclosure, ... }
				objects[i] = args[4][1]
			end
			setPropertiesDefaultAndBuiltin(self, objects)
		end
	end
end

function ChildScene.init(self)
	ChildScene.super.init(self)
	local scenePath = self:getProperty("scene")
	if scenePath ~= "" then
		loadScene(self, scenePath)
	end
end

function ChildScene.propertyWasSet(self, name, value, property)
	if name == "scene" and self.tree then
		loadScene(self, value)
		return
	end
	ChildScene.super.propertyWasSet(self, name, value, property)
end

function ChildScene.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.setLineWidth(2)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	love.graphics.line(-hw, -hh+10, -hw, -hh, -hw+10, -hh)
	love.graphics.line(hw, -hh+10, hw, -hh, hw-10, -hh)
	love.graphics.line(-hw, hh-10, -hw, hh, -hw+10, hh)
	love.graphics.line(hw, hh-10, hw, hh, hw-10, hh)
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")

	ChildScene.super.draw(self)
end

return ChildScene
