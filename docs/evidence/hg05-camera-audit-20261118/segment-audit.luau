local root=workspace.DeepwoodCampaign
local origin=Vector3.new(-270,197,-17330)
local target=Vector3.new(-285,190,-17359)
local function intersect(cf,size)
 local a=cf:PointToObjectSpace(origin) local d=cf:VectorToObjectSpace(target-origin) local lo,hi=0,1
 for _,axis in ipairs({'X','Y','Z'})do
  local h=size[axis]*.5
  if math.abs(d[axis])<1e-7 then if math.abs(a[axis])>h then return nil end
  else local t1=(-h-a[axis])/d[axis] local t2=(h-a[axis])/d[axis] if t1>t2 then t1,t2=t2,t1 end lo=math.max(lo,t1) hi=math.min(hi,t2) if lo>hi then return nil end end
 end return lo
end
local hits={} local parts=0
for _,v in ipairs(root:GetDescendants())do
 if v:IsA('BasePart')then parts+=1
  if v.Transparency<.95 then local t=intersect(v.CFrame,v.Size) if t then table.insert(hits,{path=v:GetFullName(),t=t,position=tostring(v.Position),size=tostring(v.Size),query=v.CanQuery,collide=v.CanCollide,transparency=v.Transparency,class=v.ClassName,shape=v:IsA('Part') and tostring(v.Shape) or nil})end end
 end
end
table.sort(hits,function(a,b)return a.t<b.t end)
local art={} for _,v in ipairs(root.CampaignExpansion.Epic5['HG-05_exp_1']:GetDescendants())do if v:IsA('BasePart') and (v.Name:find('Conduit') or v.Name:find('Shield')) then table.insert(art,{path=v:GetFullName(),position=tostring(v.Position),size=tostring(v.Size),query=v.CanQuery})end end
return game:GetService('HttpService'):JSONEncode({origin=tostring(origin),target=tostring(target),parts=parts,hits=hits,art=art})
