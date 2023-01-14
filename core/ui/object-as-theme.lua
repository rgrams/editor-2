
-- Generic Ruu widget theme for all widgets.
-- Passes on the theme function calls to the widget's object.

-- Using the object directly as the theme would cause conflicts with init().
-- Also, the object `self` would have to be grabbed from the widget each time,
-- instead of being the first argument as expected.

return {
	-- Common widget callbacks:
	init = function() end, -- Ignored. Use object set(), init(), or initRuu() instead.
	hover = function(wgt) wgt.object:hover(wgt) end,
	unhover = function(wgt) wgt.object:unhover(wgt) end,
	focus = function(wgt, isKbd) wgt.object:focus(wgt, isKbd) end,
	unfocus = function(wgt, isKbd) wgt.object:unfocus(wgt, isKbd) end,
	press = function(wgt, mx, my, isKbd) wgt.object:press(wgt, mx, my, isKbd) end,
	release = function(wgt, dontFire, mx, my, isKbd) wgt.object:release(wgt, dontFire, mx, my, isKbd) end,
	-- Checkbox callbacks:
	setChecked = function(wgt, isChecked) wgt.object:setChecked(wgt, isChecked) end,
	-- Slider/Custom callbacks:
	drag = function(wgt, dx, dy) wgt.objct:drag(wgt, dx, dy) end,
	-- InputField callbacks:
	updateText = function(wgt) wgt.object:updateText(wgt) end,
	textRejected = function(wgt, rejectedText) wgt.object:textRejected(wgt, rejectedText) end,
	updateSelection = function(wgt) wgt.object:updateSelection(wgt) end,
	updateCursorPos = function(wgt) wgt.object:updateCursorPos(wgt) end,
}
