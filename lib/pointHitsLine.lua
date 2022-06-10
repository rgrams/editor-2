
-- Requires vec2 module as a global.

local function pointHitsLine(px, py, x1, y1, x2, y2, lineRadius)
	local dx, dy = x2 - x1, y2 - y1
	local len2 = vec2.len2(dx, dy)
	local x1_to_px, y1_to_py = px - x1, py - y1 -- Vector from line start to point.
	local distAlongLine = vec2.dot(x1_to_px, y1_to_py, dx, dy)
	local fractionAlongLine = distAlongLine / len2 -- Divide by len^2 since dx,dy are not normalized?
	fractionAlongLine = math.max(0, math.min(fractionAlongLine, 1))
	local closestX, closestY = vec2.lerp(x1, y1, x2, y2, fractionAlongLine)
	local dist = vec2.len(px - closestX, py - closestY)
	if dist <= lineRadius then
		return dist, closestX, closestY
	else
		return nil
	end
end

return pointHitsLine
