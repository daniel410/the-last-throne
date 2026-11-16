-- Native outcomes required by the independent icon/VFX ART review.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Pixel=require(Client.PixelFX)
local report={checks=0,failures={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local camera=workspace.CurrentCamera;local old=camera.CFrame;camera.CFrame=CFrame.new(0,10,18)
local floor=Instance.new('Part');floor.Anchored=true;floor.Size=Vector3.new(200,.5,200);floor.Position=Vector3.new(0,-.25,0);floor.Parent=workspace
local first,last=Vector3.new(0,3,0),Vector3.new(0,3,-10)
local function cast(id,pulse,character)
 FX.clear();return assert(FX.skill(character,id,first,last,pulse or 1,{last}))
end
local function parts(m,name)
 local list={};for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')and p.Name==name then table.insert(list,p)end end;return list
end
local ok,err=xpcall(function()
 local m=cast('mage.pyro.molten_line')
 check(not m:FindFirstChild('FlameWake',true) and not m:FindFirstChild('FlameJet',true),'molten line has no airborne lance')
 check(#parts(m,'MoltenFlowCore')==6,'connected molten ground segments')
 for _,p in ipairs(parts(m,'MoltenFlowCore'))do check(p.Position.Y<.35,'molten seam stays within the raised cosmetic floor layer')end
 Pixel.clear()
 local accepted,terminal=Pixel.skill(nil,'mage.pyro.molten_line',first,last,1,{},nil,workspace:GetServerTimeNow())
 check(accepted and terminal.Position.Y<.3,'molten terminal accent is ground-centered')
 Pixel.clear()
 local water=cast('mage.common.water_ball');local ball=assert(water:FindFirstChild('WaterVolume',true))
 check(math.abs(ball.Size.Y-ball.Size.X)<.01 and ball.Material==Enum.Material.Glass,'Water Ball has a round liquid primary')
 check(not water:FindFirstChild('TidalLip',true),'water projectile does not have a ground ring')
 check(water:FindFirstChild('WaterSurfaceGlow',true).Material==Enum.Material.Neon,'water surface remains emissive in dark lighting')
 local ring=cast('mage_tidal_ring');check(ring:FindFirstChild('TidalLip',true)~=nil,'Tidal Ring retains its ground wave')
 local dimensions={}
 for _,id in ipairs({'frost_lance','ice_shard','shatter_dart','glacial_spike'})do
  local crystal=cast('mage.cryo.'..id);local p=assert(crystal:FindFirstChild('IceLanceVolume',true))
  dimensions[id]=p.Size
  check(#parts(crystal,'IceLanceFacet')>=8,'crystal has filled hard facets '..id)
 end
 check(dimensions.ice_shard.Z<dimensions.frost_lance.Z*.6 and dimensions.ice_shard.X>dimensions.frost_lance.X,'Ice Shard is short and wide relative to Frost Lance')
 check(dimensions.glacial_spike.Z>dimensions.frost_lance.Z*1.3 and dimensions.glacial_spike.X>dimensions.frost_lance.X*2,'Glacial Spike is visibly heavier than Frost Lance')
 check(dimensions.shatter_dart.Z<dimensions.ice_shard.Z,'Shatter Dart remains compact')
 local ward=cast('mage.cryo.ice_ward');check(#parts(ward,'IceWardPanel')>=6 and ward:FindFirstChild('IceWardCrest',true),'ice ward encloses the body with panels and a crest')
 local edge=assert(ward:FindFirstChild('IceWardPanelEdge',true))
 check(edge.Shape==Enum.PartType.Block and edge.Size.Z>edge.Size.X*10,'linear guard edges have elongated geometry rather than separate round dots')
 local storm=cast('mage.cryo.froststorm');check(storm:FindFirstChild('FroststormBand',true)and storm:FindFirstChild('FroststormFallingCrystal',true),'Froststorm has rising bands and falling ice')
 check(not storm:FindFirstChild('IceWardPanel',true),'storm is distinct from a personal shield')
 local thunder=cast('mage.cryo.thunder_spear');check(thunder:FindFirstChild('IconThunderSpearAxis',true)and not thunder:FindFirstChild('ElectricCore',true),'Thunder Spear has a straight axis rather than a chain')
 local lightning=cast('mage.cryo.lightning_line');local line=assert(lightning:FindFirstChild('IconLightningCorridor',true))
 check(line.Attachment0.WorldPosition.Y<.3 and line.Attachment1.WorldPosition.Y<.3,'Lightning Line is a low straight corridor')
 FX.clear();local chain=assert(FX.skill(nil,'mage.cryo.chain_lightning',first,last,1,{}))
 check(not chain:FindFirstChild('ElectricCore',true),'empty Chain Lightning still has no discharge')
 local gravity=cast('mage.common.gravity');check(gravity:FindFirstChild('GravityCore',true)and not gravity:FindFirstChild('ElementalSurface',true),'gravity has a dense core instead of a broad ring surface')
 local inward=assert(gravity:FindFirstChild('GravityInwardStone',true));local center=gravity:FindFirstChild('GravityCore',true).Position
 local before=(inward.Position-center).Magnitude;FX.step(workspace:GetServerTimeNow()+.2)
 check((inward.Position-center).Magnitude<before,'gravity fragments move inward')
 local axe=cast('dwarf.iron_axe.returning_echo',2)
 check(#parts(axe,'ThrownAxeBlade')>0 and axe:FindFirstChild('ThrownAxeHandle',true)and not axe:FindFirstChild('ProjectileSurface',true),'missing source draws a steel axe and handle instead of an arrow')
 local blade=parts(axe,'ThrownAxeBlade')[1];local initial=blade.CFrame;local now=workspace:GetServerTimeNow()
 FX.step(now+.08);local rotated=blade.CFrame;check(rotated~=initial,'thrown axe visibly rotates')
 FX.step(now+.16);FX.step(now+.08);check((blade.Position-rotated.Position).Magnitude<.002,'axe rotation is frame-history independent')
 local character=Instance.new('Model');character.Parent=workspace
 local appearance=Instance.new('Model');appearance:SetAttribute('WeaponClassId','dwarf');appearance.Parent=character
 local source=Instance.new('MeshPart');source.Name='Weapon';source.Anchored=true;source.CFrame=CFrame.new(2,3,1);source.Parent=appearance
 local scriptChild=Instance.new('Script');scriptChild.Parent=source
 local joint=Instance.new('WeldConstraint');joint.Part0=source;joint.Parent=source
 local pose=source.CFrame;local owner=source.Parent
 local equipped=cast('dwarf.iron_axe.breaker_throw',1,character);local copy=assert(equipped:FindFirstChild('ThrownAxeSource',true))
 check(copy:IsA('MeshPart')and not copy:FindFirstChildWhichIsA('BaseScript')and not copy:FindFirstChildWhichIsA('WeldConstraint'),'equipped mesh clone strips code and joints')
 FX.step(workspace:GetServerTimeNow()+.1);check(source.CFrame==pose and source.Parent==owner,'source weapon pose and ownership stay unchanged')
 FX.clear();character:Destroy()
 local leaves=cast('elf.magic_archer.bloom_shot');check(#parts(leaves,'NatureArrowLeaf')>=10,'Bloom Shot has five filled leaf petals')
 local rise=cast('mage.pyro.earth_rise');check(#parts(rise,'RisingCrag')==3,'Earth Rise has three height-varied pillars')
 local provoke=cast('knight.common.provoke');check(not provoke:FindFirstChild('ImpactFlare',true)and not provoke:FindFirstChild('WarcryOpenPressure',true),'zero-damage Provoke has voice cues without an impact explosion')
 FX.clear()
 local beforeNodes={};for _,p in ipairs(workspace:GetChildren())do beforeNodes[p]=true end
 Visual.play(nil,'mage.pyro.molten_line',first,last,1,{last},nil,workspace:GetServerTimeNow())
 for _,p in ipairs(workspace:GetChildren())do if not beforeNodes[p]then
  check(p.Name~='ElementalTrail','composed molten line has no airborne legacy trail')
  if p.Name~='HeroVFX'then p:Destroy()end
 end end
 FX.clear();camera.CFrame=CFrame.new(1000,10,0)
 Visual.play(nil,'mage.cryo.glacial_spike',first,last,1,{},nil,workspace:GetServerTimeNow())
 check(FX.count()==0 and workspace:FindFirstChild('IceCrystal')~=nil,'culled primary retains bounded legacy fallback')
 for _,p in ipairs(workspace:GetChildren())do if not beforeNodes[p]then p:Destroy()end end
 camera.CFrame=CFrame.new(0,10,18)
 for i=1,40 do FX.skill(nil,i%2==0 and 'mage.cryo.glacial_spike'or 'mage.cryo.eternal_tempest',first,last,1,{last})end
 local n,b,c,g,p,f=FX.count();check(n<=12 and b<=240 and c<=48 and g<=96 and p<=192 and f<=160,'new primary silhouettes share all original scene caps')
 FX.clear();check(select(6,FX.count())==0,'all added and cloned surfaces release their budget')
end,debug.traceback)
FX.clear();Pixel.clear();floor:Destroy();camera.CFrame=old
if not ok then table.insert(report.failures,err)end
report.pass=#report.failures==0
print('SKILL_VFX_ART_NATIVE '..game.HttpService:JSONEncode(report))
assert(report.pass,'ART outcome regression')
