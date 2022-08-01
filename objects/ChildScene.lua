
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local ChildScene = EditorObject:extend()
ChildScene.className = "ChildScene"
ChildScene.displayName = "ChildScene"

ChildScene.hitWidth = 64
ChildScene.hitHeight = 64

_G.objClassList:add(ChildScene, ChildScene.displayName)

local PropData = require "commands.data.PropData"

function ChildScene.init(self)
	ChildScene.super.init(self)
	assert(self.sceneEnclosureIDMap, "ChildScene.init - no sceneEnclosureIDMap")
	assert(self.sceneFilepath, "ChildScene.init - no sceneFilepath")
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

local function getIDFromPropDatas(propDatas)
	for i,propData in ipairs(propDatas) do
		if propData.name == "id" then
			return propData.value
		end
	end
end

-- Used by Tool & Importer when adding child scenes.
function ChildScene.recursiveMapEncIDs(addObjDatas, map, dataMap)
	map = map or {}
	dataMap = dataMap or {}
	for i,addObjData in ipairs(addObjDatas) do
		local id = getIDFromPropDatas(addObjData.properties)
		map[id] = addObjData.enclosure
		dataMap[id] = addObjData
		if addObjData.children then
			ChildScene.recursiveMapEncIDs(addObjData.children, map, dataMap)
		end
	end
	return map, dataMap
end

function ChildScene.applyModifiedProperties(self, mods)
	if mods[1] then -- Basic object modified property data (from Tool or somewhere).
		ChildScene.super.applyModifiedProperties(self, mods)
		return
	end

	-- Got detailed properties from import.
	self.sceneEnclosureIDMap = mods.sceneEnclosureIDMap
	if mods.rootProperties then
		ChildScene.super.applyModifiedProperties(self, mods.rootProperties)
	end
	self.sceneFilepath = mods.sceneFilepath
	self:applySceneModifications(mods)
end

function ChildScene.getModifiedProperties(self)
	local propDatas
	for i,property in ipairs(self.properties) do
		local propData
		if property.isClassBuiltin then
			if not property:isAtDefault() then
				propData = PropData.fromProp(property)
			end
		else
			propData = PropData.fromProp(property)
		end
		if propData then
			propDatas = propDatas or {}
			table.insert(propDatas, propData)
		end
	end
	return {
		rootProperties = propDatas,
		sceneEnclosureIDMap = self.sceneEnclosureIDMap,
		sceneFilepath = self.sceneFilepath,
	}
end

function ChildScene.applySceneModifications(self, mods)
	-- Apply property mods to scene objects.
	if mods.childProperties then
		for id,propDatas in pairs(mods.childProperties) do
			local enclosure = self.sceneEnclosureIDMap[id]
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
