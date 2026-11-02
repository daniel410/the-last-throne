if game then return {} end
local Rules=dofile('src/shared/DodgeRules.luau')
local Config=dofile('src/shared/K0Config.luau')
local roll=Config.Dodge.sideRoll
local n=0
local function eq(a,b,label)n=n+1;assert(a==b,label)end
local function near(a,b,label)n=n+1;assert(math.abs(a-b)<1e-8,label)end
local first={kind='Backstep',started=10}
for _,case in ipairs({{0,false},{.01,true},{.15,true},{.30,true},{.30001,false},{.65,false},{-1,false}}) do
 eq(Rules.canRoll(first,10+case[1],Config.Dodge.doubleTapWindow),case[2],'double-tap timing '..case[1])
end
eq(Rules.canRoll(nil,10,.3),false,'no roll without accepted first dodge')
eq(Rules.canRoll({kind='SideRoll',started=10},10.1,.3),false,'roll cannot restart itself')
for _,case in ipairs({{-1,-1},{-.16,-1},{-.15,1},{0,1},{1,1}}) do eq(Rules.rollSide(case[1]),case[2],'side')end
eq(Config.Dodge.distance,7,'single backstep distance unchanged')
eq(Config.Dodge.moveDuration,.30,'single backstep timing unchanged')
eq(roll.distance,2*Config.Dodge.distance,'side roll twice as far')
for _,side in ipairs({-1,1}) do
 local angle,drop,tuck=Rules.rollPose(0,roll.moveDuration,side,roll.jumpHeight)
 near(angle,0,'neutral start');near(drop,0,'start height');near(tuck,0,'start pose')
 angle,drop,tuck=Rules.rollPose(roll.moveDuration/2,roll.moveDuration,side,roll.jumpHeight)
 near(angle,-math.pi*side,'half turn');near(drop,roll.jumpHeight,'jump apex');near(tuck,1,'tuck legs')
 angle,drop,tuck=Rules.rollPose(roll.moveDuration,roll.moveDuration,side,roll.jumpHeight)
 near(angle,-2*math.pi*side,'full turn');near(drop,0,'end height');near(tuck,0,'end pose')
 for _,hz in ipairs({30,60,144}) do
  local previous=0
  for frame=0,math.ceil(.65*hz) do
   local a,d,t=Rules.rollPose(frame/hz,roll.moveDuration,side,roll.jumpHeight)
   eq(math.abs(a)+1e-8>=previous,true,'continuous full roll progress')
   eq(t>=-1e-8 and t<=1+1e-8,true,'bounded tuck')
   eq(d>=-1e-8 and d<=roll.jumpHeight+1e-8,true,'bounded jump height')
   previous=math.abs(a)
  end
 end
end
print('Dodge double tap: '..n..' checks passed')
