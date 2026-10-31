local Client=game.StarterPlayer.StarterPlayerScripts.Client
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local P=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local screen=Instance.new('ScreenGui');screen.Name='EmberCalderaUiQA';screen.Parent=game.CoreGui
local report={kind='EMBER_CALDERA_UI_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,e=xpcall(function()
 local book=require(Client.DeepwoodQuestBook).create(screen,function()end)
 local journal=P.new()
 local function text()local lines={}for _,v in ipairs(book.panel:GetDescendants())do if v:IsA('TextLabel')then table.insert(lines,v.Text)end end;return table.concat(lines,'\n')end
 for n=1,21 do
  local c=C.mainChapters[n]
  if n>=15 then book.setTab('Main');book.render({journal=journal});local t=text();check(t:find('EPIC 3',1,true)~=nil,'Frozen epic title');check(t:find('MAIN STORY '..(n-14)..' / 7',1,true)~=nil,'local chapter numbering');check(t:find(c.title,1,true)~=nil,'current frozen story title')end
  for _,g in ipairs(c.goals)do if not g.optional then
   if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
   else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary' or nil))end
  end end
 end
 book.render({journal=journal});check(text():find('EPIC COMPLETE',1,true)~=nil,'epic completion');check(text():find('Gloamwood',1,true)~=nil,'next expedition status')
 book.setTab('Side');local t=text();for _,c in ipairs(C.chapters)do if c.epic==3 and c.side then check(t:find(c.title,1,true)~=nil,'optional request visible '..c.id)end end
 book.panel:Destroy()
 local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(900,600);frame.Parent=screen
 local canvas=require(Client.DeepwoodMapCanvas).create(frame,nil,false)
 local count=0;for _ in pairs(canvas.rows)do count+=1 end;check(count==30,'twenty campaign map regions')
 local root=Instance.new('Part');root.CFrame=CFrame.new(table.unpack(C.zones['EC-07'].center))
 canvas.update({journal=journal},root,root.Position);check(canvas.pin.Visible and canvas.objective.Visible,'winter player/objective project into atlas')
 local p=canvas.project(root.Position.X,root.Position.Z);check(p.X>0 and p.X<1 and p.Y>0 and p.Y<1,'winter world projection remains inside atlas')
 for id in pairs(require(game.ReplicatedStorage.Shared.EmberCalderaContent).zones)do check(canvas.rows[id]~=nil,'winter region selectable '..id)end
 root:Destroy()
end,debug.traceback)
screen:Destroy();if not ok then table.insert(report.failures,tostring(e))end;report.pass=#report.failures==0;return report
