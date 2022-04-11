
local Class = require "philtre.modules.base-class"
local Selection = Class:extend()

function Selection.add(self, enclosure)
	table.insert(self, enclosure)
end

function Selection.remove(self, enclosure)
	for i,selected in ipairs(self) do
		if selected == enclosure then
			table.remove(self, i)
			return i
		end
	end
end

function Selection.clear(self)
	for i=#self,1,-1 do
		self[i] = nil
	end
end

return Selection
