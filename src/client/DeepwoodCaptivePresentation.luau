-- Cage locks and occupants follow authoritative snapshots, never local completion.
local RS=game:GetService('ReplicatedStorage')
local C=require(RS.Shared.CampaignContent)
local Access=require(RS.Shared.CampaignAccess)
local View={}
local profiles={{'DW-04','spirit'},{'DW-05','prisoners'},{'DW-07','rescue_captives'}}
function View.create()
 local folder=Instance.new('Folder');folder.Name='PersonalCaptiveScenes';folder.Parent=workspace
 local scenes={};local heroId;local lastSnapshot;local api
 local added=RS.ChildAdded:Connect(function(child)if child.Name=='CaptiveSceneTemplates'and api then api.update(lastSnapshot)end end)
 local function clear()folder:ClearAllChildren();scenes={}end
 api={update=function(snapshot)
  lastSnapshot=snapshot
  if not snapshot or snapshot.training or not snapshot.journal or snapshot.mode and snapshot.mode~='Tutorial' then clear();return end
  if heroId~=snapshot.heroId then clear();heroId=snapshot.heroId end
  local journal=snapshot.journal
  local chapter=C.byId[journal.expeditionMission]or C.mainChapters[math.min(C.mainCount,journal.main+1)]
  if not chapter or chapter.epic~=1 then clear();return end
  local templates=RS:FindFirstChild('CaptiveSceneTemplates');if not templates then return end
  for _,spec in ipairs(profiles)do
   local c=C.byId[spec[1]];local key=spec[1]..':'..spec[2];local g
   for _,goal in ipairs(c.goals)do if goal.id==spec[2]then g=goal;break end end
   local scene=scenes[key]
   if not Access.allowed(journal,c.zone)then
    if scene then scene.model:Destroy();scenes[key]=nil end
   else
    local at=Vector3.new(table.unpack(g.position))
    if not scene then
     local model=Instance.new('Model');model.Name=key;model.Parent=folder
     local cage=templates.PrisonCage:Clone();cage.Name='RescueCage'
     cage:PivotTo(CFrame.new(at)*cage:GetPivot());cage.Parent=model
     for _,p in ipairs(cage:GetDescendants())do if p:IsA('BasePart')then p.CanCollide=true;p.CanTouch=false;p.CanQuery=false end end
     local actor=templates[spec[2]]:Clone();actor.Name='CaptiveResident';actor.Parent=model
     scene={model=model,cage=cage,actor=actor};scenes[key]=scene
    end
    local saved=(journal.activities or {})[key]or 0
    local complete=journal.flags and journal.flags[key]or false
    local attempt=snapshot.activities and snapshot.activities[key]
    local opened=complete or saved>0 or attempt~=nil
    scene.model:SetAttribute('RescueOpen',opened)
    local caption=scene.actor.PrimaryPart:FindFirstChild('NPCLabel')
    if caption then caption.TextLabel.Text=opened and g.activity.actor or (spec[2]=='spirit'and 'Captive Forest Friend'or 'Captive Resident')end
    local door=scene.cage.RescueDoor
    local closed=CFrame.new(at)*door:GetAttribute('ClosedLocalPivot')
    door:PivotTo(opened and closed*CFrame.Angles(0,math.rad(-110),0)or closed)
    local position=at+Vector3.new(0,.4,0)
    if complete then position=Vector3.new(table.unpack(g.activity.steps[#g.activity.steps].position))
    elseif saved>0 then position=Vector3.new(table.unpack(g.activity.steps[saved].position))end
    scene.actor:PivotTo(CFrame.new(position))
    -- The server escort replaces the captive; no second resident follows them.
    for _,p in ipairs(scene.actor:GetDescendants())do
     if p:IsA('BasePart')or p:IsA('Decal')then p.LocalTransparencyModifier=attempt and 1 or 0
     elseif p:IsA('BillboardGui')then p.Enabled=not attempt end
    end
   end
  end
 end,destroy=function()added:Disconnect();folder:Destroy()end}
 return api
end
return View
