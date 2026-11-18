-- Fresh isolated 0.113.2 QA copy; install candidate ModuleScript beside CampaignWorld first.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,s in ipairs(game:GetDescendants())do if s:IsA('BaseScript')then s.Disabled=true end end
_G.HGWorld=require(game.ServerScriptService.Server.World.CampaignWorld).create(5)
local source=game.ServerScriptService.Server.World.EpicWorldArt:Clone()
source.Name='TerraceReservationAudit'
source.Source=source.Source:gsub('return Art%s*$','Art.reservation=reservation;return Art')
source.Parent=game.ServerScriptService.Server.World
_G.TerraceSafe=require(source).reservation(_G.HGWorld,'HG-05')
_G.Terraces=require(game.ServerScriptService.Server.World.RoyalBurialTerracesCandidate).build(_G.HGWorld,_G.TerraceSafe)
