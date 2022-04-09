
local M = {}

function M.add(scene, isNotActive)
	table.insert(M, scene)
	if not isNotActive then
		M.active = scene
	end
end

function M.remove(scene)
	for i=1,#M,-1 do
		local scn = M[i]
		if scn == scene then
			table.remove(M, i)
		end
	end
end

function M.setActive(scene)
	M.active = scene
end

return M
