
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiMask = EditorGuiNode:extend()
EditorGuiMask.className = "EditorGuiMask"
EditorGuiMask.displayName = "GUI Mask"

_G.objClassList:add(EditorGuiMask, EditorGuiMask.displayName)

function EditorGuiMask.set(self)
	EditorGuiMask.super.set(self)
	self.stencilFunc = function()
		local w, h = self.contentAlloc.w, self.contentAlloc.h
		love.graphics.rectangle("fill", -w/2, -h/2, w, h)
	end
end

function EditorGuiMask.enableMask(self)
	local _, value = love.graphics.getStencilTest()
	value = (value or 0) + 1
	love.graphics.setStencilTest("gequal", value)
	love.graphics.stencil(self.stencilFunc, "increment", nil, true)
end

function EditorGuiMask.disableMask(self)
	local _, value = love.graphics.getStencilTest()
	value = math.max(0, value - 1)
	love.graphics.stencil(self.stencilFunc, "decrement", nil, true)
	if value == 0 then
		love.graphics.setStencilTest()
	else
		love.graphics.setStencilTest("gequal", value)
	end
end

function EditorGuiMask.setMaskOnChildren(self, children, isEnabled)
	if not children then  return  end
	for i=1,children.maxn or #children do
		local child = children[i]
		if child then
			if isEnabled then                     child.maskObject = self
			elseif child.maskObject == self then  child.maskObject = nil  end
			if child.children and not child:is(EditorGuiMask) then
				self:setMaskOnChildren(child.children, isEnabled)
			end
		end
	end
end

function EditorGuiMask.childrenModified(self)
	self:setMaskOnChildren(self.children, true)
end

function EditorGuiMask.init(self)
	EditorGuiMask.super.init(self)
	self:setMaskOnChildren(self.children, true)
end

function EditorGuiMask.final(self)
	self:setMaskOnChildren(self.children, false)
end

return EditorGuiMask
