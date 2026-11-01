--!strict
-- Personal Restricted image; verified ownership/privacy and uploaded dimensions are recorded in evidence.
return {
	image = "rbxassetid://135608370136189",
	width = 1536,
	height = 1024,
	renderWidth = 1023,
	renderHeight = 682,
	framed = true,
	-- Body-only crops exclude each baked nameplate. Preserve the verified image IDs.
	navigationBodies = {
		shop = { x = 48, y = 6, width = 416, height = 394 },
		quests = { x = 548, y = 520, width = 446, height = 341 },
		hero = { x = 75, y = 15, width = 1090, height = 892 },
		towers = { x = 100, y = 10, width = 1145, height = 897 },
		maps = { x = 15, y = 165, width = 1120, height = 861 },
		party = { x = 5, y = 40, width = 1245, height = 860 },
	},
	navigationPlaque = {
		image = "rbxassetid://127394633978202", width = 1145, height = 1374, renderWidth = 853, renderHeight = 1024,
		region = { x = 55, y = 1026, width = 1050, height = 260 },
	},
	overrides = {
		maps = {
			image = "rbxassetid://127394633978202", width = 1145, height = 1374, renderWidth = 853, renderHeight = 1024,
			-- Trim transparent vertical padding so Maps matches the other menu emblems.
			regions = { maps = { x = 0, y = 160, width = 1145, height = 1140, captionY = 0.80, captionH = 0.133 } },
		},
		hero = {
			image = "rbxassetid://101441413467224", width = 1254, height = 1254, renderWidth = 1024, renderHeight = 1024,
			regions = { hero = { x = 0, y = 0, width = 1254, height = 1254, captionY = 0.76, captionH = 0.14 } },
		},
		towers = {
			image = "rbxassetid://134869184877363", width = 1254, height = 1254, renderWidth = 1024, renderHeight = 1024,
			regions = { towers = { x = 0, y = 0, width = 1254, height = 1254, captionY = 0.76, captionH = 0.14 } },
		},
		party = {
			image = "rbxassetid://135705589802868", width = 1254, height = 1254, renderWidth = 1024, renderHeight = 1024,
			regions = { party = { x = 0, y = 0, width = 1254, height = 1254, captionY = 0.76, captionH = 0.14 } },
		},
	},
	regions = {
		maps = { x = 0, y = 160, width = 1145, height = 1140, captionY = 0.80, captionH = 0.133 },
		shop = { x = 48, y = 6, width = 416, height = 504, captionY = 0.79, captionH = 0.17 },
		towers = { x = 550, y = 8, width = 454, height = 500, captionY = 0.79, captionH = 0.17 },
		hero = { x = 1076, y = 8, width = 416, height = 502, captionY = 0.79, captionH = 0.17 },
		party = { x = 4, y = 520, width = 504, height = 460, captionY = 0.75, captionH = 0.19 },
		quests = { x = 548, y = 520, width = 446, height = 460, captionY = 0.75, captionH = 0.19 },
		play = { x = 998, y = 800, width = 534, height = 164 },
	},
}
