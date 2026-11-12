-- Presentation only. Authoritative attack shapes, speeds and damage live in EnemyPatterns.
local P={}
-- Each species has its own combination of silhouette, orbit ornament and accent.
local rows={
 Goblin={'knife','notch'},Orc={'cleaver','fang'},Ogre={'rock','rubble'},Shaman={'hex','rune'},Warlord={'banner','crown'},
 GoblinKing={'knife','crown'},KingOgre={'rock','crown'},EnragedWarlord={'cleaver','crown'},KingShaman={'totem','rune'},Slime={'gel','droplet'},
 Webling={'web','needle'},Silkweaver={'web','spindle'},Barkstalker={'root','thorn'},Gloambat={'wing','crescent'},VenomcoilCentipede={'venom','fang'},
 AncientHollowbark={'root','branch'},HollowbarkSovereign={'root','crown'},VenomcoilKing={'venom','crown'},WidowQueen={'brood','spindle'},
 IceWolf={'frostfang','fang'},IceBear={'snow','claw'},IceTroll={'iceboulder','rubble'},IceGolem={'crystal','core'},IceElf={'icespear','feather'},
 KingIceBear={'snow','crown'},IceTrollKing={'iceboulder','crown'},KingIceGolem={'crystal','crown'},QueenIceElf={'prism','crown'},AncientGlacierKing={'glacier','crown'},
 Imp={'ember','horn'},LavaSlime={'lava','droplet'},MagmaWorm={'lava','fang'},Golem={'rock','core'},VolcanoShaman={'cinder','rune'},
 MagmaImp={'ember','crown'},MagmaGolem={'magma','core'},KingVolcanoShaman={'volcano','rune'},InfernoOverlord={'inferno','crown'},CalderaTitan={'meteor','rubble'},
 Skeleton={'bone','notch'},Zombie={'dust','claw'},Ghoul={'claw','fang'},SkeletonKnight={'cleaver','shield'},DeathKnight={'scythe','shield'},
 Mummy={'sand','rune'},Hellhound={'ember','fang'},Lich={'soul','rune'},LichSovereign={'seal','crown'},DreadCommander={'banner','shield'},Veyr={'rift','crown'},
}
local palette={physical={255,214,144},arcane={185,105,255},frost={100,220,255},fire={255,112,36},web={230,224,255},venom={155,237,65},soul={100,245,207},shadow={193,112,255}}
local overrides={
 ['GoblinKing.4']={'bomb','crown'},['WidowQueen.2']={'web','crown'},['WidowQueen.3']={'web','spindle'},
 ['IceTrollKing.3']={'iceboulder','rubble'},['QueenIceElf.4']={'icespear','crown'},
 ['KingShaman.3']={'totem','crown'},['LichSovereign.2']={'seal','rune'},['Veyr.4']={'rift','portal'},
 ['CalderaTitan.3']={'meteor','crown'},['KingVolcanoShaman.3']={'volcano','crown'},
}
P.species=rows
local families={icespear='frost',frostfang='frost',prism='frost',crystal='frost',glacier='frost',iceboulder='frost',snow='frost',
 ember='fire',cinder='fire',lava='fire',inferno='fire',volcano='fire',meteor='fire',magma='fire',bomb='fire',
 soul='soul',seal='soul',rift='shadow',banner='shadow',scythe='shadow',wing='shadow',hex='arcane',totem='arcane',
 venom='venom',brood='venom',gel='venom',web='web',root='earth',rock='earth',sand='earth',dust='earth'}
function P.get(d)
 local kind=d.id:match('^(.-)%.');local base=rows[kind];if not base then return nil end
 local row=overrides[d.id]or base
 local rgb=palette[d.element]or palette.physical
 if row[1]=='web'then rgb=palette.web elseif row[1]=='sand'then rgb={225,192,123}end
 return {kind=kind,motif=row[1],ornament=row[2],family=families[row[1]]or 'physical',color=rgb,index=tonumber(d.id:match('%.(%d+)$'))or 1,
  -- Separate attacks of a species also vary their orbit/rune arrangement.
  heavy=d.heavy==true,shape=d.shape,element=d.element}
end
return P
