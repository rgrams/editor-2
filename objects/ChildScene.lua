
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local ChildScene = EditorObject:extend()
ChildScene.className = "ChildScene"
ChildScene.displayName = "ChildScene"

ChildScene.hitWidth = 64
ChildScene.hitHeight = 64

_G.objClassList:add(ChildScene, ChildScene.displayName)

local signals = require "signals"
local objectFn = require "commands.functions.object-functions"
local PropData = require "commands.data.PropData"

local File = require "objects.properties.File"

function ChildScene.set(self)
	self.oldScenePath = ""
	self.sceneRootEnclosures = {}
	self.sceneObjectIDMap = {}
	ChildScene.super.set(self)
end

function ChildScene.initProperties(self)
	self:addProperty(PropData("scene", "", File, nil, true))
	ChildScene.super.initProperties(self)
end

local function removeOldSceneRootObjects(self)
	local scene = self.tree
	local enclosures = self.sceneRootEnclosures
	if #enclosures > 0 then
		local scn, undoArgs, oneWasSelected = objectFn.deleteObjects(scene, enclosures)
		for i=#enclosures,1,-1 do
			enclosures[i] = nil
		end
		for k,v in pairs(self.sceneObjectIDMap) do
			self.sceneObjectIDMap[k] = nil
		end
		if oneWasSelected then
			signals.send("selection changed", self, scene)
		end
	end
end

local function addSceneObjects(self, scenePath)
	local importer = require "io.defaultLuaImportExport"
	local _, addObjDatas = importer.import(scenePath, nil, self.enclosure)
	return addObjDatas
end

local function setPropertiesDefaultAndBuiltin(self, objects)
	for i=1,objects.maxn or #objects do
		local obj = objects[i]
		if obj then
			for _,property in ipairs(obj.properties) do
				property.isNonRemovable = true
				-- Can't just set the default value to the current one because those defaults
				-- aren't saved anywhere.
				-- If you delete the object in only saves modified properties, so if everything
				-- is at default, nothing is saved and the information is destroyed.
				property.sceneDefault = property:copyValue() -- Use alternate default for export.
			end
			if obj.children then
				setPropertiesDefaultAndBuiltin(self, obj.children)
			end
		end
	end
end

local function getSceneObjectIDs(objects, map)
	map = map or {}
	for i=1,objects.maxn or #objects do
		local obj = objects[i]
		if obj then
			local id = obj:getProperty("id")
			map[id] = obj.enclosure
			if obj.children then
				getSceneObjectIDs(obj.children, map)
			end
		end
	end
	return map
end

local function loadScene(self, scenePath)
	if scenePath ~= self.oldScenePath then
		removeOldSceneRootObjects(self)
		self.oldScenePath = scenePath
		if scenePath ~= "" then
			local addObjDatas = addSceneObjects(self, scenePath)
			local enclosures = self.sceneRootEnclosures
			local objects = {}
			for i,addObjData in ipairs(addObjDatas) do
				enclosures[i] = addObjData.enclosure
				objects[i] = addObjData.enclosure[1]
			end
			setPropertiesDefaultAndBuiltin(self, objects)
			getSceneObjectIDs(objects, self.sceneObjectIDMap)
		end
	end
end

function ChildScene.init(self)
	ChildScene.super.init(self)
	local scenePath = self:getProperty("scene")
	if scenePath ~= "" then
		if self.modData then
			loadScene(self, scenePath)
			self:applySceneModifications(self.modData)
			self.modData = nil
		end
	end
end

function ChildScene.propertyWasSet(self, name, value, property)
	if name == "scene" then
		if self.tree then
			loadScene(self, value)
			return
		end
	end
	ChildScene.super.propertyWasSet(self, name, value, property)
end

function ChildScene.applyModifiedProperties(self, mods)
	if mods[1] then -- Basic object modified property data (from Tool or somewhere).
		ChildScene.super.applyModifiedProperties(self, mods)
		return
	end
	-- Got detailed properties from import.
	if mods.rootProperties then
		ChildScene.super.applyModifiedProperties(self, mods.rootProperties)
	end
	if not self.tree then
		-- Must delay applying mods to scene objects until after they're created (on init).
		self.modData = mods
	else
		self:applySceneModifications(mods)
	end
end

function ChildScene.applySceneModifications(self, mods)
	-- Apply property mods to scene objects.
	for id,propDatas in pairs(mods.childProperties) do
		local enclosure = self.sceneObjectIDMap[id]
		if enclosure then -- Object may have been deleted in source scene.
			local obj = enclosure[1]
			for i,propData in ipairs(propDatas) do
				if not obj:hasProperty(propData.name) then
					obj:addProperty(propData)
				else
					obj:setProperty(propData)
				end
			end
		end
	end
	if mods.addedObjects then
		local selfID = self:getProperty("id")
		for id,addedObjects in pairs(mods.addedObjects) do
			local parentEnc = self.sceneObjectIDMap[id]
			if not parentEnc and id == selfID then  parentEnc = self.enclosure  end
			if parentEnc then
				objectFn.addObjects(self.tree, addedObjects)
			end
		end
	end
end

function ChildScene.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.setLineWidth(3)
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
