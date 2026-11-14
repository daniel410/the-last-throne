-- Read-only regression probe: evaluates the actual client region expression.
local C=dofile('src/shared/CampaignContent.luau')
local file=assert(io.open('src/client/DeepwoodAtmosphere.luau'));local source=file:read('*a');file:close()
local expression=assert(source:match('local region=([^\n]+)'))
local classify=assert(load('return function(root) return '..expression..' end'))()
local expected={[1]='Deepwood',[2]='Gloamwood',[3]='FrozenVale',[4]='EmberCaldera',[5]='HauntedGraveyard'}
local ids={};for id in pairs(C.zones)do ids[#ids+1]=id end;table.sort(ids)
local failures,total=0,0
for _,id in ipairs(ids)do
 local z=C.zones[id];local actual=classify({Position={Z=z.center[3]}});local want=expected[z.epic]
 total=total+1;if actual~=want then failures=failures+1 end
 print(string.format('%s %s Z=%.2f expected=%s actual=%s',actual==want and 'PASS' or 'FAIL',id,z.center[3],want,actual))
end
print(string.format('RESULT zones=%d mismatches=%d',total,failures))
if failures>0 then os.exit(1)end
