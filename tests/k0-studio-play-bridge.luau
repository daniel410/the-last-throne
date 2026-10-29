-- Keep an isolated, unpublished Studio open for manual Play inspection.
-- Run only with a local place; this does not publish or modify live data.
assert(game.PlaceId == 0, "Studio Play bridge requires an unpublished local place")
print("K0_STUDIO_PLAY_BRIDGE_READY")
task.wait(1800)
