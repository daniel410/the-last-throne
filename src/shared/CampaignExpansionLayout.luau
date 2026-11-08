-- Authored chapter layouts. Stable goal/step IDs survive spatial revisions.
local L={}
local chapters={
 DW={'creek','shelter','yard','tower','prison','roots','altar'},
 GW={'fork','web','refuge','roots','bank','extraction','ridge'},
 FV={'basin','cellar','ravine','archive','tunnel','court','terrace'},
 EC={'freight','workshop','mine','channels','circuit','gallery','furnace'},
 HG={'lanterns','council','crypt','gate','conduits','records','throne'},
}
local shapes={
 creek={148,122,{{-.36,-.2},{.32,-.3},{-.25,.32}}},shelter={132,116,{{-.3,-.23},{.18,.3},{-.33,.23}}},
 yard={142,130,{{-.34,-.29},{.3,.12},{-.27,.3}}},tower={120,150,{{-.35,.25},{.27,.24},{-.25,-.3}}},
 prison={158,122,{{-.36,-.3},{.3,-.3},{-.32,.3}}},roots={152,138,{{-.35,.24},{.24,-.3},{-.3,-.25}}},
 altar={164,146,{{-.34,-.25},{.32,.1},{-.26,.3}}},fork={148,140,{{-.34,0},{.26,-.32},{-.26,.3}}},
 web={126,158,{{-.36,-.24},{.2,.28},{-.3,.3}}},refuge={130,118,{{-.34,.28},{.26,0},{-.3,-.26}}},
 bank={164,114,{{-.36,-.25},{.3,-.22},{-.3,.27}}},extraction={144,116,{{-.3,-.26},{.22,.2},{-.25,.3}}},
 ridge={124,158,{{-.3,-.3},{.24,0},{-.28,.31}}},basin={160,138,{{-.34,-.3},{.3,0},{-.3,.3}}},
 cellar={124,132,{{-.32,-.28},{.26,-.15},{-.3,.3}}},ravine={174,138,{{-.36,-.3},{.1,0},{.32,.3}}},
 archive={158,124,{{-.35,-.3},{.28,-.3},{-.28,.3}}},tunnel={174,104,{{-.38,-.24},{.3,-.24},{-.3,.26}}},
 court={142,150,{{-.32,.28},{.29,.26},{-.3,-.3}}},terrace={154,146,{{-.34,-.25},{.28,.28},{-.28,.28}}},
 freight={158,128,{{-.36,-.3},{.3,0},{-.3,.3}}},workshop={136,132,{{-.34,-.3},{.26,-.2},{-.3,.28}}},
 mine={176,112,{{-.37,-.28},{.32,0},{-.3,.3}}},channels={174,138,{{-.36,-.29},{.3,-.29},{-.3,.3}}},
 circuit={144,142,{{-.32,-.3},{.28,-.24},{-.28,.3}}},gallery={166,112,{{-.36,-.25},{.3,0},{-.29,.3}}},
 furnace={168,148,{{-.34,-.28},{.3,0},{-.29,.3}}},lanterns={144,136,{{-.34,-.26},{.28,.26},{-.3,.3}}},
 council={136,124,{{-.32,-.28},{.27,0},{-.28,.28}}},crypt={174,110,{{-.36,-.28},{.3,-.28},{-.3,.3}}},
 gate={158,144,{{-.35,-.28},{.26,-.28},{-.28,.3}}},conduits={168,126,{{-.36,-.3},{.28,0},{-.3,.3}}},
 records={154,126,{{-.34,-.28},{.27,-.2},{-.29,.3}}},throne={172,154,{{-.35,-.28},{.3,0},{-.28,.3}}},
}
function L.profile(id,index)
 local prefix,chapter=id:match('^(%u+)%-(%d+)$')
 local side={['DW-Q1']='creek',['DW-Q2']='yard',['DW-Q3']='mine',['DW-Q4']='ridge',
  ['FV-Q1']='shelter',['FV-Q2']='tunnel',['FV-Q3']='bank',['FV-Q4']='tower',
  ['EC-Q1']='workshop',['EC-Q2']='freight',['EC-Q3']='altar',['EC-Q4']='ridge'}
 local kind=prefix and chapters[prefix][tonumber(chapter)]or side[id]or 'yard'
 local s=shapes[kind];local width,depth=s[1],s[2]
 if index==2 then width,depth=depth,width end
 return {kind=kind,width=width,depth=depth}
end
function L.points(id,index,area,mode)
 local profile=L.profile(id,index);local shape=shapes[profile.kind]
 local along=area.axis=='x'and area.size[1]or area.size[2]
 local across=area.axis=='x'and area.size[2]or area.size[1]
 local result={}
 for n,p in ipairs(shape[3])do
  local u,v=p[1],p[2]
  if index==2 then v=-v end
  -- Brief extraction followed by Finn's longer lead avoids two full escorts.
  if id=='GW-06'and index==1 then u,v=-.35+(n-1)*.1,(n-2)*.1
  elseif mode=='escort'then u,v=-.35+(n-1)*.28,(n%2==0 and .15 or -.15)end
  local dx,dz=area.axis=='x'and u*along*area.side or v*across,area.axis=='z'and u*along*area.side or v*across
  result[n]={area.center[1]+dx,area.center[2],area.center[3]+dz}
 end
 return result
end
return L
