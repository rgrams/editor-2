
local signals = require "signals"

local function setVertexPos(caller, enclosure, i, x, y)
	local obj = enclosure[1]
	local oldX, oldY = obj:getVertPos(i)
	obj:setVertPos(i, x, y)
	if obj.isSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, enclosure, i, oldX, oldY
end

return {
	setVertexPos = { setVertexPos, setVertexPos }
}
