
local EditorGuiColumn = require "core.objects.EditorGuiColumn"
local EditorGuiRow = EditorGuiColumn:extend()

EditorGuiRow.className = "EditorGuiRow"
EditorGuiRow.displayName = "GUI Row"

_G.objClassList:add(EditorGuiRow, EditorGuiRow.displayName)

function EditorGuiRow.allocateChildren(self)
	if not self.path then  return  end -- Gets called from propertyWasSet before init.
	gui.Row.allocateChildren(self)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiRow.allocateChild(self, child)
	gui.Row.allocateChild(self, child)
end

-- The same as Column, just swapped directions (x/y, w/h).
function EditorGuiRow.allocateHomogeneous(self, x, y, w, h, designW, designH, scale)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = w - spacingSpace
	local wEach = math.max(0, availableSpace / childCount)

	local startX = x + w/2 * self.dir
	local increment = (wEach + spacing) * -self.dir
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local thisX = startX - wEach/2 * self.dir
			self:_allocateChild(child, thisX, y, wEach*percent, h, scale)
			startX = startX + increment
		end
	end
end

-- The same as Column, just swapped directions (x/y, w/h).
function EditorGuiRow.allocateHeterogeneous(self, x, y, w, h, designW, designH, scale)
	if not self.children then  return  end
	local children = self.getRealChildList(self.children)
	local childCount = self:countChildren(children)
	if childCount == 0 then  return  end

	local spacing = self.spacing * scale
	local spacingSpace = spacing * (childCount - 1)
	local availableSpace = w - spacingSpace
	local totalChildW, totalGreedyChildW = self:getChildDimensionTotals("w")
	totalChildW, totalGreedyChildW = totalChildW*scale, totalGreedyChildW*scale
	local squashFactor = math.min(1, availableSpace / totalChildW)
	local extraW = math.max(0, availableSpace - totalChildW)
	local greedFactor = extraW / totalGreedyChildW

	local startX = x + w/2 * self.dir
	local percent = math.abs(self.dir)

	for i=1,#children do
		local child = children[i]
		if child then
			local childW = child:request().w * scale
			local thisW = childW * squashFactor
			if child.isGreedy then  thisW = thisW + childW * greedFactor  end
			local thisX = startX - thisW/2 * self.dir
			self:_allocateChild(child, thisX, y, thisW*percent, h, scale)
			startX = startX - (thisW + spacing) * self.dir
		end
	end
end

return EditorGuiRow
