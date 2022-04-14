
local Class = require "philtre.modules.base-class"
local Selection = Class:extend()

function Selection.set(self, scene)
	self.scene = scene
end

function Selection.add(self, enclosure, i)
	enclosure[1].isSelected = true
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
			enclosure[1].isSelected = false
			return i
		end
	end
end

function Selection.clear(self)
	local oldList = {}
	for i=#self,1,-1 do
		local enclosure = self[i]
		oldList[i] = enclosure
		enclosure[1].isSelected = false
		self[i] = nil
	end
	return oldList
end

function Selection.setTo(self, newList)
	local oldList = self:clear()
	for i,enclosure in ipairs(newList) do
		self[i] = enclosure
		enclosure[1].isSelected = true
	end
	return oldList
end

function Selection.copyList(self)
	if self[1] then
		local list = {}
		for i=1,#self do
			list[i] = self[i]
		end
		return list
	end
end

return Selection
