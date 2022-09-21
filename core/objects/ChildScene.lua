
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local ChildScene = EditorObject:extend()
ChildScene.className = "ChildScene"
ChildScene.displayName = "ChildScene"

ChildScene.hitWidth = 64
ChildScene.hitHeight = 64

_G.objClassList:add(ChildScene, ChildScene.displayName)

function ChildScene.init(self)
	ChildScene.super.init(self)
	assert(self.sceneEnclosureIDMap, "ChildScene.init - no sceneEnclosureIDMap")
	assert(self.sceneFilepath, "ChildScene.init - no sceneFilepath")
end

local function getIDFromPropDatas(propDatas)
	for i,propData in ipairs(propDatas) do
		if propData.name == "id" then
			return propData.value
		end
	end
end

-- Used by Tool & Importer when adding child scenes.
-- `isOrigID` - Optional map of IDs inherent to the scene, for remapping after extra children have been added.
function ChildScene.recursiveMapEncIDs(addObjDatas, map, dataMap, isOrigID)
	map = map or {}
	dataMap = dataMap or {}
	for i,addObjData in ipairs(addObjDatas) do
		local props = addObjData.properties.rootProperties or addObjData.properties
		local id = getIDFromPropDatas(props)
		if not isOrigID or isOrigID[id] then
			map[id] = addObjData.enclosure
			dataMap[id] = addObjData
			if addObjData.children then
				ChildScene.recursiveMapEncIDs(addObjData.children, map, dataMap, isOrigID)
			end
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
	if mods.isChildSceneObj then  self.isChildSceneObj = true  end
	self.sceneEnclosureIDMap = mods.sceneEnclosureIDMap
	if mods.rootProperties then
		ChildScene.super.applyModifiedProperties(self, mods.rootProperties)
	end
	self.sceneFilepath = mods.sceneFilepath
	self:applySceneModifications(mods)
end

function ChildScene.getModifiedProperties(self)
	local propDatas = ChildScene.super.getModifiedProperties(self)
	return {
		isChildSceneObj = self.isChildSceneObj,
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
