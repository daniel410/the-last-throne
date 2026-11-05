-- Execute the actual layout body with geometry adapters; no rendered-device claim.
local f=assert(io.open('src/client/DeepwoodMap.luau'));local source=f:read('*a');f:close()
local a=assert(source:find(' layout=function()',1,true));local b=assert(source:find(' area:GetPropertyChangedSignal',a,true))
local layoutSource=source:sub(a,b-1)
local U={new=function(xs,x,ys,y)return {xs=xs,x=x,ys=ys,y=y}end,fromOffset=function(x,y)return {xs=0,x=x,ys=0,y=y}end}
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function rect(item,parent)
 return {x=item.Position.xs*parent.x+item.Position.x,y=item.Position.ys*parent.y+item.Position.y,w=item.Size.xs*parent.x+item.Size.x,h=item.Size.ys*parent.y+item.Size.y}
end
for _,size in ipairs({{1920,1080},{1366,768},{844,390},{667,375},{390,844},{320,568}})do
 for _,visible in ipairs({false,true})do
  local env={gui={AbsoluteSize={X=size[1],Y=size[2]}},workspace={CurrentCamera={}},UDim2=U,
   panel={Subtitle={}},title={},progress={},detail={},legend={},hint={},navigation={Caption={}},journey={},epicTabs={},compass={},
   area={AbsoluteSize={X=0,Y=0}},travel={Visible=visible},minus={},plus={},fit={},you={}}
  setmetatable(env,{__index=_G})
  assert(load('local layout\n'..layoutSource..'\nreturn layout',nil,'t',env))()()
  local dimensions={x=env.panel.Size.x,y=env.panel.Size.y}
  if visible then
   local t=rect(env.travel,dimensions);local map=rect(env.area,dimensions);local nav=rect(env.navigation,dimensions)
   check(t.h>=40 and t.w>=200,'travel remains an actionable touch target')
   check(t.x>=0 and t.x+t.w<=dimensions.x and t.y>=0,'travel stays inside the panel')
   check(map.y+map.h<=t.y,'travel does not cover cartography')
   check(t.y+t.h<=nav.y,'travel does not cover navigation controls')
   if size[1]<650 or size[2]<540 then check(not env.detail.Visible,'compact travel row does not overlap region prose')
   else
    local d=rect(env.detail,dimensions);check(d.x+d.w<=t.x,'desktop region description and travel button have separate space')
   end
  else check(env.detail.Visible,'normal map description is preserved without travel')end
 end
end
print('Checkpoint map layout: '..n..' checks passed')
