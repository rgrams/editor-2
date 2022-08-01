
local M = {}

local id = require "lib.id"
local AddObjData = require "commands.data.AddObjData"
local PropData = require "commands.data.PropData"
local StringProp = require "objects.properties.String"

function M.add(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local object = Class()
	enclosure[1] = object
	object.enclosure = enclosure

	local oneWasSelected = isSelected

	if children then
		object.children = object.children or {}
		for _,addData in ipairs(children) do
			assert(addData.parentEnclosure == enclosure, "object-functions.add() - Child's parent enclosure in AddObjData does not match our own")
			local scn, enc, wasSelected = M.add(addData.unpack())
			oneWasSelected = oneWasSelected or wasSelected
		end
	end

	if properties then
		object:applyModifiedProperties(properties)
	end

	local parentObj = parentEnclosure and parentEnclosure[1] or scene
	if parentObj.path then
		scene:add(object, parentObj)
	else
		parentObj.children = parentObj.children or {}
		table.insert(parentObj.children, object)
	end

	if isSelected then
		scene.selection:add(enclosure)
	end

	return scene, enclosure, oneWasSelected
end

local function deleteChildren(scene, children, isSimulation)
	if not children then  return false  end

	local childCount = children.maxn or #children
	if childCount == 0 then  return false  end

	local oneWasSelected = false

	local undoArgs = {}
	for i=1,childCount do
		local object = children[i]
		if object then
			local addData = AddObjData(M.delete(scene, object.enclosure, false, isSimulation))
			oneWasSelected = oneWasSelected or addData.isSelected
			table.insert(undoArgs, addData)
		end
	end
	return undoArgs, oneWasSelected
end

local function dictContainsAncestor(dict, obj)
	local p = obj.parent
	while not dict[p] do
		p = p.parent
		if not p then  return false  end
	end
	return true
end

-- Removes objects from the list if any of their ancestors are also in the list.
function M.removeDescendantsFromList(enclosures)
	local objDict = {} -- Make a dict of the objects to remove for quick checking.
	for i,enclosure in ipairs(enclosures) do
		objDict[enclosure[1]] = true
	end
	for i=#enclosures,1,-1 do
		local obj = enclosures[i][1]
		if dictContainsAncestor(objDict, obj) then
			table.remove(enclosures, i)
		end
	end
end

function M.delete(scene, enclosure, _oneWasSelected, isSimulation)
	local object = enclosure[1]
	local Class = getmetatable(object)
	local properties = object:getModifiedProperties() or false
	local isSelected = object.isSelected
	local oneWasSelected = isSelected
	if isSelected and not isSimulation then
		scene.selection:remove(enclosure)
	end
	if not object.parent then
		print("obj.delete - object has no parent", object)
	end
	local parentEnclosure = object.parent.enclosure or false
	local children, childWasSelected = deleteChildren(scene, object.children, isSimulation)
	oneWasSelected = oneWasSelected or childWasSelected
	if not isSimulation then
		local parent = object.parent
		object.tree:remove(object)
		object:call("wasRemoved", parent)
	end
	return scene, Class, enclosure, properties, isSelected, parentEnclosure, children, oneWasSelected
end

function M.deleteObjects(scene, enclosures)
	local addDatas = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local addData = AddObjData(M.delete(scene, enclosure))
		table.insert(addDatas, addData)
		oneWasSelected = oneWasSelected or addData.isSelected
	end
	return scene, addDatas, oneWasSelected
end

function M.copy(scene, enclosures)
	local isSimulation = true
	local addObjDatas = {}
	for _,enclosure in ipairs(enclosures) do
		local addData = AddObjData(M.delete(scene, enclosure, false, isSimulation))
		table.insert(addObjDatas, addData)
	end
	return addObjDatas
end

function M.addToMultiple(scene, parentEnclosures, Class, properties, isSelected, children)
	local newEnclosures = {}
	local oneWasSelected = isSelected
	for _,parentEnclosure in ipairs(parentEnclosures) do
		local scn, enc, wasSelected = M.add(scene, Class, {}, properties, isSelected, parentEnclosure, children)
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(newEnclosures, enc)
	end
	return scene, newEnclosures, oneWasSelected
end

function M.addObjects(scene, addObjDatas)
	local enclosures = {}
	local oneWasSelected = false
	for _,addObjData in ipairs(addObjDatas) do
		local scn, enc, wasSelected = M.add(addObjData.unpack())
		oneWasSelected = oneWasSelected or wasSelected
		table.insert(enclosures, enc)
	end
	return scene, enclosures, oneWasSelected
end

local function setNewIDProp(propDatas)
	for i,propData in ipairs(propDatas) do
		if propData.name == "id" and propData.Class == StringProp then
			local t = {
				name = propData.name,
				value = id.new(),
				Class = propData.Class,
				defaultVal = propData.defaultVal,
				isClassBuiltin = propData.isClassBuiltin,
				isNonRemovable = propData.isNonRemovable,
			}
			local newPropData = PropData(t)
			propDatas[i] = newPropData
			return propDatas
		end
	end
	return propDatas
end

-- Copy to new tables and insert new enclosures and new scene-tree.
function M.copyPasteDataFor(scene, parentEnclosure, addObjDatas, keepOrigParents)
	local newAddObjDatas = {}
	local isSelected = false
	for i,addData in ipairs(addObjDatas) do
		local newEnclosure = {}
		local children = addData.children
		if children then  children = M.copyPasteDataFor(scene, newEnclosure, children)  end
		local newAddData = AddObjData(
			scene,
			addData.Class,
			newEnclosure,
			setNewIDProp(addData.properties),
			isSelected,
			keepOrigParents and addData.parentEnclosure or parentEnclosure,
			children
		)
		newAddObjDatas[i] = newAddData
	end
	return newAddObjDatas
end

-- WARNING: Clipboard argsList needs to be copied before it gets put into the history.
function M.paste(scene, parentEnclosures, copiedAddDatas)
	local newEnclosures
	local oneWasSelected = false
	if not parentEnclosures then -- Add to scene root.
		local scn, newEncs, wasSelected = M.addObjects(scene, copiedAddDatas)
		oneWasSelected = oneWasSelected or wasSelected
		newEnclosures = newEncs
	else
		newEnclosures = {}
		for i,parentEnclosure in ipairs(parentEnclosures) do
			local addDatas
			if i == 1 then  addDatas = copiedAddDatas
			else  addDatas = M.copyPasteDataFor(scene, parentEnclosure, copiedAddDatas)  end
			local scn, newEncs, wasSelected = M.addObjects(scene, addDatas)
			oneWasSelected = oneWasSelected or wasSelected
			for _,enclosure in ipairs(newEncs) do
				table.insert(newEnclosures, enclosure)
			end
		end
	end
	return scene, newEnclosures, oneWasSelected
end

return M
