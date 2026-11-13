-- Visual geometry acceptance in an isolated local build. No account access.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use a local isolated build')
local A=require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local V=require(game.ReplicatedStorage.Shared.FourFamilyArmorVisuals)
local folder=game.ServerStorage[V.folderName]
local report={kind='ARMOR_FIT_NATIVE',checks=0,eyes={},robes={},hats={},pass=false}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local function mul(a,b)return Vector3.new(a.X*b.X,a.Y*b.Y,a.Z*b.Z)end
local geometry={}
local function meshData(part)
 if geometry[part.MeshId]then return geometry[part.MeshId]end
 local e=assert(game.AssetService:CreateEditableMeshAsync(Content.fromUri(part.MeshId)))
 local points={};local lo=Vector3.new(math.huge,math.huge,math.huge);local hi=-lo
 for _,id in e:GetVertices()do local p=e:GetPosition(id);points[id]=p;lo=lo:Min(p);hi=hi:Max(p)end
 local faces={};for _,id in e:GetFaces()do table.insert(faces,e:GetFaceVertices(id))end
 e:Destroy();local data={points=points,faces=faces,center=(lo+hi)/2,size=hi-lo};geometry[part.MeshId]=data;return data
end
local function blocked(part,head,frame,heights)
 local data=meshData(part);local scale=Vector3.new(part.Size.X/data.size.X,part.Size.Y/data.size.Y,part.Size.Z/data.size.Z)
 local points={};for id,p in data.points do points[id]=frame:PointToWorldSpace(mul(p-data.center,scale))end
 local hits=0
 for _,sign in {-1,1}do for _,y in heights or {.18,.23,.28}do for _,dx in {-.025,0,.025}do
  local target=head.CFrame:PointToWorldSpace(Vector3.new(sign*(.18+dx)*head.Size.X,y*head.Size.Y,-head.Size.Z*.5))
  local origin=target+head.CFrame.LookVector*3;local direction=-head.CFrame.LookVector
  local occluded=false
  for _,face in data.faces do
   local a,b,c=points[face[1]],points[face[2]],points[face[3]]
   local edge1,edge2=b-a,c-a;local h=direction:Cross(edge2);local det=edge1:Dot(h)
   if math.abs(det)>1e-8 then
    local inv=1/det;local s=origin-a;local u=inv*s:Dot(h)
    if u>=0 and u<=1 then local q=s:Cross(edge1);local v=inv*direction:Dot(q)
     if v>=0 and u+v<=1 then local distance=inv*edge2:Dot(q)
      if distance>0 and distance<3-.001 then occluded=true;break end
     end
    end
   end
  end
  if occluded then hits+=1 end
 end end end
 return hits
end
local ok,err=xpcall(function()
 for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
  local d=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(d,rig);d:Destroy()
  c.Parent=workspace;c:PivotTo(CFrame.new(0,700,0));c.HumanoidRootPart.Anchored=true
  for _,family in {'traveler','tempered','veteran','sentinel'}do
   local prefix=family=='sentinel'and'sentinel_tier'or family
   c:SetAttribute('K0ClassId','knight');c:SetAttribute('TLTEquippedHead',prefix..'_hood');A.sync(c)
   local mesh=c.TLTArmor_head.Head;local head=c.Head
   local after=blocked(mesh,head,mesh.CFrame)
   local before=blocked(mesh,head,mesh.CFrame-head.CFrame.UpVector*(V.fit.helmetLift*head.Size.Y/1.182))
   table.insert(report.eyes,{rig=rig.Name,family=family,beforeBlocked=before,afterBlocked=after,samples=18})
   check(blocked(c.TLTArmor_head.Hair,head,c.TLTArmor_head.Hair.CFrame)==0,'helmet hair leaves eyes clear')
   check(after==0,'helmet leaves both eye regions clear '..rig.Name..'/'..family..' hits='..after)
   c:SetAttribute('K0ClassId','dwarf');A.sync(c)
   check(blocked(c.TLTArmor_head.Head,head,c.TLTArmor_head.Head.CFrame)==0,'Dwarf eyes clear '..family)
   check(blocked(c.TLTArmor_head.Hair,head,c.TLTArmor_head.Hair.CFrame)==0,'Dwarf hair leaves eyes clear')
   c:SetAttribute('K0ClassId','mage');c:SetAttribute('TLTEquippedHead','mage_'..family..'_hat')
   c:SetAttribute('TLTEquippedBody','mage_'..family..'_coat');A.sync(c)
   local torso=c:FindFirstChild('UpperTorso')or c:FindFirstChild('Torso')
   local shell=c.TLTArmor_body.UpperTorso
   local ratio=shell.Size.Z/torso.Size.Z
   check(ratio>1.2,'robe encloses body depth with cloth margin '..family)
   table.insert(report.robes,{rig=rig.Name,family=family,torsoDepth=torso.Size.Z,robeDepth=shell.Size.Z,ratio=ratio})
   check(blocked(c.TLTArmor_head.Hair,head,c.TLTArmor_head.Hair.CFrame)==0,'Mage forelocks leave eyes clear')
   local hat=c.TLTArmor_head.Head
   local ref=folder[family..'_hat'].Head
   local relative=head.CFrame:ToObjectSpace(hat.CFrame).Position.Y
   local old=(ref:GetAttribute('ArmorLocalCenter').Y-ref:GetAttribute('ArmorReferenceAnchor').Y)*head.Size.Y/1.182
   check(math.abs((old-relative)-V.fit.hatLowering*head.Size.Y/1.182)<.001,'hat seats lower on wearer head')
   local brimLow=relative-hat.Size.Y/2
   check(brimLow<head.Size.Y*.4,'hat brim intersects upper head rather than floating')
   table.insert(report.hats,{rig=rig.Name,family=family,brimBottomFromHeadCenter=brimLow,headTop=head.Size.Y/2})
   local previous=c.TLTArmor_head;previous:SetAttribute('ArmorFitVersion',1);A.sync(c)
   check(c.TLTArmor_head~=previous and c.TLTArmor_head:GetAttribute('ArmorFitVersion')==V.version,'old fitting is rebuilt once')
   c:SetAttribute('K0ClassId','elf');c:SetAttribute('TLTEquippedHead',prefix..'_hood');A.sync(c)
   check(blocked(c.TLTArmor_head.Hair,head,c.TLTArmor_head.Hair.CFrame)==0,'Elf forelocks leave eyes clear')
   local hood=c.TLTArmor_head.Head
   check(blocked(hood,head,hood.CFrame)==0,'Hood leaves both eyes clear '..rig.Name..'/'..family)
   check(blocked(hood,head,hood.CFrame,{-.10,-.15,-.20})==0,'Hood cowl leaves the mouth clear '..rig.Name..'/'..family)
  end
  c:Destroy()
 end
 local reproduced=false;for _,r in report.eyes do if r.beforeBlocked>0 then reproduced=true end end
 check(reproduced,'baseline reproduced eye occlusion in actual mesh triangles')
end,debug.traceback)
report.pass=ok;report.error=err
print('ARMOR_FIT_JSON '..game.HttpService:JSONEncode(report));assert(ok,err)
