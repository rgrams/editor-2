
local objectFn = require "core.commands.functions.object-functions"
local signals = require "core.signals"

local function add(caller, ...)
	local scene, enclosure, oneWasSelected = objectFn.add(...)
	signals.send("objects added", caller, scene)
	if oneWasSelected then
		signals.send("selection changed", caller, scene)
	end
	return caller, scene, enclosure, oneWasSelected
end

local function delete(caller, ...)
	local scn, Cl, enc, props, isSel, parEnc, chldrn, oneWasSelected = objectFn.delete(...)
	signals.send("objects deleted", caller, scn)
	if oneWasSelected then
		signals.send("selection changed", caller, scn)
	end
	return caller, scn, Cl, enc, props, isSel, parEnc, chldrn, oneWasSelected
end

local function addObjects(caller, ...)
	local scene, enclosures, oneWasSelected = objectFn.addObjects(...)
	signals.send("objects added", caller, scene)
	if oneWasSelected then
		signals.send("selection changed", caller, scene)
	end
	return caller, scene, enclosures, oneWasSelected
end

local function deleteObjects(caller, ...)
	local scene, undoArgs, oneWasSelected = objectFn.deleteObjects(...)
	signals.send("objects deleted", caller, scene)
	if oneWasSelected then
		signals.send("selection changed", caller, scene)
	end
	return caller, scene, undoArgs, oneWasSelected
end

local function addToMultiple(caller, ...)
	local scene, newEnclosures, oneWasSelected = objectFn.addToMultiple(...)
	signals.send("objects added", caller, scene)
	if oneWasSelected then
		signals.send("selection changed", caller, scene)
	end
	return caller, scene, newEnclosures, oneWasSelected
end

local function paste(caller, ...)
	local scene, newEnclosures, oneWasSelected = objectFn.paste(...)
	signals.send("objects added", caller, scene)
	if oneWasSelected then
		signals.send("selection changed", caller, scene)
	end
	return caller, scene, newEnclosures, oneWasSelected
end

local function getAllEnclosuresFromArgs(addObjDatas, list)
	list = list or {}
	for i,addData in ipairs(addObjDatas) do
		table.insert(list, addData.enclosure)
		if addData.children then
			getAllEnclosuresFromArgs(addData.children, list)
		end
	end
	return list
end

local function duplicate(caller, scene, enclosuresToCopy)
	local dupAddDatas = objectFn.copy(scene, enclosuresToCopy)
	local keepOrigParents = true
	dupAddDatas = objectFn.copyPasteDataFor(scene, nil, dupAddDatas, keepOrigParents)
	-- Want to select -all- new objects, not just the ancestors.
	local newEnclosuresToSelect = getAllEnclosuresFromArgs(dupAddDatas)

	local scn, newEnclosuresForUndo = objectFn.addObjects(scene, dupAddDatas)
	local oldSelection = scene.selection:setTo(newEnclosuresToSelect)

	signals.send("objects added", caller, scene)
	signals.send("selection changed", caller, scene)

	return caller, scene, newEnclosuresForUndo, oldSelection
end

local function unduplicate(caller, scene, enclosures, oldSelection)
	objectFn.deleteObjects(scene, enclosures)
	scene.selection:setTo(oldSelection)
	signals.send("objects added", caller, scene)
	signals.send("selection changed", caller, scene)
	-- Only used for undoing duplicate, so it doesn't need to return anything.
end


return {
	addObject = { add, delete },
	deleteObject = { delete, add },
	addObjects = { addObjects, deleteObjects },
	deleteObjects = { deleteObjects, addObjects },
	addObjectToMultiple = { addToMultiple, deleteObjects },
	paste = { paste, deleteObjects },
	duplicate = { duplicate, unduplicate },
}
