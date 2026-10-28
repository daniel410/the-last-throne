#!/usr/bin/env python3
"""Validate approved planning rewards against source encounters; never fit rewards automatically."""
from pathlib import Path
import argparse,json
ROOT=Path(__file__).resolve().parents[1]
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,default=ROOT/'assets/balance/epics-01-04-progression.json');args=parser.parse_args()
 budget=json.loads((ROOT/'assets/balance/story-reward-budget.json').read_text());curve=budget['xp_curve'];enemy=budget['enemy_rewards']
 def needed(lv):return curve['base']+curve['per_level']*(lv-1)
 def cumulative(lv):return sum(needed(n) for n in range(1,lv))
 def locate(xp):
  lv=1
  while lv<80 and xp>=needed(lv):xp-=needed(lv);lv+=1
  return {'level':lv,'xp_in_level':xp,'next_level_xp':needed(lv) if lv<80 else None}
 # DW-01 only its clearing3 is mandatory; optional transit kills/slime are excluded.
 dw=[[(6,3,False)],[(6,2,False),(7,1,False)],[],[(7,2,False),(8,4,False)],[(9,7,False),(10,1,True)],[(10,4,False),(11,1,False)],[(11,8,False),(12,1,True)]]
 sources={};configs=[('FV','frozen-vale-v1',{'King Ice Golem','Queen Ice Elf'}),('EC','ember-caldera-v1',{'Magma Golem','Inferno Overlord'}),('HG','haunted-graveyard-v1',{'Death Knight','Lich Sovereign'})]
 for prefix,folder,bosses in configs:
  for q in json.loads((ROOT/'assets/maps'/folder/'scenario-data.json').read_text()):sources[f'{prefix}-0{q["n"]}']=(q,[(lv,count,name in bosses) for name,lv,count,role in q['mobs'] if '선택' not in role])
 prologue={q['id']:q for q in json.loads((ROOT/'assets/maps/dawnspire-prologue-v1/scenario-data.json').read_text())}
 old=current=cumulative(budget['start']['level'])+budget['start']['xp_in_level'];coins=budget['start']['coins'];rows=[]
 for q in budget['rows']:
  if q['id'].startswith('DS'):
   src=prologue[q['id']];mobs=[(m['level'],m['count'],m['boss']) for m in src['encounters']]
   assert src['quest_xp']==q['quest_xp'] and src['quest_coins']==q['quest_coins']
  elif q['id'].startswith('DW'):mobs=dw[int(q['id'][-2:])-1]
  else:
   src,mobs=sources[q['id']]
   assert src['quest_xp']==q['quest_xp'] and src['coins']==q['quest_coins'],q['id']+' source rewards mismatch'
   assert src['repeat_quest_xp']==q['repeat_quest_xp'],q['id']+' repeat XP mismatch'
  combat=sum((enemy['xp_base']+enemy['xp_per_level']*lv)*(enemy['boss_xp_multiplier'] if boss else 1)*count for lv,count,boss in mobs)
  loot=sum((enemy['coins_base']+lv//enemy['coins_level_divisor'])*(enemy['boss_coins_multiplier'] if boss else 1)*count for lv,count,boss in mobs)
  assert combat==q['expected_combat_xp'] and loot==q['expected_kill_coins'],q['id']+' encounter budget changed; review rewards'
  assert q['repeat_quest_xp']==(0 if q['safe_hub'] or q.get('first_clear_only') else q['quest_xp']//4)
  assert f'퀘스트XP{q["quest_xp"]}' in (ROOT/q['scenario']).read_text(),q['id']+' document XP mismatch'
  start=locate(current);old+=q['legacy_quest_xp']+combat;current+=q['quest_xp']+combat;coins+=q['quest_coins']+loot
  rows.append({'id':q['id'],'name':q['name'],'quest_coins':q['quest_coins'],'existing_quest_xp':q['legacy_quest_xp'],'proposed_quest_xp':q['quest_xp'],'applied_quest_xp':q['quest_xp'],'repeat_quest_xp':q['repeat_quest_xp'],'target':q['target_level'],'planned_main_enemy_count':sum(c for _,c,_ in mobs),'start_adjusted':start,'cumulative_stat_points_earned':4*(locate(current)['level']-1),'cumulative_skill_points_earned':locate(current)['level']-1,'combat_xp_draft':combat,'kill_coins_draft':loot,'total_coins_draft':q['quest_coins']+loot,'cumulative_gross_coins_draft':coins,'baseline_finish':locate(old),'quest_xp_delta':q['quest_xp']-q['legacy_quest_xp'],'total_adjusted_xp':q['quest_xp']+combat,'adjusted_finish':locate(current),'baseline_reaches_target':locate(old)['level']>=q['target_level'],'baseline_exceeds_target':locate(old)['level']>q['target_level'],'adjusted_reaches_target':locate(current)['level']==q['target_level']})
 assert len(rows)==32 and len({q['id'] for q in rows})==32
 assert rows[3]['adjusted_finish']=={'level':5,'xp_in_level':0,'next_level_xp':200}
 assert rows[3]['cumulative_gross_coins_draft']==198
 assert rows[4]['start_adjusted']==rows[3]['adjusted_finish']
 assert all(q['adjusted_reaches_target'] for q in rows),'Approved rewards do not meet target windows; inspect inputs, do not auto-fit'
 result={'version':budget['version'],'date':budget['date'],'status':'applied planning baseline; runtime integration and playtests pending','currency':budget['currency'],'budget_source':'assets/balance/story-reward-budget.json','assumptions':{'start_level':budget['start']['level'],'start_xp_in_level':budget['start']['xp_in_level'],'start_coins':budget['start']['coins'],'xp_curve':curve,'enemy_rewards':enemy,'required_costs':0,'excluded':'optional kills/bosses, slime children, respawns, sales, boosters, random loot and equipment value','participation':budget['rules']['eligible_personal_reward'],'warning':'encounter participation and economy still require implementation/playtests','calibration':'approved fixed quest XP; validator does not recompute or fit reward values','tutorial_repeat_rewards':'quest and kills0; logic encounter receipt prevents retry farming','legacy_fields':'existing_quest_xp/baseline_finish describe the superseded percentage table; proposed_quest_xp is a compatibility alias for applied_quest_xp'},'quest_coins_total':sum(q['quest_coins'] for q in rows),'rows':rows,'summary':{'baseline_final':locate(old),'adjusted_final':locate(current),'baseline_missed_targets':sum(not q['baseline_reaches_target'] for q in rows),'baseline_exceeded_targets':sum(q['baseline_exceeds_target'] for q in rows),'quest_xp_total_existing':sum(q['existing_quest_xp'] for q in rows),'quest_xp_total_proposed':sum(q['applied_quest_xp'] for q in rows),'gross_coins_draft':coins}}
 args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result['summary'],ensure_ascii=False))
if __name__=='__main__':main()
