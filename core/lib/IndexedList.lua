
-- Dictionary/Array combo class.
-- For mapping names --> Classes for EditorObjects, Properties, etc.
-- Also an iterable sequence for selector menus, etc.

local Class = require "core.philtre.modules.base-class"
local IndexedList = Class:extend()

function IndexedList.set(self)
	self.contains = {}
	self.nameOf = {}
end

function IndexedList.add(self, item, name)
	self.contains[name] = item
	self.nameOf[item] = name
	table.insert(self, item)
end

function IndexedList.get(self, name)
	return self.contains[name]
end

function IndexedList.getName(self, item)
	return self.nameOf[item]
end

return IndexedList
