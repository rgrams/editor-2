
local Class = require "philtre.modules.base-class"
local Selection = Class:extend()

function Selection.add(self, enclosure, i)
	if i then
		i = math.min(i, #self+1)
		table.insert(self, i, enclosure)
	else
		table.insert(self, enclosure)
	end
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
