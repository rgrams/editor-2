
local EditorGuiColumn = require "objects.EditorGuiColumn"
local EditorGuiRow = EditorGuiColumn:extend()

EditorGuiRow.className = "EditorGuiRow"
EditorGuiRow.displayName = "GUI Row"

_G.objClassList:add(EditorGuiRow, EditorGuiRow.displayName)

function EditorGuiRow.allocateChildren(self, forceUpdate)
	if not self.path then  return  end -- Gets called from propertyWasSet before init.
	gui.Row.allocateChildren(self, forceUpdate)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiRow.allocateChild(self, child, forceUpdate)
	gui.Row.allocateChild(self, child, forceUpdate)
end

-- The same as Column, just swapped directions (x/y, w/h).
function EditorGuiRow.allocateHomogeneous(self, alloc, forceUpdate)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * self._givenRect.scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = alloc.w - spacingSpace
	local h = alloc.h
	local w = math.max(0, availableSpace / childCount)

	local startX = alloc.x + alloc.w/2 * self.dir
	local increment = (w + spacing) * -self.dir
	local y = alloc.y
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local x = startX - w/2 * self.dir
			self:_allocateChild(child, x, y, w*percent, h, self._givenRect.scale, forceUpdate)
			startX = startX + increment
		end
	end
end

-- The same as Column, just swapped directions (x/y, w/h).
function EditorGuiRow.allocateHeterogeneous(self, alloc, forceUpdate)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * self._givenRect.scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = alloc.w - spacingSpace
	local totalChildW, totalGreedyChildW = self:getChildDimensionTotals("w", children)
	local squashFactor = math.min(1, availableSpace / totalChildW)
	local extraW = math.max(0, availableSpace - totalChildW)
	local greedFactor = extraW / totalGreedyChildW

	local h = alloc.h

	local startX = alloc.x + alloc.w/2 * self.dir
	local y = alloc.y
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local childW = child:request().w
			local w = childW * squashFactor
			if child.isGreedy then  w = w + childW * greedFactor  end
			local x = startX - w/2 * self.dir
			self:_allocateChild(child, x, y, w*percent, h, self._givenRect.scale, forceUpdate)
			startX = startX - (w + spacing) * self.dir
		end
	end
end

return EditorGuiRow
