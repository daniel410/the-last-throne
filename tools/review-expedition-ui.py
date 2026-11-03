from pathlib import Path
import runpy,json
ns=runpy.run_path('tools/prepare-difficulty-native-test.py');sources=ns['sources']
code='local sources='+ '{}\n'
code='local sources={\n'+''.join('['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False)+',\n'for k,v in sources.items())+'}\n'
code+='''
local originalGame=game
local tree={}
for path in pairs(sources)do
 local parent=tree
 for part in path:gmatch('[^/]+')do
  local name=part:gsub('%.luau$',''):gsub('%.lua$','')
  parent[name]=parent[name]or {Parent=parent};parent=parent[name]
 end
 parent.path=path
end
local signal=Instance.new('BindableEvent')
local actor={UserId=42,GetAttribute=function()return 'Lobby'end,GetAttributeChangedSignal=function()return signal.Event end}
local proxy={ReplicatedStorage={Shared=tree.src.shared},Players={LocalPlayer=actor}}
function proxy:GetService(name)return self[name]or originalGame:GetService(name)end
local cache={}
local function req(node)
 if cache[node]then return cache[node]end
 local fn=assert(loadstring(sources[node.path],'@'..node.path))
 setfenv(fn,setmetatable({game=proxy,script=node,require=req},{__index=getfenv()}))
 cache[node]=fn();return cache[node]
end
local existing=originalGame.CoreGui:FindFirstChild('TLT_ExpeditionUIReview');assert(not existing,'Review already exists')
local gui=Instance.new('ScreenGui');gui.Name='TLT_ExpeditionUIReview';gui.IgnoreGuiInset=true;gui.DisplayOrder=100000;gui.Parent=originalGame.CoreGui
local root=Instance.new('Frame');root.Name='ReviewCanvas';root.Size=UDim2.fromOffset(1108,707);root.BackgroundColor3=Color3.fromRGB(8,16,30);root.BorderSizePixel=0;root.Parent=gui
local view=req(tree.src.client.ExpeditionView).create(root,function()end)
local D=req(tree.src.shared.Difficulty);local content=req(tree.src.shared.CampaignContent)
local missions={}
for _,c in ipairs(content.chapters)do
 local modes={}
 for _,mode in ipairs(D.order)do modes[mode]={allowed=mode=='Easy'and c.id=='DW-01',reason=mode=='Easy'and 'StoryLocked'or 'DifficultyLevel',level=math.max(D.entry(c),D.modes[mode].level)}end
 table.insert(missions,{id=c.id,title=c.quest and c.quest.title or c.title,modes=modes})
end
local state={role='Lobby',configured=true,studio=false,population=1,capacity=20,selection={missionId='DW-01',difficultyId='Easy'},missions=missions,list={}}
view.render(state);view.panel.Visible=true;task.wait(.25)
local function measure(name)
 local panel=view.panel;local scroll=panel.PartyList;local solo=scroll:FindFirstChild('Solo');local launch=scroll:FindFirstChild('Launch')
 local function row(b)return b and {active=b.Active,y=b.AbsolutePosition.Y-scroll.AbsolutePosition.Y+scroll.CanvasPosition.Y,height=b.AbsoluteSize.Y,visibleAtTop=b.AbsolutePosition.Y+b.AbsoluteSize.Y<=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y}end
 local art=scroll.ModeEasy.TDButtonArt
 return {name=name,root={root.AbsoluteSize.X,root.AbsoluteSize.Y},panel={panel.AbsoluteSize.X,panel.AbsoluteSize.Y},scroll={scroll.AbsoluteSize.X,scroll.AbsoluteSize.Y},canvas=scroll.AbsoluteCanvasSize.Y,solo=row(solo),launch=row(launch),easyImage=art.Image,easyLoaded=art.IsLoaded,hellActive=scroll.ModeHell.Active}
end
local results={measure('desktop1108x707')}
root.Size=UDim2.fromOffset(844,390);task.wait(.25);table.insert(results,measure('mobile844x390'))
root.Size=UDim2.fromOffset(1108,707);task.wait(.25)
state.party={hostId=42,target=4,status='forming',members={}}
for i=1,4 do table.insert(state.party.members,{userId=i==1 and 42 or i,name='Review Hero '..i,classId=i==2 and 'mage'or 'knight',level=i==2 and 1 or 80,main=7,arrived=true,ready=false})end
state.selection.difficultyId='Hell';view.render(state);task.wait(.25);table.insert(results,measure('party-not-ready-lockedHell'))
state.party=nil;state.selection.difficultyId='Easy';view.render(state);task.wait(.25)
_G.TLTExpeditionReview={gui=gui,root=root,view=view,state=state,signal=signal}
return results
'''
Path('builds/expedition-ui-review.luau').write_text(code)
