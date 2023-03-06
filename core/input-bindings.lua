-- { actionType, inputStr, actionName, ignoresMods }
return {
	{ "cursor", "mouse moved" },
	{ "button", "M:1", "click", true },
	{ "button", "M:2", "right click", true },
	{ "button", "M:3", "pan camera", true },
	{ "button", "space", "pan camera", true },

	{ "button", "M:wheely+", "scroll", true },
	{ "button", "M:wheely-", "scroll", true },

	{ "button", "up", "up", true },
	{ "button", "down", "down", true },
	{ "button", "left", "left", true },
	{ "button", "right", "right", true },

	{ "button", "tab", "next" },
	{ "button", "shift tab", "prev" },

	{ "button", "return", "enter" },
	{ "button", "kpenter", "enter" },
	{ "text", "text" },
	{ "button", "backspace", "backspace", true },
	{ "button", "delete", "delete", true },
	{ "button", "end", "end" },
	{ "button", "home", "home" },
	{ "button", "escape", "cancel" },
	{ "button", "lshift", "selection modifier", true },
	{ "button", "rshift", "selection modifier", true },

	{ "button", "lctrl", "snap", true },
	{ "button", "rctrl", "snap", true },

	{ "button", "ctrl a", "select all" },
	{ "button", "a", "add modifier", true },
	{ "button", "shift a", "add" },
	{ "button", "alt a", "add scene" },
	{ "button", "alt shift a", "add last scene" },
	{ "button", "ctrl z", "undo" },
	{ "button", "ctrl shift z", "redo" },
	{ "button", "ctrl x", "cut" },
	{ "button", "ctrl c", "copy" },
	{ "button", "ctrl v", "paste" },
	{ "button", "ctrl n", "new scene" },
	{ "button", "ctrl s", "save" },
	{ "button", "ctrl shift s", "save as" },
	{ "button", "ctrl o", "open" },
	{ "button", "ctrl e", "export" },
	{ "button", "ctrl shift e", "export as" },
	{ "button", "ctrl shift a", "add property" },
	{ "button", "0", "zero position" },
	{ "button", "shift 0", "zero rotation" },
	{ "button", "kp0", "zero position" },
	{ "button", "shift kp0", "zero rotation" },
	{ "button", ";", "force drag modifier", true },
	{ "button", "ctrl tab", "next tab" },
	{ "button", "ctrl shift tab", "prev tab" },
	{ "button", "ctrl w", "close tab" },
	{ "button", "1", "default tool" },
	{ "button", "2", "polygon tool" },
	{ "button", "f5", "run game" },
	{ "button", "d", "duplicate drag modifier", true },
	{ "button", "p", "select parent" },
}
