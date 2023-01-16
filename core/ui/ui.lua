return {
	isSceneFile = true,
	useProjectLocalPaths = true,
	objects = {
		{
			class = "GUI Column",
			id = "4VmrwF",
			name = "UI",
			size = { x = 1600, y = 900 },
			properties = {
				Class = "core.ui.UI",
			},
			children = {
				{
					class = "GUI Row",
					id = "BMFK6Q",
					name = "Toolbar",
					size = { x = 100, y = 26 },
					modeX = "fill",
					properties = {
						Class = "core.ui.Toolbar",
					},
				},
				{
					class = "GUI Row",
					id = "i6fFTu",
					name = "MainRow",
					modeX = "fill",
					modeY = "fill",
					properties = {
						isGreedy = true,
					},
					children = {
						{
							class = "GUI Column",
							id = "nsgHG0",
							name = "VPColumn",
							modeX = "fill",
							modeY = "fill",
							properties = {
								isGreedy = true,
							},
							children = {
								{
									class = "GUI Row",
									id = "7qnDLa",
									name = "TabBar",
									size = { x = 100, y = 24 },
									modeX = "fill",
									spacing = 2,
									properties = {
										Class = "core.ui.TabBar",
									},
								},
								{
									class = "GUI Node",
									id = "5DixsW",
									name = "Viewport",
									size = { x = 50, y = 50 },
									modeX = "fill",
									modeY = "fill",
									properties = {
										isGreedy = true,
										Class = "core.ui.Viewport",
									},
								},
							}
						},
						{
							class = "GUI Node",
							id = "vk73mJ",
							name = "ResizeHandle",
							size = { x = 6, y = 6 },
							modeY = "fill",
							properties = {
								Class = "core.ui.widgets.ResizeHandle",
								target = "/Window/UI/MainRow/PropertyPanel",
							},
						},
						{
							class = "GUI Column",
							id = "BhT1KG",
							name = "PropertyPanel",
							size = { x = 250, y = 600 },
							pivot = "E",
							anchor = "E",
							modeX = "fill",
							modeY = "fill",
							pad = { x = 4, y = 4 },
							properties = {
								Class = "core.ui.PropertyPanel",
							},
						},
					}
				},
			}
		},
	},
}
