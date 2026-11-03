-- Earned crafting items are separate from account Diamonds. Reward bands use
-- authored mission/enemy level plus the chosen mode, never the visitor's level.
local E={bands={
 {level=1,gold=1,gems=6,stones=1},
 {level=20,gold=1.1,gems=8,stones=2},
 {level=40,gold=1.25,gems=10,stones=3},
 {level=60,gold=1.5,gems=12,stones=4},
 {level=80,gold=1.75,gems=14,stones=5},
},gemFactors={Easy=1,Hard=1.25,Insane=1.5,Hell=2},stoneFactors={Easy=1,Hard=1.25,Insane=1.5,Hell=2}}
function E.band(level)
 local band=E.bands[1]
 for _,row in ipairs(E.bands)do if level>=row.level then band=row end end
 return band
end
function E.materials(level,mode)
 local band=E.band(level)
 return math.floor(band.gems*E.gemFactors[mode]),math.ceil(band.stones*E.stoneFactors[mode]),band.level
end
return E
