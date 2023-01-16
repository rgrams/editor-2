
-- Löve editor scene loader.
-- NOTE: For loading -exported- scene files, not editor scene files.

-- Adds a loader to `new`: new.scene(requirePath). Use that to preload scenes.
-- 	(It flattens out child scenes, etc.)
--
-- M.create(scene) - Scene constructor. Returns a list of root objects. Doesn't add to tree.
-- M.addToParent(objects, parent) - Adds a list of objects to a parent (in tree or not).
-- M.addScene(scene, parent) - Shortcut to call both .create() and .addToParent() at once.
--
-- REQUIRES:
-- 	1. a 'classes' module with object classes, keyed by class name.
-- 	2. Each class used must have a .fromData(Class, objData) method defined,
-- 	   which returns a new object of that class, from the exported object data.

local M = {}

local basepath = (...):gsub("[^%.]+$", "")
local classes = require(basepath .. "classes")
local new = require "core.philtre.core.new"
local debugEnabled = false

local function addTransforms(t1, t2, out)
	out = out or {}
	out.x = (t1.x or t2.x) and (t1.x or 0) + (t2.x or 0)
	out.y = (t1.y or t2.y) and (t1.y or 0) + (t2.y or 0)
	out.angle = (t1.angle or t2.angle) and (t1.angle or 0) + (t2.angle or 0)
	out.sx = (t1.sx or t2.sx) and (t1.sx or 1) * (t2.sx or 1)
	out.sy = (t1.sy or t2.sy) and (t1.sy or 1) * (t2.sy or 1)
	out.kx = (t1.kx or t2.kx) and (t1.kx or 0) + (t2.kx or 0)
	out.ky = (t1.ky or t2.ky) and (t1.ky or 0) + (t2.ky or 0)
	return out
end

local function addSceneMods(base, mods)
	for k,v in pairs(mods) do
		if k ~= "properties" then
			base[k] = v
		end
	end
	if mods.properties then
		local baseProp = base.properties or {}
		base.properties = baseProp
		for k,v in pairs(mods.properties) do
			baseProp[k] = v
		end
	end
end

local function addToList(toAdd, list)
	for _,v in ipairs(toAdd) do  table.insert(list, v)  end
end

local function addAddedObjs(base, added)
	local keys = {}
	for id,objList in pairs(added) do
		table.insert(keys, id)
		if base[id] then  addToList(objList, base[id])
		else  base[id] = objList  end
	end
	return base
end

local function preLoadObjects(objects, parentsChildList, transform, mods, added)
	for i,obj in ipairs(objects) do
		if obj.class == "ChildScene" then
			local childScene = require(obj.exportedScene)
			package.loaded[obj.exportedScene] = nil
			local _transform, _mods, _added = obj, obj.sceneObjProperties, obj.sceneAddedObjects
			if mods then
				if mods[obj.id] then  addSceneMods(obj, mods[obj.id])  end
				addSceneMods(_mods, mods)
			end
			if transform then  _transform = addTransforms(transform, _transform)  end
			if added then  _added = addAddedObjs(_added or {}, added)  end
			if _added and _added[obj.id] then
				local ourAdded = _added[obj.id]
				_added[obj.id] = nil
				preLoadObjects(ourAdded, parentsChildList, _transform, _mods, _added)
			end
			preLoadObjects(childScene.objects, parentsChildList, _transform, _mods, _added)
		else
			if mods and mods[obj.id] then  addSceneMods(obj, mods[obj.id])  end
			if transform then  addTransforms(obj, transform, obj)  end
			table.insert(parentsChildList, obj)
			if obj.children then
				local origChildren = obj.children
				obj.children = {}
				-- Scene transform should only apply to root objects, not to children.
				-- Children are in their parent's local space.
				preLoadObjects(origChildren, obj.children, nil, mods, added)
			end
			if added and added[obj.id] then
				obj.children = obj.children or {}
				local ourAdded = added[obj.id]
				added[obj.id] = nil
				preLoadObjects(ourAdded, obj.children, nil, mods, added)
			end
		end
	end
end

function M.preLoadScene(requirePath)
	local scene = require(requirePath)
	package.loaded[requirePath] = nil -- We're going to modify this copy, so remove it from the cache.
	local rootObjects = {}
	preLoadObjects(scene.objects, rootObjects)
	scene.objects = rootObjects
	return scene
end

function new.scene(requirePath)
	return new.custom("scene", M.preLoadScene, requirePath)
end

local function makeObject(objData, transform, mods)
	local userClass = objData.properties and objData.properties.Class
	local Class = userClass and require(userClass) or classes[objData.class]
	if Class and Class.fromData then
		local obj = Class.fromData(Class, objData)
		if objData.children then
			obj.children = obj.children or {}
			for i,childObjData in ipairs(objData.children) do
				local child = makeObject(childObjData, transform, mods)
				if child then  table.insert(obj.children, child)  end
			end
		end
		return obj
	elseif debugEnabled then
		if not Class then
			print("No Class: "..tostring(objData.class))
		else
			print("No Class.fromData?", Class, Class.fromData)
		end
	end
end

function M.addToParent(objects, parent)
	local parentIsNotInTree = parent.path == nil
	if parentIsNotInTree then  parent.children = parent.children or {}  end

	for i=1,#objects do
		if parentIsNotInTree then  table.insert(parent.children, objects[i])
		else  parent.tree:add(objects[i], parent)  end
	end
	return objects
end

function M.create(scene)
	local addedObjects = {}
	for i=1,#scene.objects do
		local child = makeObject(scene.objects[i])
		if child then  table.insert(addedObjects, child)  end
	end
	return addedObjects
end

function M.addScene(scene, parent)
	assert(parent, "Scene-loader.addScene: Must provide a parent.")
	local rootObjects = M.addToParent(M.create(scene), parent)
	return rootObjects
end

return M
