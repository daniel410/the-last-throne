-- Preserve the Frozen Vale entry point and its attribute contract.
local Shared=require(script.Parent.CampaignSurfaceUnderlays)
return {version=1,apply=function(world)return Shared.apply(world,'FV')end}
