
local objectFn = require "commands.functions.object-functions"
local signals = require "signals"

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

local function getAllEnclosuresFromArgs(args, list)
	list = list or {}
	for i,argsList in ipairs(args) do
		local enclosure, children = argsList[3], argsList[7]
		table.insert(list, enclosure)
		if children then
			getAllEnclosuresFromArgs(children, list)
		end
	end
	return list
end

local function duplicate(caller, scene, enclosuresToCopy)
	local dupArgs = objectFn.copy(scene, enclosuresToCopy)
	dupArgs = objectFn.copyPasteDataFor(scene, nil, dupArgs)
	for i,enclosure in ipairs(enclosuresToCopy) do
		local args = dupArgs[i]
		local origParent = enclosure[1].parent
		args[6] = origParent.enclosure -- Set parent back to the original.
	end
	-- Want to select -all- new objects, not just the ancestors.
	local newEnclosuresToSelect = getAllEnclosuresFromArgs(dupArgs)

	local scn, newEnclosuresForUndo = objectFn.addObjects(scene, dupArgs)
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
