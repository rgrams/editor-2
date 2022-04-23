
local M = {}

local objToStr = require "philtre.lib.object-to-string"

local function copyChildrenData(children)
	local output = {}
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			-- Copy object data:
			local data = {}
			local Class = getmetatable(child)
			data.class = Class.displayName
			for _,property in ipairs(child.properties) do
				data[property.name] = property:getValue()
			end
			if child.children then
				data.children = copyChildrenData(child.children)
			end

			table.insert(output, data)
		end
	end
	return output
end

function M.export(scene, file, options)
	print("----  EXPORT  ----")
	options = options or {}
	local data = copyChildrenData(scene.children, options)
	local str = "return " .. objToStr(data) .. "\n"
	file:write(str)
end

return M
