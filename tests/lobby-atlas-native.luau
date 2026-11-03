-- Real battle canvas in the lobby; snapshots never mutate progression.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='LOBBY_ATLAS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='LobbyAtlasQA';gui.Parent=game.CoreGui
local host=Instance.new('Frame');host.Size=UDim2.fromOffset(1000,750);host.Parent=gui
local view=require(client.LobbyAtlas).create(host)
local function snap(main)return {heroId='h',heroes={h={deepwood={main=main,explored={},clears={}}}}}end
local function countRows(open)
 local n=0
 for _,row in pairs(view.rows())do n+=1;if open~=nil then check(row.name:GetAttribute('Accessible')==open,'real progression controls lock state')end end
 return n
end
local ok,err=xpcall(function()
 view.show(nil);check(countRows(false)==10,'no hero cannot claim any unlocked regions')
 view.update(snap(0));check(view.rows()['DW-01'].name:GetAttribute('Accessible'),'first region open')
 check(not view.rows()['DW-02'].name:GetAttribute('Accessible'),'later story stays locked')
 view.selectRegion('DW-02');check(view.root.RegionDetail.Text:find('LOCKED',1,true)~=nil and view.root.RegionDetail.Text:find('Complete',1,true)~=nil,'locked region explains prerequisite')
 view.selectEpic(2);check(countRows(false)==10,'all Frozen Vale regions visible while locked')
 view.update(snap(7));check(view.rows()['FV-01'].name:GetAttribute('Accessible'),'Frozen Vale opens after Deepwood')
 check(not view.rows()['FV-02'].name:GetAttribute('Accessible'),'Frozen Vale later story remains locked')
 view.selectEpic(3);check(countRows(false)==10,'all Ember Caldera regions visible while locked')
 view.update(snap(14));check(view.rows()['EC-01'].name:GetAttribute('Accessible'),'Ember opens after Frozen Vale')
 for _,i in ipairs({4,5})do view.selectEpic(i);check(countRows(false)==7,'late epic has seven gated regions')end
 view.update(snap(21));view.selectEpic(4);check(view.rows()['GW-01'].name:GetAttribute('Accessible')and not view.rows()['GW-02'].name:GetAttribute('Accessible'),'Gloamwood opens after EC')
 view.update(snap(28));view.selectEpic(5);check(view.rows()['HG-01'].name:GetAttribute('Accessible')and not view.rows()['HG-02'].name:GetAttribute('Accessible'),'HG opens after Gloamwood')
 view.selectEpic(1);view.update(snap(21));check(countRows(true)==10,'complete story unlocks entire Deepwood')
 for _,size in ipairs({Vector2.new(1000,750),Vector2.new(366,756),Vector2.new(643,293)})do
  host.Size=UDim2.fromOffset(size.X,size.Y);task.wait()
  local root=view.root;local area=root.Atlas
  check(area.AbsoluteSize.X>0 and area.AbsoluteSize.Y>0,'positive atlas bounds on desktop, portrait, short landscape')
  check(area.AbsolutePosition.Y+area.AbsoluteSize.Y<=root.RegionDetail.AbsolutePosition.Y+.1,'map does not cover detail controls')
  check(root.EpicCategories.AbsoluteSize.Y>=44,'touch category height')
  check(root.Zoom.Caption.TextFits and root.Fit.Caption.TextFits,'map control labels fit')
  check(root.Fit.AbsolutePosition.X+root.Fit.AbsoluteSize.X<=root.Zoom.AbsolutePosition.X and root.Zoom.AbsolutePosition.X+root.Zoom.AbsoluteSize.X<=root.AbsolutePosition.X+root.AbsoluteSize.X+1,'map controls do not overlap or leave the panel')
  check(area.CanvasSize.X.Offset>=area.AbsoluteSize.X,'map remains scrollable')
 end
 -- Existing battle full atlas and minimap constructors still work.
 local Canvas=require(client.DeepwoodMapCanvas)
 local f=Instance.new('Frame');f.Size=UDim2.fromOffset(1000,750);f.Parent=gui
 local all=Canvas.create(f,nil,false);all.update({journal={main=0,explored={}}})
 local n=0;for _ in pairs(all.rows)do n+=1 end;check(n==44,'battle overview includes all44 regions')
 f:ClearAllChildren();local single=Canvas.create(f,'FV-01',true);single.update({journal={main=7,explored={}}});check(single.rows['FV-01']~=nil,'battle minimap retains single-region mode')
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok
return report
