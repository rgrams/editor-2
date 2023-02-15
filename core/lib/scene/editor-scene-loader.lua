
-- Löve editor scene loader.
-- NOTE: For loading EDITOR scene files.

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

local function addSceneModsTo(from, to)
	for k,v in pairs(from) do
		if k ~= "properties" then  to[k] = v  end
	end
	if from.properties then -- Non-builtin properties kept in separate subtable.
		local toProperties = to.properties or {}
		to.properties = toProperties
		for k,v in pairs(from.properties) do  toProperties[k] = v  end
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

local function split(str, sepPattern)
	local results = {}
	local pattern = "(.-)" .. sepPattern
	local lastEnd = 1
	local st, en, capture = str:find(pattern, 1)
	while st do
		if st ~= 1 or capture ~= "" then
			table.insert(results, capture)
		end
		lastEnd = en + 1
		st, en, capture = str:find(pattern, lastEnd)
	end
	if lastEnd-1 <= #str then -- Includes an empty string if the separator is at the end.
		capture = str:sub(lastEnd)
		table.insert(results, capture)
	end
	return results
end

local function toRequirePath(filepath)
	return filepath:gsub("[\\/]", "."):gsub("%.lua", "")
end

local function mapPropertyValue(map, name, propType, value)
	if (name == "pos" or name == "scale" or name == "skew") and propType == "vec2" then
		local key1, key2
		if name == "pos" then  key1, key2 = "x", "y"
		elseif name == "scale" then  key1, key2 = "sx", "sy"
		elseif name == "skew" then  key1, key2 = "kx", "ky"  end
		map[key1], map[key2] = value.x, value.y
		return
	elseif name == "angle" and propType == "float" then
		value = math.rad(value)
	elseif propType == "file" or propType == "image" or propType == "script" then
		if value ~= "" then
			local ext = string.sub(value, -4, -1)
			if ext == ".lua" then
				value = toRequirePath(value)
			end
		end
	elseif propType == "font" then
		if value[1] == "" then  value[1] = nil  end
	elseif (name == "categories" or name == "mask") and propType == "string" then
		if value == "" then  return  end
		value = split(value, ", ")
	end
	map[name] = value
end

local NAME, VALUE, TYPE, IS_EXTRA = 1, 2, 3, "isExtra"
local function unpackProperty(prop)
	return prop[NAME], prop[TYPE], prop[VALUE]
end

-- Change list of property data structures to name-values on `map`,
-- 	plus `properties` dictionary with non-builtins.
local function propertyListToKeyValue(list, map)
	local nonBuiltinProps = {}
	for _,prop in ipairs(list) do
		if prop[IS_EXTRA] then  table.insert(nonBuiltinProps, prop)
		else  mapPropertyValue(map, unpackProperty(prop))  end
	end
	if nonBuiltinProps[1] then
		local extraProps = {}
		map.properties = extraProps
		for _,prop in ipairs(nonBuiltinProps) do
			mapPropertyValue(extraProps, unpackProperty(prop))
		end
	end
end

local function loadObjectClass(obj)
	local userClass = obj.properties and obj.properties.Class
	obj.Class = userClass and require(userClass) or classes[obj.class]
end

local function remapObjectProperties(obj)
	local propertyList = obj.properties
	obj.properties = nil
	propertyListToKeyValue(propertyList, obj)
	loadObjectClass(obj)
end

local function remapSceneChildProperties(childProperties)
	for id,propertyList in pairs(childProperties) do
		local newMap = {}
		childProperties[id] = newMap
		propertyListToKeyValue(propertyList, newMap)
	end
end

local function remapChildSceneProperties(obj)
	local properties = obj.properties
	obj.properties = nil
	propertyListToKeyValue(properties.rootProperties, obj)
	remapSceneChildProperties(properties.childProperties)
	-- Added objects will be remapped when they are preloaded on their real parent later.
	obj.childProperties = properties.childProperties
	obj.addedObjects = properties.addedObjects
end

local function uncachedRequire(path)
	local scene = require(path)
	package.loaded[path] = nil
	return scene
end

local function preLoadObjects(objects, parentsChildList, transform, mods, added)
	for i,obj in ipairs(objects) do
		if obj.class == "ChildScene" then
			remapChildSceneProperties(obj)
			local childScene = uncachedRequire(toRequirePath(obj.sceneFilepath))
			local _transform, _mods, _added = obj, obj.childProperties, obj.addedObjects
			if mods then
				if mods[obj.id] then  addSceneModsTo(mods[obj.id], obj)  end
				addSceneModsTo(mods, _mods)
			end
			if transform then  _transform = addTransforms(transform, _transform)  end
			if added then  _added = addAddedObjs(_added or {}, added)  end
			if _added and _added[obj.id] then
				local ourAdded = _added[obj.id]
				_added[obj.id] = nil
				preLoadObjects(ourAdded, parentsChildList, _transform, _mods, _added)
			end
			preLoadObjects(childScene, parentsChildList, _transform, _mods, _added)
		else
			remapObjectProperties(obj)
			if mods and mods[obj.id] then  addSceneModsTo(mods[obj.id], obj)  end
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
	local scene = uncachedRequire(requirePath) -- We're going to modify this copy, so don't cache it.
	local rootObjects = {}
	preLoadObjects(scene, rootObjects)
	scene.objects = rootObjects
	return scene
end

function new.scene(requirePath)
	return new.custom("scene", M.preLoadScene, requirePath)
end

local function makeObject(objData, transform, mods)
	local Class = objData.Class
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
