
local EditorGuiNode = require "core.objects.EditorGuiNode"
local EditorGuiColumn = EditorGuiNode:extend()

EditorGuiColumn:implements(gui.Column, "skip")

EditorGuiColumn.className = "EditorGuiColumn"
EditorGuiColumn.displayName = "GUI Column"

_G.objClassList:add(EditorGuiColumn, EditorGuiColumn.displayName)

local PropData = require "core.commands.data.PropData"
local ChildScene = require "core.objects.ChildScene"

local Float = require "core.objects.properties.Property"
local Bool = require "core.objects.properties.Bool"

function EditorGuiColumn.set(self)
	EditorGuiColumn.super.set(self)
	self.spacing = 0
	self.homogeneous = false
	self.dir = -1
end

function EditorGuiColumn.initProperties(self)
	EditorGuiColumn.super.initProperties(self)
	self:addProperty(PropData("spacing",     nil,   Float, nil,  true))
	self:addProperty(PropData("homogeneous", false, Bool, false, true))
	self:addProperty(PropData("dir",         -1,    Float, -1, true))
end

function EditorGuiColumn.init(self)
	if self.parent.allocateChild then  self.parent:allocateChild(self)  end
	self:allocateChildren() -- Just force it.
	self:updateAABB()
	self:wasModified()
end

function EditorGuiColumn.allocateChildren(self)
	if not self.path then  return  end -- Gets called from propertyWasSet before init.
	gui.Column.allocateChildren(self)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiColumn.allocateChild(self, child)
	gui.Column.allocateChild(self, child)
end

function EditorGuiColumn.childrenModified(self)
	self:allocateChildren()
end

function EditorGuiColumn.propertyWasSet(self, name, value, property)
	EditorGuiColumn.super.propertyWasSet(self, name, value, property)
	if name == "spacing" then
		self.spacing = value
		self:allocateChildren()
	elseif name == "homogeneous" then
		self.homogeneous = value
		self:allocateChildren()
	elseif name == "dir" then
		self.dir = value
		self:allocateChildren()
	end
end

-- If child is a ChildScene, skip it and grab all it's children.
function EditorGuiColumn.getRealChildList(children, list)
	list = list or {}
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			if child:is(ChildScene) then
				EditorGuiColumn.getRealChildList(child.children, list)
			elseif child.request then
				table.insert(list, child)
			end
		end
	end
	return list
end

function EditorGuiColumn.getChildDimensionTotals(self, key, children)
	local dim1, dim2 = 0, 0
	children = children or self.getRealChildList(self.children)
	for i=1,#children do
		local child = children[i]
		local val = child:request()[key]
		dim1 = dim1 + (val or 0)
		if child.isGreedy then
			dim2 = dim2 + (val or 0)
		end
	end
	return dim1, dim2
end

function EditorGuiColumn.countChildren(self, children)
	children = children or self.getRealChildList(self.children)
	return #children
end

function EditorGuiColumn.allocateHomogeneous(self, x, y, w, h, designW, designH, scale)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = h - spacingSpace
	local hEach = math.max(0, availableSpace / childCount)

	local startY = y + h/2 * self.dir
	local increment = (hEach + spacing) * -self.dir
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local thisY = startY - hEach/2 * self.dir
			self:_allocateChild(child, x, thisY, w, hEach*percent, scale)
			startY = startY + increment
		end
	end
end

function EditorGuiColumn.allocateHeterogeneous(self, x, y, w, h, designW, designH, scale)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = h - spacingSpace
	local totalChildH, totalGreedyChildH = self:getChildDimensionTotals("h", children)
	totalChildH, totalGreedyChildH = totalChildH*scale, totalGreedyChildH*scale
	local squashFactor = math.min(1, availableSpace / totalChildH)
	local extraH = math.max(0, availableSpace - totalChildH)
	local greedFactor = extraH / totalGreedyChildH

	local startY = y + h/2 * self.dir
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local childH = child:request().h * scale
			local thisH = childH * squashFactor
			if child.isGreedy then  thisH = thisH + childH * greedFactor  end
			local thisY = startY - thisH/2 * self.dir
			self:_allocateChild(child, x, thisY, w, thisH*percent, scale)
			startY = startY - (thisH + spacing) * self.dir
		end
	end
end

return EditorGuiColumn
