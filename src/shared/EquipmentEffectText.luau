-- en-US equipment effect strings. Values are percentage points, not power points.
return {
 Title='SPECIAL EFFECTS', None='No special effects.',
 Labels={damage='Damage',physical_damage='Physical damage',magic_damage='Magic damage',
  basic_damage='Basic attack damage',skill_damage='Skill damage',damage_reduction='Damage reduction'},
 Bonus='%s +%s%%', SkillBonus='%s damage +%s%%',
 Note='Matching damage bonuses add together (maximum +100%). Damage reduction adds up to 50% and applies before defense. Enhancement improves base stats only.',
 Comparison='%s: %s%% -> %s%% (%s percentage points)',
 Unchanged='Special effects stay unchanged by enhancement.',
}
