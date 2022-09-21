
local M = {}

local map = {
	rshift = "shift",
	lshift = "shift",
	rctrl = "ctrl",
	lctrl = "ctrl",
	ralt = "alt",
	lalt = "alt",
	rgui = "meta",
	lgui = "meta",
	mode = "mode",
}

local presses = {
	shift = 0,
	ctrl = 0,
	alt = 0,
	meta = 0,
	mode = 0
}

local keyList = { "ctrl", "alt", "shift", "meta", "mode" }
local separator = " "
local str = ""

local function updateString()
	str = ""
	for i,modkey in ipairs(keyList) do
		if presses[modkey] > 0 then
			str = str .. modkey .. separator
		end
	end
	Input.modkeysChanged(str)
end

function M.getString()
	return str
end

function M.keypressed(key, isRepeat)
	if isRepeat then  return  end
	local modkey = map[key]
	if modkey then
		presses[modkey] = presses[modkey] + 1
		if presses[modkey] == 1 then
			updateString()
		end
	end
end

function M.keyreleased(key)
	local modkey = map[key]
	if modkey then
		presses[modkey] = presses[modkey] - 1
		if presses[modkey] == 0 then
			updateString()
		end
	end
end

function M.isPressed(modkey)
	return presses[modkey] > 0
end

return M
