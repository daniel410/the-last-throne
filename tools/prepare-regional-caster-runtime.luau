-- Run in Edit after the approved v2 imports. Never publishes a Place.
local storage=game:GetService('ServerStorage')
local imported=assert(storage:FindFirstChild('RegionalCasterImported'))
assert(not storage:FindFirstChild('RegionalCasterModels'),'Do not replace an existing prepared export')
local runtime=Instance.new('Folder');runtime.Name='RegionalCasterModels'
local export=Instance.new('Folder');export.Name='MR01PreparedExports'
local clips={'-- Generated from the actual Roblox v2 import; normalized Bone.Transform samples.\nreturn {\n'}
local manifest={}
for _,kind in ipairs({'QueenIceElf','VolcanoShaman','KingVolcanoShaman'})do
 local original=assert(imported:FindFirstChild('TLT_MR01_'..kind))
 local bones={};for _,b in original:GetDescendants()do if b:IsA('Bone')then bones[b.Name]=b end end
 local nativeBasis=CFrame.Angles(0,math.pi,0)
 local model=original:Clone();model.Name=kind
 local root=assert(model:FindFirstChild('RootPart'));model.PrimaryPart=root
 model:PivotTo(CFrame.identity)
 local legacyFolder=kind=='QueenIceElf' and storage.FrozenValeModels or storage.EmberCalderaModels
 local legacyName=({QueenIceElf='queen_ice_elf',VolcanoShaman='volcano_shaman',KingVolcanoShaman='king_volcano_shaman'})[kind]
 local height=assert(legacyFolder:FindFirstChild(legacyName)):FindFirstChild('TargetHeight').Value
 local target=Instance.new('NumberValue');target.Name='TargetHeight';target.Value=height;target.Parent=model
 local record={kind=kind,targetHeight=height,meshes={},bones=0,clips={}}
 table.insert(clips,'['..string.format('%q',kind)..']={\n')
 for _,o in original:GetDescendants()do
  if o:IsA('KeyframeSequence')then
   local frames=o:GetKeyframes();table.sort(frames,function(a,b)return a.Time<b.Time end)
   assert(#frames==41,'Unexpected imported sample count')
   local duration=frames[#frames].Time;table.insert(record.clips,{name=o.Name,samples=#frames,duration=duration})
   table.insert(clips,'['..string.format('%q',o.Name)..']=(function() return {duration='..string.format('%.9g',duration)..',frames={\n')
   for _,key in frames do
    table.insert(clips,'{time='..string.format('%.9g',key.Time)..',pose={')
    for _,pose in key:GetDescendants()do if pose:IsA('Pose')then
     -- Imported Pose deltas reconstruct glTF locals, whereas rest Bones and
     -- mesh geometry use (-X,+Y,-Z). Retarget before assigning Bone.Transform.
     local rest=assert(bones[pose.Name]).CFrame
     local frame=rest:Inverse()*nativeBasis*(rest*pose.CFrame)*nativeBasis:Inverse()
     local values={frame:GetComponents()};local numbers={}
     for _,v in values do table.insert(numbers,string.format('%.9g',v))end
     table.insert(clips,'['..string.format('%q',pose.Name)..']=CFrame.new('..table.concat(numbers,',')..'),')
    end end
    table.insert(clips,'}},\n')
   end
   table.insert(clips,'}} end)(),\n')
  end
 end
 table.insert(clips,'},\n')
 for _,o in model:GetChildren()do
  if o:IsA('Folder') or o:IsA('ObjectValue') or o:IsA('AnimationController')then o:Destroy()end
 end
 for _,o in model:GetDescendants()do
  if o:IsA('Bone')then record.bones+=1 end
  if o:IsA('BasePart')then
   o.Anchored=true;o.Massless=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false
   if o:IsA('MeshPart')then
    o.Name=string.find(o.Name,'Staff') and 'Staff' or 'Body'
    table.insert(record.meshes,{part=o.Name,mesh=o.MeshId,texture=o.TextureID,size={o.Size.X,o.Size.Y,o.Size.Z}})
   else o.Transparency=1 end
  end
 end
 root.Name='VisualRoot';model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 assert(record.bones==9 and #record.meshes==2 and #record.clips==10,'Import contract mismatch')
 model.Parent=runtime;table.insert(manifest,record)
end
table.insert(clips,'}\n')
local source=table.concat(clips)
for start=1,#source,10000 do local value=Instance.new('StringValue');value.Name='Clips'..math.floor((start-1)/10000+1);value.Value=source:sub(start,start+9999);value.Parent=export end
local binary=game:GetService('SerializationService'):SerializeInstancesAsync({runtime})
for start=0,buffer.len(binary)-1,10000 do
 local a={};for i=start,math.min(start+9999,buffer.len(binary)-1)do table.insert(a,string.format('%02x',buffer.readu8(binary,i)))end
 local value=Instance.new('StringValue');value.Name='Runtime'..math.floor(start/10000+1);value.Value=table.concat(a);value.Parent=export
end
runtime.Parent=storage;export.Parent=storage
return {runtimeBytes=buffer.len(binary),clipBytes=#source,runtimeChunks=math.ceil(buffer.len(binary)/10000),clipChunks=math.ceil(#source/10000),models=manifest}
