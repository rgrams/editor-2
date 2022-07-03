
local signals = require "signals"

local function add(caller, selection, enclosure, index)
	selection:add(enclosure, index)
	signals.send("selection changed", caller, selection.scene)
	return caller, selection, enclosure
end

local function remove(caller, selection, enclosure)
	local index = selection:remove(enclosure)
	signals.send("selection changed", caller, selection.scene)
	return caller, selection, enclosure, index
end

local function clear(caller, selection)
	local oldList = selection:clear()
	signals.send("selection changed", caller, selection.scene)
	return caller, selection, oldList
end

local function setTo(caller, selection, newList)
	local oldList = selection:setTo(newList)
	signals.send("selection changed", caller, selection.scene)
	return caller, selection, oldList
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	clearSelection = { clear, setTo },
	setSelection = { setTo, setTo },
}
