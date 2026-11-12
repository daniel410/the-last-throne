# 128개 스킬 개별 VFX 검토표

TLT-033/057 · 2026-11-11. 각 행의 전후 이미지는 실제 Roblox 엔진의 고정 효과 캡처다. 캐릭터/무기 애니메이션·실기기·멀티플레이 최종 수용은 별도다. 마지막 펄스39개도 별도로 확인했다. [방법·검증·한계](README.md).

## knight

| 순서·스킬 | 개별 검토·조치 | 전 / 후 / 반복 마지막 |
| --- | --- | --- |
| 1. SHIELD BASH | Shield Bash는 방패 진행축에 수직인 접점. `guard`, 폭0.24, 잔상0.32s | [전](before/knight.common.bash.png) · [후](after/knight.common.bash.png) |
| 2. WHIRLWIND | Whirlwind의360도 검 궤적. `spin`, 폭0.21, 잔상0.38s | [전](before/knight.common.whirlwind.png) · [후](after/knight.common.whirlwind.png) |
| 3. PROVOKE | 도발은 피해광선 대신 발밑 함성 파문. `warcry`, 폭0.14, 잔상0.48s | [전](before/knight.common.provoke.png) · [후](after/knight.common.provoke.png) |
| 4. COUNTER SLASH | 반격의 짧은 칼날과 방어 호를 분리. `counter`, 폭0.19, 잔상0.42s | [전](before/knight.steel_knight.counter_slash.png) · [후](after/knight.steel_knight.counter_slash.png) |
| 5. STEEL SWEEP | 전방 부채꼴 끝을 잇는 낮은 강철 초승달. `crescent`, 폭0.25, 잔상0.4s | [전](before/knight.steel_knight.steel_sweep.png) · [후](after/knight.steel_knight.steel_sweep.png) |
| 6. CHALLENGING STRIKE | 도발 공격을 한 번의 검격과 발밑 압력으로 구분. `slash`, 폭0.22, 잔상0.42s | [전](before/knight.steel_knight.challenging_strike.png) · [후](after/knight.steel_knight.challenging_strike.png) |
| 7. TWIN CYCLONE | 두 펄스의 회전 위상을 바꿔 Twin Cyclone의 박자 표시. `spin`, 폭0.21, 잔상0.34s | [전](before/knight.steel_knight.twin_cyclone.png) · [후](after/knight.steel_knight.twin_cyclone.png) · [마지막](last-pulse/knight.steel_knight.twin_cyclone.png) |
| 8. SHIELD BREAKER | 한 대상 방패 파쇄의 전방 수직 면과 접점 집중. `guard`, 폭0.26, 잔상0.34s | [전](before/knight.steel_knight.shield_breaker.png) · [후](after/knight.steel_knight.shield_breaker.png) |
| 9. GUARDIAN COUNTER | 반격 궤적 뒤에 아군 보호와 구분되는 개인 방어 호. `counter`, 폭0.16, 잔상0.46s | [전](before/knight.steel_knight.guardian_counter.png) · [후](after/knight.steel_knight.guardian_counter.png) |
| 10. RALLYING SLASH | 넓은 선동 베기의 두 겹 전방 호. `areslash`, 폭0.18, 잔상0.44s | [전](before/knight.steel_knight.rallying_slash.png) · [후](after/knight.steel_knight.rallying_slash.png) |
| 11. BREAKER CHARGE | 돌진 두 펄스마다 진행축에 수직인 방패 파동. `guard`, 폭0.21, 잔상0.3s | [전](before/knight.steel_knight.breaker_charge.png) · [후](after/knight.steel_knight.breaker_charge.png) · [마지막](last-pulse/knight.steel_knight.breaker_charge.png) |
| 12. VANGUARD STRIKE | 일반 검광 대신 좁은 전방 찌르기. `thrust`, 폭0.16, 잔상0.36s | [전](before/knight.steel_knight.vanguard_strike.png) · [후](after/knight.steel_knight.vanguard_strike.png) |
| 13. BLADE STORM | 4회 박자마다 회전 위상 변경과 짧은 잔상. `spin`, 폭0.16, 잔상0.28s | [전](before/knight.steel_knight.blade_storm.png) · [후](after/knight.steel_knight.blade_storm.png) · [마지막](last-pulse/knight.steel_knight.blade_storm.png) |
| 14. SWEEPING BREAK | 전방 베기와 구별되는 바닥360도 파쇄 호. `crescent`, 폭0.25, 잔상0.46s | [전](before/knight.steel_knight.sweeping_break.png) · [후](after/knight.steel_knight.sweeping_break.png) |
| 15. WARCRY ASSAULT | 3회 함성 공격의 전방 압력 파문. `warcry`, 폭0.16, 잔상0.32s | [전](before/knight.steel_knight.warcry_assault.png) · [후](after/knight.steel_knight.warcry_assault.png) · [마지막](last-pulse/knight.steel_knight.warcry_assault.png) |
| 16. UNYIELDING FRONT | 궁극기의 원형 방어진과 전진 방패를 함께 표현. `guard`, 폭0.24, 잔상0.55s | [전](before/knight.steel_knight.unyielding_front.png) · [후](after/knight.steel_knight.unyielding_front.png) · [마지막](last-pulse/knight.steel_knight.unyielding_front.png) |
| 17. OATHBLADE | 맹세의 두 검격은 펄스별 좌우 반전. `slash`, 폭0.18, 잔상0.38s | [전](before/knight.paladin.oathblade.png) · [후](after/knight.paladin.oathblade.png) · [마지막](last-pulse/knight.paladin.oathblade.png) |
| 18. RADIANT SWEEP | 금빛 전방 호와 표식 접점을 짧게 유지. `crescent`, 폭0.28, 잔상0.45s | [전](before/knight.paladin.radiant_sweep.png) · [후](after/knight.paladin.radiant_sweep.png) |
| 19. OATH CHALLENGE | 맹세 소비는 전방 성광 압력으로 구분. `warcry`, 폭0.18, 잔상0.44s | [전](before/knight.paladin.oath_challenge.png) · [후](after/knight.paladin.oath_challenge.png) |
| 20. DAWN BURST | Dawn Burst는 시전자 중심 방사형 성광. `holy`, 폭0.18, 잔상0.5s | [전](before/knight.paladin.dawn_burst.png) · [후](after/knight.paladin.dawn_burst.png) |
| 21. OATHBREAKER STRIKE | 검격을 수직 내려찍기 실루엣으로 변경. `cleave`, 폭0.32, 잔상0.4s | [전](before/knight.paladin.oathbreaker_strike.png) · [후](after/knight.paladin.oathbreaker_strike.png) |
| 22. SHIELD VERDICT | Shield Verdict는 좁고 강한 방패 전면. `guard`, 폭0.3, 잔상0.38s | [전](before/knight.paladin.shield_verdict.png) · [후](after/knight.paladin.shield_verdict.png) |
| 23. GUARDIAN SLASH | 보호가 붙은 전방 검격의 칼날 호 분리. `crescent`, 폭0.21, 잔상0.43s | [전](before/knight.paladin.guardian_slash.png) · [후](after/knight.paladin.guardian_slash.png) |
| 24. RADIANT CHARGE | 성광 돌진은 전진축 방패 면을 유지. `guard`, 폭0.2, 잔상0.32s | [전](before/knight.paladin.radiant_charge.png) · [후](after/knight.paladin.radiant_charge.png) · [마지막](last-pulse/knight.paladin.radiant_charge.png) |
| 25. VALIANT ADVANCE | 다대상 전진을 넓고 얇은 방패 압력으로 구분. `guard`, 폭0.16, 잔상0.42s | [전](before/knight.paladin.valiant_advance.png) · [후](after/knight.paladin.valiant_advance.png) |
| 26. DAWN SPIRAL | 반복 나선은 펄스별 위상 변경. `holy`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.dawn_spiral.png) · [후](after/knight.paladin.dawn_spiral.png) · [마지막](last-pulse/knight.paladin.dawn_spiral.png) |
| 27. SUNWARD CROSS | Sunward Cross는 실제 교차하는 두 검광. `cross`, 폭0.23, 잔상0.38s | [전](before/knight.paladin.sunward_cross.png) · [후](after/knight.paladin.sunward_cross.png) · [마지막](last-pulse/knight.paladin.sunward_cross.png) |
| 28. OATHBOUND ASSAULT | 세 번 맹세 공격의 교대 검격. `slash`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.oathbound_assault.png) · [후](after/knight.paladin.oathbound_assault.png) · [마지막](last-pulse/knight.paladin.oathbound_assault.png) |
| 29. OATH OF DAWN | 맹세 궁극기는 중앙이 빈 방사형 성광 인장. `holy`, 폭0.23, 잔상0.7s | [전](before/knight.paladin.oath_of_dawn.png) · [후](after/knight.paladin.oath_of_dawn.png) · [마지막](last-pulse/knight.paladin.oath_of_dawn.png) |
| 30. DRIVING THRUST | Driving Thrust는좁은6stud 찌르기. `thrust`, 폭0.19, 잔상0.32s | [전](before/knight_driving_thrust.png) · [후](after/knight_driving_thrust.png) |
| 31. CRESCENT CUT | Crescent Cut은전방110도 단일호. `crescent`, 폭0.25, 잔상0.38s | [전](before/knight_crescent_cut.png) · [후](after/knight_crescent_cut.png) |
| 32. GUARDED STRIKE | Guarded Strike는단일 방패 접점과 방어호. `guard`, 폭0.19, 잔상0.34s | [전](before/knight_guarded_strike.png) · [후](after/knight_guarded_strike.png) |
| 1. OVERHEAD SMASH | Overhead Smash의 수직 궤적과 접점. `cleave`, 폭0.32, 잔상0.42s | [전](before/dwarf.common.overhead.png) · [후](after/dwarf.common.overhead.png) |
| 2. AXE THROW | 실제 도끼 투척의 회전 후류. `axe`, 폭0.14, 잔상0.38s | [전](before/dwarf.common.throw.png) · [후](after/dwarf.common.throw.png) |
| 3. GROUND SLAM | Ground Slam은 시전자 바닥 중심360도. `earth`, 폭0.18, 잔상0.48s | [전](before/dwarf.common.ground.png) · [후](after/dwarf.common.ground.png) |
| 4. ARMOR SPLITTER | 갑옷 파쇄는 도끼날의 수직 호. `cleave`, 폭0.32, 잔상0.38s | [전](before/dwarf.iron_axe.armor_splitter.png) · [후](after/dwarf.iron_axe.armor_splitter.png) |
| 5. RETURNING ECHO | 2펄스 복귀 방향을 실제로 반전. `axe`, 폭0.14, 잔상0.4s | [전](before/dwarf.iron_axe.returning_echo.png) · [후](after/dwarf.iron_axe.returning_echo.png) · [마지막](last-pulse/dwarf.iron_axe.returning_echo.png) |
| 6. MOUNTAIN SWEEP | Mountain Sweep은360도 원형 균열. `earth`, 폭0.16, 잔상0.46s | [전](before/dwarf.iron_axe.mountain_sweep.png) · [후](after/dwarf.iron_axe.mountain_sweep.png) |
| 7. CRAG CLEAVE | 전방 다대상 내려찍기를 쌍 수직 호로 표현. `cleave`, 폭0.25, 잔상0.42s | [전](before/dwarf.iron_axe.crag_cleave.png) · [후](after/dwarf.iron_axe.crag_cleave.png) |
| 8. BREAKER THROW | 강한 관통 투척을 긴 단일 도끼 후류로 구분. `axe`, 폭0.22, 잔상0.42s | [전](before/dwarf.iron_axe.breaker_throw.png) · [후](after/dwarf.iron_axe.breaker_throw.png) |
| 9. STONEBOUND LEAP | 착지 위치 중심으로 바깥 방향 파편. `earth`, 폭0.19, 잔상0.48s | [전](before/dwarf.iron_axe.stonebound_leap.png) · [후](after/dwarf.iron_axe.stonebound_leap.png) |
| 10. IRON SHOULDER | 어깨 밀기는 도끼 마법이 아닌 전방 충격. `guard`, 폭0.23, 잔상0.34s | [전](before/dwarf.iron_axe.iron_shoulder.png) · [후](after/dwarf.iron_axe.iron_shoulder.png) |
| 11. CROSSCUT AXE | 복귀/교차cut은 서버가 보낸 펄스 끝점을 유지. `axe`, 폭0.15, 잔상0.36s | [전](before/dwarf.iron_axe.crosscut_axe.png) · [후](after/dwarf.iron_axe.crosscut_axe.png) · [마지막](last-pulse/dwarf.iron_axe.crosscut_axe.png) |
| 12. MOUNTAIN STRIKE | 전방120도 이내로만 산맥 균열 전개. `earth`, 폭0.23, 잔상0.48s | [전](before/dwarf.iron_axe.mountain_strike.png) · [후](after/dwarf.iron_axe.mountain_strike.png) |
| 13. SHATTER BLOW | 지정 지점의 반경4 파쇄로 장거리 균열 방지. `earth`, 폭0.18, 잔상0.52s | [전](before/dwarf.iron_axe.shatter_blow.png) · [후](after/dwarf.iron_axe.shatter_blow.png) |
| 14. TWIN AXE PATH | 두 투척 펄스의 궤적과 회전 위상 구분. `axe`, 폭0.14, 잔상0.3s | [전](before/dwarf.iron_axe.twin_axe_path.png) · [후](after/dwarf.iron_axe.twin_axe_path.png) · [마지막](last-pulse/dwarf.iron_axe.twin_axe_path.png) |
| 15. TREMOR GUARD | 보호 부여는 낮은 바닥 진동 고리로 유지. `earth`, 폭0.14, 잔상0.48s | [전](before/dwarf.iron_axe.tremor_guard.png) · [후](after/dwarf.iron_axe.tremor_guard.png) |
| 16. MOUNTAIN COLLAPSE | 산맥 궁극기는 원형이 아닌 전방120도 대형 균열. `earth`, 폭0.25, 잔상0.66s | [전](before/dwarf.iron_axe.mountain_collapse.png) · [후](after/dwarf.iron_axe.mountain_collapse.png) · [마지막](last-pulse/dwarf.iron_axe.mountain_collapse.png) |
| 17. GUNNER SHOT | 한 발 총격의 짧은 총구와 얇은 탄도. `bullet`, 폭0.08, 잔상0.18s | [전](before/dwarf.gunner.gunner_shot.png) · [후](after/dwarf.gunner.gunner_shot.png) |
| 18. BOMB TOSS | 수류탄은 지정지점의 바깥 폭발과 파편. `blast`, 폭0.18, 잔상0.44s | [전](before/dwarf.gunner.bomb_toss.png) · [후](after/dwarf.gunner.bomb_toss.png) |
| 19. SHELL BURST | 포탄은 상공 낙하축과 접지 폭발. `mortar`, 폭0.2, 잔상0.4s | [전](before/dwarf.gunner.shell_burst.png) · [후](after/dwarf.gunner.shell_burst.png) |
| 20. QUICKFIRE | 속사는 펄스보다 짧은 탄도 수명. `bullet`, 폭0.06, 잔상0.13s | [전](before/dwarf.gunner.quickfire.png) · [후](after/dwarf.gunner.quickfire.png) · [마지막](last-pulse/dwarf.gunner.quickfire.png) |
| 21. SHRAPNEL TOSS | 산개된 실제 서버 중심마다 파편 폭발. `blast`, 폭0.13, 잔상0.32s | [전](before/dwarf.gunner.shrapnel_toss.png) · [후](after/dwarf.gunner.shrapnel_toss.png) · [마지막](last-pulse/dwarf.gunner.shrapnel_toss.png) |
| 22. BLAST STEP | 후퇴 폭발은 전방 부채꼴만 표시. `blast`, 폭0.19, 잔상0.38s | [전](before/dwarf.gunner.blast_step.png) · [후](after/dwarf.gunner.blast_step.png) |
| 23. SCATTER SHOT | 산탄은 한 직선 대신5개 부채꼴 탄도. `fan`, 폭0.07, 잔상0.19s | [전](before/dwarf.gunner.scatter_shot.png) · [후](after/dwarf.gunner.scatter_shot.png) |
| 24. SKIPPING CHARGE | 두 번 튀는 폭탄의 실제 산개 중심 유지. `blast`, 폭0.17, 잔상0.36s | [전](before/dwarf.gunner.skipping_charge.png) · [후](after/dwarf.gunner.skipping_charge.png) · [마지막](last-pulse/dwarf.gunner.skipping_charge.png) |
| 25. FIELD MORTAR | 포격은4회 각각 낙하 흔적. `mortar`, 폭0.17, 잔상0.42s | [전](before/dwarf.gunner.field_mortar.png) · [후](after/dwarf.gunner.field_mortar.png) · [마지막](last-pulse/dwarf.gunner.field_mortar.png) |
| 26. PIERCING ROUND | 관통탄은 가는 심과 압력 후류로 구분. `bullet`, 폭0.09, 잔상0.22s | [전](before/dwarf.gunner.piercing_round.png) · [후](after/dwarf.gunner.piercing_round.png) |
| 27. ROLLING CHARGE | 굴림 폭탄 폭발 중심은 서버 확정 지점. `blast`, 폭0.2, 잔상0.44s | [전](before/dwarf.gunner.rolling_charge.png) · [후](after/dwarf.gunner.rolling_charge.png) |
| 28. SIEGE PATTERN | 두 포격의 개별 서버 위치 표시. `mortar`, 폭0.18, 잔상0.43s | [전](before/dwarf.gunner.siege_pattern.png) · [후](after/dwarf.gunner.siege_pattern.png) · [마지막](last-pulse/dwarf.gunner.siege_pattern.png) |
| 29. SIEGE BARRAGE | 궁극기4펄스도 이전 포격 잔상이 겹치지 않게 제한. `mortar`, 폭0.23, 잔상0.46s | [전](before/dwarf.gunner.siege_barrage.png) · [후](after/dwarf.gunner.siege_barrage.png) · [마지막](last-pulse/dwarf.gunner.siege_barrage.png) |
| 30. HOOKING CHOP | Hooking Chop은짧은 갈고리형 수직호. `cleave`, 폭0.24, 잔상0.3s | [전](before/dwarf_hooking_chop.png) · [후](after/dwarf_hooking_chop.png) |
| 31. LOW SWEEP | Low Sweep은발목 높이 전방110도 호. `low`, 폭0.22, 잔상0.36s | [전](before/dwarf_low_sweep.png) · [후](after/dwarf_low_sweep.png) |
| 32. BRACED THROW | Braced Throw는26stud 관통 후류. `axe`, 폭0.2, 잔상0.42s | [전](before/dwarf_braced_throw.png) · [후](after/dwarf_braced_throw.png) |
| 1. AIMED SHOT | Aimed Shot은 굵은 단일 정밀 후류. `arrow`, 폭0.15, 잔상0.38s | [전](before/elf.common.aimed.png) · [후](after/elf.common.aimed.png) |
| 2. RAPID FIRE | Rapid Fire는 각 발사가 겹치지 않는 짧은 후류. `arrow`, 폭0.07, 잔상0.16s | [전](before/elf.common.rapid.png) · [후](after/elf.common.rapid.png) · [마지막](last-pulse/elf.common.rapid.png) |
| 3. MULTI SHOT | Multi Shot은 실제70도 범위의5방향 화살. `fan`, 폭0.08, 잔상0.28s | [전](before/elf.common.multi.png) · [후](after/elf.common.multi.png) |
| 4. WEAKPOINT SHOT | 약점 사격은 단일 정밀 후류. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.marksman.weakpoint_shot.png) · [후](after/elf.marksman.weakpoint_shot.png) |
| 5. MOVING VOLLEY | 이동3연사는 짧은 개별 사격. `arrow`, 폭0.08, 잔상0.2s | [전](before/elf.marksman.moving_volley.png) · [후](after/elf.marksman.moving_volley.png) · [마지막](last-pulse/elf.marksman.moving_volley.png) |
| 6. PIERCING LINE | 관통 직선의 두 가는 압력선. `arrow`, 폭0.09, 잔상0.34s | [전](before/elf.marksman.piercing_line.png) · [후](after/elf.marksman.piercing_line.png) |
| 7. HEAVY DRAW | 강하게 당긴 화살은 두꺼운 단일 관통 심. `arrow`, 폭0.17, 잔상0.42s | [전](before/elf.marksman.heavy_draw.png) · [후](after/elf.marksman.heavy_draw.png) |
| 8. PRECISION VOLLEY | 약점 소비3연사는 이전 꼬리를 빨리 제거. `arrow`, 폭0.1, 잔상0.24s | [전](before/elf.marksman.precision_volley.png) · [후](after/elf.marksman.precision_volley.png) · [마지막](last-pulse/elf.marksman.precision_volley.png) |
| 9. FAN BREAK | Fan Break의 실제 부채꼴 범위를 화살로 표현. `fan`, 폭0.09, 잔상0.3s | [전](before/elf.marksman.fan_break.png) · [후](after/elf.marksman.fan_break.png) |
| 10. HUNTER'S FOCUS | 집중 사격의 이중 후류와 실제 보호 표시. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.hunter_s_focus.png) · [후](after/elf.marksman.hunter_s_focus.png) |
| 11. RETREATING FIRE | 후퇴 이동은 현재 발사점에서 시작. `arrow`, 폭0.12, 잔상0.32s | [전](before/elf.marksman.retreating_fire.png) · [후](after/elf.marksman.retreating_fire.png) |
| 12. PIERCING VOLLEY | 45stud 관통 부채를 한 줄로 축소하지 않음. `fan`, 폭0.11, 잔상0.36s | [전](before/elf.marksman.piercing_volley.png) · [후](after/elf.marksman.piercing_volley.png) |
| 13. MARK BREAKER | 표식 파쇄는 굵은 단일 화살 접점. `arrow`, 폭0.18, 잔상0.38s | [전](before/elf.marksman.mark_breaker.png) · [후](after/elf.marksman.mark_breaker.png) |
| 14. CROSSFIRE | Crossfire의2펄스 교차 방향을 서버 그대로 사용. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf.marksman.crossfire.png) · [후](after/elf.marksman.crossfire.png) · [마지막](last-pulse/elf.marksman.crossfire.png) |
| 15. ARROW RAIN | Arrow Rain은 실제 지정지점에만 낙하. `rain`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.arrow_rain.png) · [후](after/elf.marksman.arrow_rain.png) · [마지막](last-pulse/elf.marksman.arrow_rain.png) |
| 16. GRAND VOLLEY | Grand Volley는90도 부채꼴3회로 구분. `fan`, 폭0.12, 잔상0.3s | [전](before/elf.marksman.grand_volley.png) · [후](after/elf.marksman.grand_volley.png) · [마지막](last-pulse/elf.marksman.grand_volley.png) |
| 17. ELEMENTAL ARROW | 자연 화살의 가는 마력 나선. `arrow`, 폭0.13, 잔상0.35s | [전](before/elf.magic_archer.elemental_arrow.png) · [후](after/elf.magic_archer.elemental_arrow.png) |
| 18. SPARK VOLLEY | 번개 속성 화살은 전기 가지가 달린 개별3연사. `arrow`, 폭0.08, 잔상0.22s | [전](before/elf.magic_archer.spark_volley.png) · [후](after/elf.magic_archer.spark_volley.png) · [마지막](last-pulse/elf.magic_archer.spark_volley.png) |
| 19. VINE TRAP | Vine Trap은 지정지점을 감싸는 뿌리. `vine`, 폭0.12, 잔상0.44s | [전](before/elf.magic_archer.vine_trap.png) · [후](after/elf.magic_archer.vine_trap.png) · [마지막](last-pulse/elf.magic_archer.vine_trap.png) |
| 20. BLOOM SHOT | Bloom Shot은 명중점의 꽃잎형3갈래 접점. `arrow`, 폭0.12, 잔상0.38s | [전](before/elf.magic_archer.bloom_shot.png) · [후](after/elf.magic_archer.bloom_shot.png) |
| 21. STORM ARROW | Storm Arrow는 상공에서 지정지점으로 낙뢰. `lightning`, 폭0.14, 잔상0.28s | [전](before/elf.magic_archer.storm_arrow.png) · [후](after/elf.magic_archer.storm_arrow.png) |
| 22. ROOTING FAN | Rooting Fan은 시전자 앞 부채꼴 뿌리. `vine`, 폭0.11, 잔상0.4s | [전](before/elf.magic_archer.rooting_fan.png) · [후](after/elf.magic_archer.rooting_fan.png) |
| 23. WARDEN ARROW | Warden Arrow는 보호 효과와 화살 궤적 분리. `arrow`, 폭0.11, 잔상0.34s | [전](before/elf.magic_archer.warden_arrow.png) · [후](after/elf.magic_archer.warden_arrow.png) |
| 24. GLIDING SHOT | 전진 사격은 현재 발사점 기준. `arrow`, 폭0.12, 잔상0.3s | [전](before/elf.magic_archer.gliding_shot.png) · [후](after/elf.magic_archer.gliding_shot.png) |
| 25. SPIRIT RAIN | Spirit Rain은 자연 팔레트의 낙하 화살. `rain`, 폭0.13, 잔상0.3s | [전](before/elf.magic_archer.spirit_rain.png) · [후](after/elf.magic_archer.spirit_rain.png) · [마지막](last-pulse/elf.magic_archer.spirit_rain.png) |
| 26. ELEMENTAL PIERCE | Elemental Pierce는 좁은 직선 관통. `arrow`, 폭0.14, 잔상0.36s | [전](before/elf.magic_archer.elemental_pierce.png) · [후](after/elf.magic_archer.elemental_pierce.png) |
| 27. ECHO ARROWS | 3회 Echo는 각 펄스 나선 위상을 변경. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.magic_archer.echo_arrows.png) · [후](after/elf.magic_archer.echo_arrows.png) · [마지막](last-pulse/elf.magic_archer.echo_arrows.png) |
| 28. VINE BURST | Vine Burst는 지점 중심의 뿌리 폭발. `vine`, 폭0.16, 잔상0.5s | [전](before/elf.magic_archer.vine_burst.png) · [후](after/elf.magic_archer.vine_burst.png) |
| 29. SPIRIT ARROWFALL | 궁극기는3회 지정지점 화살비와 개별접점. `rain`, 폭0.16, 잔상0.46s | [전](before/elf.magic_archer.spirit_arrowfall.png) · [후](after/elf.magic_archer.spirit_arrowfall.png) · [마지막](last-pulse/elf.magic_archer.spirit_arrowfall.png) |
| 30. RETREATING SHOT | Retreating Shot은뒤로 이동해도 발사 방향 유지. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf_retreating_shot.png) · [후](after/elf_retreating_shot.png) |
| 31. PINNING SHOT | Pinning Shot은끝점의 짧은 고정 접점. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf_pinning_shot.png) · [후](after/elf_pinning_shot.png) |
| 32. ARROW SCREEN | Arrow Screen은반경4의 가까운 화살비. `rain`, 폭0.08, 잔상0.34s | [전](before/elf_arrow_screen.png) · [후](after/elf_arrow_screen.png) · [마지막](last-pulse/elf_arrow_screen.png) |
| 1. MANA BOLT | Mana Bolt는 비전색 쌍 나선. `arcane`, 폭0.12, 잔상0.34s | [전](before/mage.common.mana_bolt.png) · [후](after/mage.common.mana_bolt.png) |
| 2. WATER BALL | Water Ball의 구면 물보라와 젖음 접점. `water`, 폭0.16, 잔상0.42s | [전](before/mage.common.water_ball.png) · [후](after/mage.common.water_ball.png) |
| 3. GRAVITY | Gravity는 확정 영역 안쪽으로 당기는 나선. `gravity`, 폭0.14, 잔상0.56s | [전](before/mage.common.gravity.png) · [후](after/mage.common.gravity.png) |
| 4. EMBER LANCE | Ember Lance는 뾰족한 전방 불꽃 창. `fire`, 폭0.15, 잔상0.36s | [전](before/mage.pyro.ember_lance.png) · [후](after/mage.pyro.ember_lance.png) |
| 5. STEAM BURST | Steam Burst의 물색 증기를 위로 올림. `steam`, 폭0.17, 잔상0.48s | [전](before/mage.pyro.steam_burst.png) · [후](after/mage.pyro.steam_burst.png) |
| 6. CINDER RING | Cinder Ring은 시전자 중심의 빈 원형 화염. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.cinder_ring.png) · [후](after/mage.pyro.cinder_ring.png) · [마지막](last-pulse/mage.pyro.cinder_ring.png) |
| 7. FLAME DART | 짧은 시전 Flame Dart는 가늘고 짧게. `fire`, 폭0.13, 잔상0.24s | [전](before/mage.pyro.flame_dart.png) · [후](after/mage.pyro.flame_dart.png) |
| 8. EARTH RISE | Earth Rise는 지점 중심의 솟는 암석. `earth`, 폭0.18, 잔상0.48s | [전](before/mage.pyro.earth_rise.png) · [후](after/mage.pyro.earth_rise.png) |
| 9. EMBER STEP | Ember Step은 이동 후가 아닌 서버의 출발장판 중심. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.ember_step.png) · [후](after/mage.pyro.ember_step.png) |
| 10. STONE LANCE | Stone Lance는 바닥 균열 대신 공중 돌창. `stone`, 폭0.23, 잔상0.42s | [전](before/mage.pyro.stone_lance.png) · [후](after/mage.pyro.stone_lance.png) |
| 11. SEARING WARD | Searing Ward는 원형 열기와 보호 부여를 구분. `fire`, 폭0.15, 잔상0.42s | [전](before/mage.pyro.searing_ward.png) · [후](after/mage.pyro.searing_ward.png) |
| 12. LAVA ERUPTION | Lava Eruption은 반경14 내 방사형 용암 균열. `lava`, 폭0.24, 잔상0.6s | [전](before/mage.pyro.lava_eruption.png) · [후](after/mage.pyro.lava_eruption.png) |
| 13. MAGMA SPEAR | Magma Spear는3겹 고온 창 심. `fire`, 폭0.18, 잔상0.44s | [전](before/mage.pyro.magma_spear.png) · [후](after/mage.pyro.magma_spear.png) |
| 14. MOLTEN LINE | Molten Line은3펄스의 실제 직선 유지. `fire`, 폭0.14, 잔상0.34s | [전](before/mage.pyro.molten_line.png) · [후](after/mage.pyro.molten_line.png) · [마지막](last-pulse/mage.pyro.molten_line.png) |
| 15. ASHFALL | Ashfall은 나선 광선 대신 지면에 떨어지는 불씨. `ash`, 폭0.12, 잔상0.4s | [전](before/mage.pyro.ashfall.png) · [후](after/mage.pyro.ashfall.png) · [마지막](last-pulse/mage.pyro.ashfall.png) |
| 16. CALDERA'S JUDGMENT | Caldera 궁극기는반경20 지점의 용암과 분출. `lava`, 폭0.26, 잔상0.68s | [전](before/mage.pyro.caldera_s_judgment.png) · [후](after/mage.pyro.caldera_s_judgment.png) · [마지막](last-pulse/mage.pyro.caldera_s_judgment.png) |
| 17. FROST LANCE | Frost Lance는 좁고 뾰족한 얼음 창. `frost`, 폭0.17, 잔상0.38s | [전](before/mage.cryo.frost_lance.png) · [후](after/mage.cryo.frost_lance.png) |
| 18. ICE SHARD | Ice Shard는3갈래 짧은 결정 파편. `frost`, 폭0.12, 잔상0.34s | [전](before/mage.cryo.ice_shard.png) · [후](after/mage.cryo.ice_shard.png) |
| 19. FROST RING | Frost Ring은 시전자 중심360도 서리. `frost`, 폭0.13, 잔상0.46s | [전](before/mage.cryo.frost_ring.png) · [후](after/mage.cryo.frost_ring.png) |
| 20. SHATTER DART | 표식 파쇄 얼음은 짧은 쌍 결정. `frost`, 폭0.16, 잔상0.32s | [전](before/mage.cryo.shatter_dart.png) · [후](after/mage.cryo.shatter_dart.png) |
| 21. CHAIN LIGHTNING | Chain Lightning은 확정된 적 사이만 연결. `lightning`, 폭0.12, 잔상0.2s | [전](before/mage.cryo.chain_lightning.png) · [후](after/mage.cryo.chain_lightning.png) |
| 22. FROST STEP | Frost Step은 서버 출발 중심의 서리. `frost`, 폭0.12, 잔상0.4s | [전](before/mage.cryo.frost_step.png) · [후](after/mage.cryo.frost_step.png) |
| 23. THUNDER SPEAR | Thunder Spear는 한 전방축의 전기 창. `lightning`, 폭0.19, 잔상0.26s | [전](before/mage.cryo.thunder_spear.png) · [후](after/mage.cryo.thunder_spear.png) |
| 24. ICE WARD | Ice Ward의 냉기와 보호 부여를 분리. `frost`, 폭0.14, 잔상0.44s | [전](before/mage.cryo.ice_ward.png) · [후](after/mage.cryo.ice_ward.png) |
| 25. FROSTSTORM | Froststorm은 지정지점 반경14의 서리 폭풍. `frost`, 폭0.18, 잔상0.56s | [전](before/mage.cryo.froststorm.png) · [후](after/mage.cryo.froststorm.png) |
| 26. GLACIAL SPIKE | Glacial Spike는 큰 단일 결정창. `frost`, 폭0.26, 잔상0.46s | [전](before/mage.cryo.glacial_spike.png) · [후](after/mage.cryo.glacial_spike.png) |
| 27. LIGHTNING LINE | Lightning Line은 직선 축 주위 전기 가지. `lightning`, 폭0.14, 잔상0.24s | [전](before/mage.cryo.lightning_line.png) · [후](after/mage.cryo.lightning_line.png) |
| 28. HAILFALL | Hailfall은 바닥 파편 대신 상공 낙하 결정. `hail`, 폭0.13, 잔상0.4s | [전](before/mage.cryo.hailfall.png) · [후](after/mage.cryo.hailfall.png) · [마지막](last-pulse/mage.cryo.hailfall.png) |
| 29. ETERNAL TEMPEST | Eternal Tempest는20반경 지점의 빈 중심 서리 인장. `frost`, 폭0.22, 잔상0.64s | [전](before/mage.cryo.eternal_tempest.png) · [후](after/mage.cryo.eternal_tempest.png) · [마지막](last-pulse/mage.cryo.eternal_tempest.png) |
| 30. WIND LANCE | Wind Lance의전용 공기리본을중복하지않음. 별도 공기 리본 유지 | [전](before/mage_wind_lance.png) · [후](after/mage_wind_lance.png) |
| 31. TIDAL RING | Tidal Ring은시전자중심5stud 물결. `water`, 폭0.19, 잔상0.46s | [전](before/mage_tidal_ring.png) · [후](after/mage_tidal_ring.png) |
| 32. ARCANE WARD | Arcane Ward는시전점중심 보호리본. `ward`, 폭0.12, 잔상0.56s | [전](before/mage_arcane_ward.png) · [후](after/mage_arcane_ward.png) |

## dwarf

| 순서·스킬 | 개별 검토·조치 | 전 / 후 / 반복 마지막 |
| --- | --- | --- |
| 1. SHIELD BASH | Shield Bash는 방패 진행축에 수직인 접점. `guard`, 폭0.24, 잔상0.32s | [전](before/knight.common.bash.png) · [후](after/knight.common.bash.png) |
| 2. WHIRLWIND | Whirlwind의360도 검 궤적. `spin`, 폭0.21, 잔상0.38s | [전](before/knight.common.whirlwind.png) · [후](after/knight.common.whirlwind.png) |
| 3. PROVOKE | 도발은 피해광선 대신 발밑 함성 파문. `warcry`, 폭0.14, 잔상0.48s | [전](before/knight.common.provoke.png) · [후](after/knight.common.provoke.png) |
| 4. COUNTER SLASH | 반격의 짧은 칼날과 방어 호를 분리. `counter`, 폭0.19, 잔상0.42s | [전](before/knight.steel_knight.counter_slash.png) · [후](after/knight.steel_knight.counter_slash.png) |
| 5. STEEL SWEEP | 전방 부채꼴 끝을 잇는 낮은 강철 초승달. `crescent`, 폭0.25, 잔상0.4s | [전](before/knight.steel_knight.steel_sweep.png) · [후](after/knight.steel_knight.steel_sweep.png) |
| 6. CHALLENGING STRIKE | 도발 공격을 한 번의 검격과 발밑 압력으로 구분. `slash`, 폭0.22, 잔상0.42s | [전](before/knight.steel_knight.challenging_strike.png) · [후](after/knight.steel_knight.challenging_strike.png) |
| 7. TWIN CYCLONE | 두 펄스의 회전 위상을 바꿔 Twin Cyclone의 박자 표시. `spin`, 폭0.21, 잔상0.34s | [전](before/knight.steel_knight.twin_cyclone.png) · [후](after/knight.steel_knight.twin_cyclone.png) · [마지막](last-pulse/knight.steel_knight.twin_cyclone.png) |
| 8. SHIELD BREAKER | 한 대상 방패 파쇄의 전방 수직 면과 접점 집중. `guard`, 폭0.26, 잔상0.34s | [전](before/knight.steel_knight.shield_breaker.png) · [후](after/knight.steel_knight.shield_breaker.png) |
| 9. GUARDIAN COUNTER | 반격 궤적 뒤에 아군 보호와 구분되는 개인 방어 호. `counter`, 폭0.16, 잔상0.46s | [전](before/knight.steel_knight.guardian_counter.png) · [후](after/knight.steel_knight.guardian_counter.png) |
| 10. RALLYING SLASH | 넓은 선동 베기의 두 겹 전방 호. `areslash`, 폭0.18, 잔상0.44s | [전](before/knight.steel_knight.rallying_slash.png) · [후](after/knight.steel_knight.rallying_slash.png) |
| 11. BREAKER CHARGE | 돌진 두 펄스마다 진행축에 수직인 방패 파동. `guard`, 폭0.21, 잔상0.3s | [전](before/knight.steel_knight.breaker_charge.png) · [후](after/knight.steel_knight.breaker_charge.png) · [마지막](last-pulse/knight.steel_knight.breaker_charge.png) |
| 12. VANGUARD STRIKE | 일반 검광 대신 좁은 전방 찌르기. `thrust`, 폭0.16, 잔상0.36s | [전](before/knight.steel_knight.vanguard_strike.png) · [후](after/knight.steel_knight.vanguard_strike.png) |
| 13. BLADE STORM | 4회 박자마다 회전 위상 변경과 짧은 잔상. `spin`, 폭0.16, 잔상0.28s | [전](before/knight.steel_knight.blade_storm.png) · [후](after/knight.steel_knight.blade_storm.png) · [마지막](last-pulse/knight.steel_knight.blade_storm.png) |
| 14. SWEEPING BREAK | 전방 베기와 구별되는 바닥360도 파쇄 호. `crescent`, 폭0.25, 잔상0.46s | [전](before/knight.steel_knight.sweeping_break.png) · [후](after/knight.steel_knight.sweeping_break.png) |
| 15. WARCRY ASSAULT | 3회 함성 공격의 전방 압력 파문. `warcry`, 폭0.16, 잔상0.32s | [전](before/knight.steel_knight.warcry_assault.png) · [후](after/knight.steel_knight.warcry_assault.png) · [마지막](last-pulse/knight.steel_knight.warcry_assault.png) |
| 16. UNYIELDING FRONT | 궁극기의 원형 방어진과 전진 방패를 함께 표현. `guard`, 폭0.24, 잔상0.55s | [전](before/knight.steel_knight.unyielding_front.png) · [후](after/knight.steel_knight.unyielding_front.png) · [마지막](last-pulse/knight.steel_knight.unyielding_front.png) |
| 17. OATHBLADE | 맹세의 두 검격은 펄스별 좌우 반전. `slash`, 폭0.18, 잔상0.38s | [전](before/knight.paladin.oathblade.png) · [후](after/knight.paladin.oathblade.png) · [마지막](last-pulse/knight.paladin.oathblade.png) |
| 18. RADIANT SWEEP | 금빛 전방 호와 표식 접점을 짧게 유지. `crescent`, 폭0.28, 잔상0.45s | [전](before/knight.paladin.radiant_sweep.png) · [후](after/knight.paladin.radiant_sweep.png) |
| 19. OATH CHALLENGE | 맹세 소비는 전방 성광 압력으로 구분. `warcry`, 폭0.18, 잔상0.44s | [전](before/knight.paladin.oath_challenge.png) · [후](after/knight.paladin.oath_challenge.png) |
| 20. DAWN BURST | Dawn Burst는 시전자 중심 방사형 성광. `holy`, 폭0.18, 잔상0.5s | [전](before/knight.paladin.dawn_burst.png) · [후](after/knight.paladin.dawn_burst.png) |
| 21. OATHBREAKER STRIKE | 검격을 수직 내려찍기 실루엣으로 변경. `cleave`, 폭0.32, 잔상0.4s | [전](before/knight.paladin.oathbreaker_strike.png) · [후](after/knight.paladin.oathbreaker_strike.png) |
| 22. SHIELD VERDICT | Shield Verdict는 좁고 강한 방패 전면. `guard`, 폭0.3, 잔상0.38s | [전](before/knight.paladin.shield_verdict.png) · [후](after/knight.paladin.shield_verdict.png) |
| 23. GUARDIAN SLASH | 보호가 붙은 전방 검격의 칼날 호 분리. `crescent`, 폭0.21, 잔상0.43s | [전](before/knight.paladin.guardian_slash.png) · [후](after/knight.paladin.guardian_slash.png) |
| 24. RADIANT CHARGE | 성광 돌진은 전진축 방패 면을 유지. `guard`, 폭0.2, 잔상0.32s | [전](before/knight.paladin.radiant_charge.png) · [후](after/knight.paladin.radiant_charge.png) · [마지막](last-pulse/knight.paladin.radiant_charge.png) |
| 25. VALIANT ADVANCE | 다대상 전진을 넓고 얇은 방패 압력으로 구분. `guard`, 폭0.16, 잔상0.42s | [전](before/knight.paladin.valiant_advance.png) · [후](after/knight.paladin.valiant_advance.png) |
| 26. DAWN SPIRAL | 반복 나선은 펄스별 위상 변경. `holy`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.dawn_spiral.png) · [후](after/knight.paladin.dawn_spiral.png) · [마지막](last-pulse/knight.paladin.dawn_spiral.png) |
| 27. SUNWARD CROSS | Sunward Cross는 실제 교차하는 두 검광. `cross`, 폭0.23, 잔상0.38s | [전](before/knight.paladin.sunward_cross.png) · [후](after/knight.paladin.sunward_cross.png) · [마지막](last-pulse/knight.paladin.sunward_cross.png) |
| 28. OATHBOUND ASSAULT | 세 번 맹세 공격의 교대 검격. `slash`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.oathbound_assault.png) · [후](after/knight.paladin.oathbound_assault.png) · [마지막](last-pulse/knight.paladin.oathbound_assault.png) |
| 29. OATH OF DAWN | 맹세 궁극기는 중앙이 빈 방사형 성광 인장. `holy`, 폭0.23, 잔상0.7s | [전](before/knight.paladin.oath_of_dawn.png) · [후](after/knight.paladin.oath_of_dawn.png) · [마지막](last-pulse/knight.paladin.oath_of_dawn.png) |
| 30. DRIVING THRUST | Driving Thrust는좁은6stud 찌르기. `thrust`, 폭0.19, 잔상0.32s | [전](before/knight_driving_thrust.png) · [후](after/knight_driving_thrust.png) |
| 31. CRESCENT CUT | Crescent Cut은전방110도 단일호. `crescent`, 폭0.25, 잔상0.38s | [전](before/knight_crescent_cut.png) · [후](after/knight_crescent_cut.png) |
| 32. GUARDED STRIKE | Guarded Strike는단일 방패 접점과 방어호. `guard`, 폭0.19, 잔상0.34s | [전](before/knight_guarded_strike.png) · [후](after/knight_guarded_strike.png) |
| 1. OVERHEAD SMASH | Overhead Smash의 수직 궤적과 접점. `cleave`, 폭0.32, 잔상0.42s | [전](before/dwarf.common.overhead.png) · [후](after/dwarf.common.overhead.png) |
| 2. AXE THROW | 실제 도끼 투척의 회전 후류. `axe`, 폭0.14, 잔상0.38s | [전](before/dwarf.common.throw.png) · [후](after/dwarf.common.throw.png) |
| 3. GROUND SLAM | Ground Slam은 시전자 바닥 중심360도. `earth`, 폭0.18, 잔상0.48s | [전](before/dwarf.common.ground.png) · [후](after/dwarf.common.ground.png) |
| 4. ARMOR SPLITTER | 갑옷 파쇄는 도끼날의 수직 호. `cleave`, 폭0.32, 잔상0.38s | [전](before/dwarf.iron_axe.armor_splitter.png) · [후](after/dwarf.iron_axe.armor_splitter.png) |
| 5. RETURNING ECHO | 2펄스 복귀 방향을 실제로 반전. `axe`, 폭0.14, 잔상0.4s | [전](before/dwarf.iron_axe.returning_echo.png) · [후](after/dwarf.iron_axe.returning_echo.png) · [마지막](last-pulse/dwarf.iron_axe.returning_echo.png) |
| 6. MOUNTAIN SWEEP | Mountain Sweep은360도 원형 균열. `earth`, 폭0.16, 잔상0.46s | [전](before/dwarf.iron_axe.mountain_sweep.png) · [후](after/dwarf.iron_axe.mountain_sweep.png) |
| 7. CRAG CLEAVE | 전방 다대상 내려찍기를 쌍 수직 호로 표현. `cleave`, 폭0.25, 잔상0.42s | [전](before/dwarf.iron_axe.crag_cleave.png) · [후](after/dwarf.iron_axe.crag_cleave.png) |
| 8. BREAKER THROW | 강한 관통 투척을 긴 단일 도끼 후류로 구분. `axe`, 폭0.22, 잔상0.42s | [전](before/dwarf.iron_axe.breaker_throw.png) · [후](after/dwarf.iron_axe.breaker_throw.png) |
| 9. STONEBOUND LEAP | 착지 위치 중심으로 바깥 방향 파편. `earth`, 폭0.19, 잔상0.48s | [전](before/dwarf.iron_axe.stonebound_leap.png) · [후](after/dwarf.iron_axe.stonebound_leap.png) |
| 10. IRON SHOULDER | 어깨 밀기는 도끼 마법이 아닌 전방 충격. `guard`, 폭0.23, 잔상0.34s | [전](before/dwarf.iron_axe.iron_shoulder.png) · [후](after/dwarf.iron_axe.iron_shoulder.png) |
| 11. CROSSCUT AXE | 복귀/교차cut은 서버가 보낸 펄스 끝점을 유지. `axe`, 폭0.15, 잔상0.36s | [전](before/dwarf.iron_axe.crosscut_axe.png) · [후](after/dwarf.iron_axe.crosscut_axe.png) · [마지막](last-pulse/dwarf.iron_axe.crosscut_axe.png) |
| 12. MOUNTAIN STRIKE | 전방120도 이내로만 산맥 균열 전개. `earth`, 폭0.23, 잔상0.48s | [전](before/dwarf.iron_axe.mountain_strike.png) · [후](after/dwarf.iron_axe.mountain_strike.png) |
| 13. SHATTER BLOW | 지정 지점의 반경4 파쇄로 장거리 균열 방지. `earth`, 폭0.18, 잔상0.52s | [전](before/dwarf.iron_axe.shatter_blow.png) · [후](after/dwarf.iron_axe.shatter_blow.png) |
| 14. TWIN AXE PATH | 두 투척 펄스의 궤적과 회전 위상 구분. `axe`, 폭0.14, 잔상0.3s | [전](before/dwarf.iron_axe.twin_axe_path.png) · [후](after/dwarf.iron_axe.twin_axe_path.png) · [마지막](last-pulse/dwarf.iron_axe.twin_axe_path.png) |
| 15. TREMOR GUARD | 보호 부여는 낮은 바닥 진동 고리로 유지. `earth`, 폭0.14, 잔상0.48s | [전](before/dwarf.iron_axe.tremor_guard.png) · [후](after/dwarf.iron_axe.tremor_guard.png) |
| 16. MOUNTAIN COLLAPSE | 산맥 궁극기는 원형이 아닌 전방120도 대형 균열. `earth`, 폭0.25, 잔상0.66s | [전](before/dwarf.iron_axe.mountain_collapse.png) · [후](after/dwarf.iron_axe.mountain_collapse.png) · [마지막](last-pulse/dwarf.iron_axe.mountain_collapse.png) |
| 17. GUNNER SHOT | 한 발 총격의 짧은 총구와 얇은 탄도. `bullet`, 폭0.08, 잔상0.18s | [전](before/dwarf.gunner.gunner_shot.png) · [후](after/dwarf.gunner.gunner_shot.png) |
| 18. BOMB TOSS | 수류탄은 지정지점의 바깥 폭발과 파편. `blast`, 폭0.18, 잔상0.44s | [전](before/dwarf.gunner.bomb_toss.png) · [후](after/dwarf.gunner.bomb_toss.png) |
| 19. SHELL BURST | 포탄은 상공 낙하축과 접지 폭발. `mortar`, 폭0.2, 잔상0.4s | [전](before/dwarf.gunner.shell_burst.png) · [후](after/dwarf.gunner.shell_burst.png) |
| 20. QUICKFIRE | 속사는 펄스보다 짧은 탄도 수명. `bullet`, 폭0.06, 잔상0.13s | [전](before/dwarf.gunner.quickfire.png) · [후](after/dwarf.gunner.quickfire.png) · [마지막](last-pulse/dwarf.gunner.quickfire.png) |
| 21. SHRAPNEL TOSS | 산개된 실제 서버 중심마다 파편 폭발. `blast`, 폭0.13, 잔상0.32s | [전](before/dwarf.gunner.shrapnel_toss.png) · [후](after/dwarf.gunner.shrapnel_toss.png) · [마지막](last-pulse/dwarf.gunner.shrapnel_toss.png) |
| 22. BLAST STEP | 후퇴 폭발은 전방 부채꼴만 표시. `blast`, 폭0.19, 잔상0.38s | [전](before/dwarf.gunner.blast_step.png) · [후](after/dwarf.gunner.blast_step.png) |
| 23. SCATTER SHOT | 산탄은 한 직선 대신5개 부채꼴 탄도. `fan`, 폭0.07, 잔상0.19s | [전](before/dwarf.gunner.scatter_shot.png) · [후](after/dwarf.gunner.scatter_shot.png) |
| 24. SKIPPING CHARGE | 두 번 튀는 폭탄의 실제 산개 중심 유지. `blast`, 폭0.17, 잔상0.36s | [전](before/dwarf.gunner.skipping_charge.png) · [후](after/dwarf.gunner.skipping_charge.png) · [마지막](last-pulse/dwarf.gunner.skipping_charge.png) |
| 25. FIELD MORTAR | 포격은4회 각각 낙하 흔적. `mortar`, 폭0.17, 잔상0.42s | [전](before/dwarf.gunner.field_mortar.png) · [후](after/dwarf.gunner.field_mortar.png) · [마지막](last-pulse/dwarf.gunner.field_mortar.png) |
| 26. PIERCING ROUND | 관통탄은 가는 심과 압력 후류로 구분. `bullet`, 폭0.09, 잔상0.22s | [전](before/dwarf.gunner.piercing_round.png) · [후](after/dwarf.gunner.piercing_round.png) |
| 27. ROLLING CHARGE | 굴림 폭탄 폭발 중심은 서버 확정 지점. `blast`, 폭0.2, 잔상0.44s | [전](before/dwarf.gunner.rolling_charge.png) · [후](after/dwarf.gunner.rolling_charge.png) |
| 28. SIEGE PATTERN | 두 포격의 개별 서버 위치 표시. `mortar`, 폭0.18, 잔상0.43s | [전](before/dwarf.gunner.siege_pattern.png) · [후](after/dwarf.gunner.siege_pattern.png) · [마지막](last-pulse/dwarf.gunner.siege_pattern.png) |
| 29. SIEGE BARRAGE | 궁극기4펄스도 이전 포격 잔상이 겹치지 않게 제한. `mortar`, 폭0.23, 잔상0.46s | [전](before/dwarf.gunner.siege_barrage.png) · [후](after/dwarf.gunner.siege_barrage.png) · [마지막](last-pulse/dwarf.gunner.siege_barrage.png) |
| 30. HOOKING CHOP | Hooking Chop은짧은 갈고리형 수직호. `cleave`, 폭0.24, 잔상0.3s | [전](before/dwarf_hooking_chop.png) · [후](after/dwarf_hooking_chop.png) |
| 31. LOW SWEEP | Low Sweep은발목 높이 전방110도 호. `low`, 폭0.22, 잔상0.36s | [전](before/dwarf_low_sweep.png) · [후](after/dwarf_low_sweep.png) |
| 32. BRACED THROW | Braced Throw는26stud 관통 후류. `axe`, 폭0.2, 잔상0.42s | [전](before/dwarf_braced_throw.png) · [후](after/dwarf_braced_throw.png) |
| 1. AIMED SHOT | Aimed Shot은 굵은 단일 정밀 후류. `arrow`, 폭0.15, 잔상0.38s | [전](before/elf.common.aimed.png) · [후](after/elf.common.aimed.png) |
| 2. RAPID FIRE | Rapid Fire는 각 발사가 겹치지 않는 짧은 후류. `arrow`, 폭0.07, 잔상0.16s | [전](before/elf.common.rapid.png) · [후](after/elf.common.rapid.png) · [마지막](last-pulse/elf.common.rapid.png) |
| 3. MULTI SHOT | Multi Shot은 실제70도 범위의5방향 화살. `fan`, 폭0.08, 잔상0.28s | [전](before/elf.common.multi.png) · [후](after/elf.common.multi.png) |
| 4. WEAKPOINT SHOT | 약점 사격은 단일 정밀 후류. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.marksman.weakpoint_shot.png) · [후](after/elf.marksman.weakpoint_shot.png) |
| 5. MOVING VOLLEY | 이동3연사는 짧은 개별 사격. `arrow`, 폭0.08, 잔상0.2s | [전](before/elf.marksman.moving_volley.png) · [후](after/elf.marksman.moving_volley.png) · [마지막](last-pulse/elf.marksman.moving_volley.png) |
| 6. PIERCING LINE | 관통 직선의 두 가는 압력선. `arrow`, 폭0.09, 잔상0.34s | [전](before/elf.marksman.piercing_line.png) · [후](after/elf.marksman.piercing_line.png) |
| 7. HEAVY DRAW | 강하게 당긴 화살은 두꺼운 단일 관통 심. `arrow`, 폭0.17, 잔상0.42s | [전](before/elf.marksman.heavy_draw.png) · [후](after/elf.marksman.heavy_draw.png) |
| 8. PRECISION VOLLEY | 약점 소비3연사는 이전 꼬리를 빨리 제거. `arrow`, 폭0.1, 잔상0.24s | [전](before/elf.marksman.precision_volley.png) · [후](after/elf.marksman.precision_volley.png) · [마지막](last-pulse/elf.marksman.precision_volley.png) |
| 9. FAN BREAK | Fan Break의 실제 부채꼴 범위를 화살로 표현. `fan`, 폭0.09, 잔상0.3s | [전](before/elf.marksman.fan_break.png) · [후](after/elf.marksman.fan_break.png) |
| 10. HUNTER'S FOCUS | 집중 사격의 이중 후류와 실제 보호 표시. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.hunter_s_focus.png) · [후](after/elf.marksman.hunter_s_focus.png) |
| 11. RETREATING FIRE | 후퇴 이동은 현재 발사점에서 시작. `arrow`, 폭0.12, 잔상0.32s | [전](before/elf.marksman.retreating_fire.png) · [후](after/elf.marksman.retreating_fire.png) |
| 12. PIERCING VOLLEY | 45stud 관통 부채를 한 줄로 축소하지 않음. `fan`, 폭0.11, 잔상0.36s | [전](before/elf.marksman.piercing_volley.png) · [후](after/elf.marksman.piercing_volley.png) |
| 13. MARK BREAKER | 표식 파쇄는 굵은 단일 화살 접점. `arrow`, 폭0.18, 잔상0.38s | [전](before/elf.marksman.mark_breaker.png) · [후](after/elf.marksman.mark_breaker.png) |
| 14. CROSSFIRE | Crossfire의2펄스 교차 방향을 서버 그대로 사용. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf.marksman.crossfire.png) · [후](after/elf.marksman.crossfire.png) · [마지막](last-pulse/elf.marksman.crossfire.png) |
| 15. ARROW RAIN | Arrow Rain은 실제 지정지점에만 낙하. `rain`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.arrow_rain.png) · [후](after/elf.marksman.arrow_rain.png) · [마지막](last-pulse/elf.marksman.arrow_rain.png) |
| 16. GRAND VOLLEY | Grand Volley는90도 부채꼴3회로 구분. `fan`, 폭0.12, 잔상0.3s | [전](before/elf.marksman.grand_volley.png) · [후](after/elf.marksman.grand_volley.png) · [마지막](last-pulse/elf.marksman.grand_volley.png) |
| 17. ELEMENTAL ARROW | 자연 화살의 가는 마력 나선. `arrow`, 폭0.13, 잔상0.35s | [전](before/elf.magic_archer.elemental_arrow.png) · [후](after/elf.magic_archer.elemental_arrow.png) |
| 18. SPARK VOLLEY | 번개 속성 화살은 전기 가지가 달린 개별3연사. `arrow`, 폭0.08, 잔상0.22s | [전](before/elf.magic_archer.spark_volley.png) · [후](after/elf.magic_archer.spark_volley.png) · [마지막](last-pulse/elf.magic_archer.spark_volley.png) |
| 19. VINE TRAP | Vine Trap은 지정지점을 감싸는 뿌리. `vine`, 폭0.12, 잔상0.44s | [전](before/elf.magic_archer.vine_trap.png) · [후](after/elf.magic_archer.vine_trap.png) · [마지막](last-pulse/elf.magic_archer.vine_trap.png) |
| 20. BLOOM SHOT | Bloom Shot은 명중점의 꽃잎형3갈래 접점. `arrow`, 폭0.12, 잔상0.38s | [전](before/elf.magic_archer.bloom_shot.png) · [후](after/elf.magic_archer.bloom_shot.png) |
| 21. STORM ARROW | Storm Arrow는 상공에서 지정지점으로 낙뢰. `lightning`, 폭0.14, 잔상0.28s | [전](before/elf.magic_archer.storm_arrow.png) · [후](after/elf.magic_archer.storm_arrow.png) |
| 22. ROOTING FAN | Rooting Fan은 시전자 앞 부채꼴 뿌리. `vine`, 폭0.11, 잔상0.4s | [전](before/elf.magic_archer.rooting_fan.png) · [후](after/elf.magic_archer.rooting_fan.png) |
| 23. WARDEN ARROW | Warden Arrow는 보호 효과와 화살 궤적 분리. `arrow`, 폭0.11, 잔상0.34s | [전](before/elf.magic_archer.warden_arrow.png) · [후](after/elf.magic_archer.warden_arrow.png) |
| 24. GLIDING SHOT | 전진 사격은 현재 발사점 기준. `arrow`, 폭0.12, 잔상0.3s | [전](before/elf.magic_archer.gliding_shot.png) · [후](after/elf.magic_archer.gliding_shot.png) |
| 25. SPIRIT RAIN | Spirit Rain은 자연 팔레트의 낙하 화살. `rain`, 폭0.13, 잔상0.3s | [전](before/elf.magic_archer.spirit_rain.png) · [후](after/elf.magic_archer.spirit_rain.png) · [마지막](last-pulse/elf.magic_archer.spirit_rain.png) |
| 26. ELEMENTAL PIERCE | Elemental Pierce는 좁은 직선 관통. `arrow`, 폭0.14, 잔상0.36s | [전](before/elf.magic_archer.elemental_pierce.png) · [후](after/elf.magic_archer.elemental_pierce.png) |
| 27. ECHO ARROWS | 3회 Echo는 각 펄스 나선 위상을 변경. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.magic_archer.echo_arrows.png) · [후](after/elf.magic_archer.echo_arrows.png) · [마지막](last-pulse/elf.magic_archer.echo_arrows.png) |
| 28. VINE BURST | Vine Burst는 지점 중심의 뿌리 폭발. `vine`, 폭0.16, 잔상0.5s | [전](before/elf.magic_archer.vine_burst.png) · [후](after/elf.magic_archer.vine_burst.png) |
| 29. SPIRIT ARROWFALL | 궁극기는3회 지정지점 화살비와 개별접점. `rain`, 폭0.16, 잔상0.46s | [전](before/elf.magic_archer.spirit_arrowfall.png) · [후](after/elf.magic_archer.spirit_arrowfall.png) · [마지막](last-pulse/elf.magic_archer.spirit_arrowfall.png) |
| 30. RETREATING SHOT | Retreating Shot은뒤로 이동해도 발사 방향 유지. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf_retreating_shot.png) · [후](after/elf_retreating_shot.png) |
| 31. PINNING SHOT | Pinning Shot은끝점의 짧은 고정 접점. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf_pinning_shot.png) · [후](after/elf_pinning_shot.png) |
| 32. ARROW SCREEN | Arrow Screen은반경4의 가까운 화살비. `rain`, 폭0.08, 잔상0.34s | [전](before/elf_arrow_screen.png) · [후](after/elf_arrow_screen.png) · [마지막](last-pulse/elf_arrow_screen.png) |
| 1. MANA BOLT | Mana Bolt는 비전색 쌍 나선. `arcane`, 폭0.12, 잔상0.34s | [전](before/mage.common.mana_bolt.png) · [후](after/mage.common.mana_bolt.png) |
| 2. WATER BALL | Water Ball의 구면 물보라와 젖음 접점. `water`, 폭0.16, 잔상0.42s | [전](before/mage.common.water_ball.png) · [후](after/mage.common.water_ball.png) |
| 3. GRAVITY | Gravity는 확정 영역 안쪽으로 당기는 나선. `gravity`, 폭0.14, 잔상0.56s | [전](before/mage.common.gravity.png) · [후](after/mage.common.gravity.png) |
| 4. EMBER LANCE | Ember Lance는 뾰족한 전방 불꽃 창. `fire`, 폭0.15, 잔상0.36s | [전](before/mage.pyro.ember_lance.png) · [후](after/mage.pyro.ember_lance.png) |
| 5. STEAM BURST | Steam Burst의 물색 증기를 위로 올림. `steam`, 폭0.17, 잔상0.48s | [전](before/mage.pyro.steam_burst.png) · [후](after/mage.pyro.steam_burst.png) |
| 6. CINDER RING | Cinder Ring은 시전자 중심의 빈 원형 화염. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.cinder_ring.png) · [후](after/mage.pyro.cinder_ring.png) · [마지막](last-pulse/mage.pyro.cinder_ring.png) |
| 7. FLAME DART | 짧은 시전 Flame Dart는 가늘고 짧게. `fire`, 폭0.13, 잔상0.24s | [전](before/mage.pyro.flame_dart.png) · [후](after/mage.pyro.flame_dart.png) |
| 8. EARTH RISE | Earth Rise는 지점 중심의 솟는 암석. `earth`, 폭0.18, 잔상0.48s | [전](before/mage.pyro.earth_rise.png) · [후](after/mage.pyro.earth_rise.png) |
| 9. EMBER STEP | Ember Step은 이동 후가 아닌 서버의 출발장판 중심. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.ember_step.png) · [후](after/mage.pyro.ember_step.png) |
| 10. STONE LANCE | Stone Lance는 바닥 균열 대신 공중 돌창. `stone`, 폭0.23, 잔상0.42s | [전](before/mage.pyro.stone_lance.png) · [후](after/mage.pyro.stone_lance.png) |
| 11. SEARING WARD | Searing Ward는 원형 열기와 보호 부여를 구분. `fire`, 폭0.15, 잔상0.42s | [전](before/mage.pyro.searing_ward.png) · [후](after/mage.pyro.searing_ward.png) |
| 12. LAVA ERUPTION | Lava Eruption은 반경14 내 방사형 용암 균열. `lava`, 폭0.24, 잔상0.6s | [전](before/mage.pyro.lava_eruption.png) · [후](after/mage.pyro.lava_eruption.png) |
| 13. MAGMA SPEAR | Magma Spear는3겹 고온 창 심. `fire`, 폭0.18, 잔상0.44s | [전](before/mage.pyro.magma_spear.png) · [후](after/mage.pyro.magma_spear.png) |
| 14. MOLTEN LINE | Molten Line은3펄스의 실제 직선 유지. `fire`, 폭0.14, 잔상0.34s | [전](before/mage.pyro.molten_line.png) · [후](after/mage.pyro.molten_line.png) · [마지막](last-pulse/mage.pyro.molten_line.png) |
| 15. ASHFALL | Ashfall은 나선 광선 대신 지면에 떨어지는 불씨. `ash`, 폭0.12, 잔상0.4s | [전](before/mage.pyro.ashfall.png) · [후](after/mage.pyro.ashfall.png) · [마지막](last-pulse/mage.pyro.ashfall.png) |
| 16. CALDERA'S JUDGMENT | Caldera 궁극기는반경20 지점의 용암과 분출. `lava`, 폭0.26, 잔상0.68s | [전](before/mage.pyro.caldera_s_judgment.png) · [후](after/mage.pyro.caldera_s_judgment.png) · [마지막](last-pulse/mage.pyro.caldera_s_judgment.png) |
| 17. FROST LANCE | Frost Lance는 좁고 뾰족한 얼음 창. `frost`, 폭0.17, 잔상0.38s | [전](before/mage.cryo.frost_lance.png) · [후](after/mage.cryo.frost_lance.png) |
| 18. ICE SHARD | Ice Shard는3갈래 짧은 결정 파편. `frost`, 폭0.12, 잔상0.34s | [전](before/mage.cryo.ice_shard.png) · [후](after/mage.cryo.ice_shard.png) |
| 19. FROST RING | Frost Ring은 시전자 중심360도 서리. `frost`, 폭0.13, 잔상0.46s | [전](before/mage.cryo.frost_ring.png) · [후](after/mage.cryo.frost_ring.png) |
| 20. SHATTER DART | 표식 파쇄 얼음은 짧은 쌍 결정. `frost`, 폭0.16, 잔상0.32s | [전](before/mage.cryo.shatter_dart.png) · [후](after/mage.cryo.shatter_dart.png) |
| 21. CHAIN LIGHTNING | Chain Lightning은 확정된 적 사이만 연결. `lightning`, 폭0.12, 잔상0.2s | [전](before/mage.cryo.chain_lightning.png) · [후](after/mage.cryo.chain_lightning.png) |
| 22. FROST STEP | Frost Step은 서버 출발 중심의 서리. `frost`, 폭0.12, 잔상0.4s | [전](before/mage.cryo.frost_step.png) · [후](after/mage.cryo.frost_step.png) |
| 23. THUNDER SPEAR | Thunder Spear는 한 전방축의 전기 창. `lightning`, 폭0.19, 잔상0.26s | [전](before/mage.cryo.thunder_spear.png) · [후](after/mage.cryo.thunder_spear.png) |
| 24. ICE WARD | Ice Ward의 냉기와 보호 부여를 분리. `frost`, 폭0.14, 잔상0.44s | [전](before/mage.cryo.ice_ward.png) · [후](after/mage.cryo.ice_ward.png) |
| 25. FROSTSTORM | Froststorm은 지정지점 반경14의 서리 폭풍. `frost`, 폭0.18, 잔상0.56s | [전](before/mage.cryo.froststorm.png) · [후](after/mage.cryo.froststorm.png) |
| 26. GLACIAL SPIKE | Glacial Spike는 큰 단일 결정창. `frost`, 폭0.26, 잔상0.46s | [전](before/mage.cryo.glacial_spike.png) · [후](after/mage.cryo.glacial_spike.png) |
| 27. LIGHTNING LINE | Lightning Line은 직선 축 주위 전기 가지. `lightning`, 폭0.14, 잔상0.24s | [전](before/mage.cryo.lightning_line.png) · [후](after/mage.cryo.lightning_line.png) |
| 28. HAILFALL | Hailfall은 바닥 파편 대신 상공 낙하 결정. `hail`, 폭0.13, 잔상0.4s | [전](before/mage.cryo.hailfall.png) · [후](after/mage.cryo.hailfall.png) · [마지막](last-pulse/mage.cryo.hailfall.png) |
| 29. ETERNAL TEMPEST | Eternal Tempest는20반경 지점의 빈 중심 서리 인장. `frost`, 폭0.22, 잔상0.64s | [전](before/mage.cryo.eternal_tempest.png) · [후](after/mage.cryo.eternal_tempest.png) · [마지막](last-pulse/mage.cryo.eternal_tempest.png) |
| 30. WIND LANCE | Wind Lance의전용 공기리본을중복하지않음. 별도 공기 리본 유지 | [전](before/mage_wind_lance.png) · [후](after/mage_wind_lance.png) |
| 31. TIDAL RING | Tidal Ring은시전자중심5stud 물결. `water`, 폭0.19, 잔상0.46s | [전](before/mage_tidal_ring.png) · [후](after/mage_tidal_ring.png) |
| 32. ARCANE WARD | Arcane Ward는시전점중심 보호리본. `ward`, 폭0.12, 잔상0.56s | [전](before/mage_arcane_ward.png) · [후](after/mage_arcane_ward.png) |

## elf

| 순서·스킬 | 개별 검토·조치 | 전 / 후 / 반복 마지막 |
| --- | --- | --- |
| 1. SHIELD BASH | Shield Bash는 방패 진행축에 수직인 접점. `guard`, 폭0.24, 잔상0.32s | [전](before/knight.common.bash.png) · [후](after/knight.common.bash.png) |
| 2. WHIRLWIND | Whirlwind의360도 검 궤적. `spin`, 폭0.21, 잔상0.38s | [전](before/knight.common.whirlwind.png) · [후](after/knight.common.whirlwind.png) |
| 3. PROVOKE | 도발은 피해광선 대신 발밑 함성 파문. `warcry`, 폭0.14, 잔상0.48s | [전](before/knight.common.provoke.png) · [후](after/knight.common.provoke.png) |
| 4. COUNTER SLASH | 반격의 짧은 칼날과 방어 호를 분리. `counter`, 폭0.19, 잔상0.42s | [전](before/knight.steel_knight.counter_slash.png) · [후](after/knight.steel_knight.counter_slash.png) |
| 5. STEEL SWEEP | 전방 부채꼴 끝을 잇는 낮은 강철 초승달. `crescent`, 폭0.25, 잔상0.4s | [전](before/knight.steel_knight.steel_sweep.png) · [후](after/knight.steel_knight.steel_sweep.png) |
| 6. CHALLENGING STRIKE | 도발 공격을 한 번의 검격과 발밑 압력으로 구분. `slash`, 폭0.22, 잔상0.42s | [전](before/knight.steel_knight.challenging_strike.png) · [후](after/knight.steel_knight.challenging_strike.png) |
| 7. TWIN CYCLONE | 두 펄스의 회전 위상을 바꿔 Twin Cyclone의 박자 표시. `spin`, 폭0.21, 잔상0.34s | [전](before/knight.steel_knight.twin_cyclone.png) · [후](after/knight.steel_knight.twin_cyclone.png) · [마지막](last-pulse/knight.steel_knight.twin_cyclone.png) |
| 8. SHIELD BREAKER | 한 대상 방패 파쇄의 전방 수직 면과 접점 집중. `guard`, 폭0.26, 잔상0.34s | [전](before/knight.steel_knight.shield_breaker.png) · [후](after/knight.steel_knight.shield_breaker.png) |
| 9. GUARDIAN COUNTER | 반격 궤적 뒤에 아군 보호와 구분되는 개인 방어 호. `counter`, 폭0.16, 잔상0.46s | [전](before/knight.steel_knight.guardian_counter.png) · [후](after/knight.steel_knight.guardian_counter.png) |
| 10. RALLYING SLASH | 넓은 선동 베기의 두 겹 전방 호. `areslash`, 폭0.18, 잔상0.44s | [전](before/knight.steel_knight.rallying_slash.png) · [후](after/knight.steel_knight.rallying_slash.png) |
| 11. BREAKER CHARGE | 돌진 두 펄스마다 진행축에 수직인 방패 파동. `guard`, 폭0.21, 잔상0.3s | [전](before/knight.steel_knight.breaker_charge.png) · [후](after/knight.steel_knight.breaker_charge.png) · [마지막](last-pulse/knight.steel_knight.breaker_charge.png) |
| 12. VANGUARD STRIKE | 일반 검광 대신 좁은 전방 찌르기. `thrust`, 폭0.16, 잔상0.36s | [전](before/knight.steel_knight.vanguard_strike.png) · [후](after/knight.steel_knight.vanguard_strike.png) |
| 13. BLADE STORM | 4회 박자마다 회전 위상 변경과 짧은 잔상. `spin`, 폭0.16, 잔상0.28s | [전](before/knight.steel_knight.blade_storm.png) · [후](after/knight.steel_knight.blade_storm.png) · [마지막](last-pulse/knight.steel_knight.blade_storm.png) |
| 14. SWEEPING BREAK | 전방 베기와 구별되는 바닥360도 파쇄 호. `crescent`, 폭0.25, 잔상0.46s | [전](before/knight.steel_knight.sweeping_break.png) · [후](after/knight.steel_knight.sweeping_break.png) |
| 15. WARCRY ASSAULT | 3회 함성 공격의 전방 압력 파문. `warcry`, 폭0.16, 잔상0.32s | [전](before/knight.steel_knight.warcry_assault.png) · [후](after/knight.steel_knight.warcry_assault.png) · [마지막](last-pulse/knight.steel_knight.warcry_assault.png) |
| 16. UNYIELDING FRONT | 궁극기의 원형 방어진과 전진 방패를 함께 표현. `guard`, 폭0.24, 잔상0.55s | [전](before/knight.steel_knight.unyielding_front.png) · [후](after/knight.steel_knight.unyielding_front.png) · [마지막](last-pulse/knight.steel_knight.unyielding_front.png) |
| 17. OATHBLADE | 맹세의 두 검격은 펄스별 좌우 반전. `slash`, 폭0.18, 잔상0.38s | [전](before/knight.paladin.oathblade.png) · [후](after/knight.paladin.oathblade.png) · [마지막](last-pulse/knight.paladin.oathblade.png) |
| 18. RADIANT SWEEP | 금빛 전방 호와 표식 접점을 짧게 유지. `crescent`, 폭0.28, 잔상0.45s | [전](before/knight.paladin.radiant_sweep.png) · [후](after/knight.paladin.radiant_sweep.png) |
| 19. OATH CHALLENGE | 맹세 소비는 전방 성광 압력으로 구분. `warcry`, 폭0.18, 잔상0.44s | [전](before/knight.paladin.oath_challenge.png) · [후](after/knight.paladin.oath_challenge.png) |
| 20. DAWN BURST | Dawn Burst는 시전자 중심 방사형 성광. `holy`, 폭0.18, 잔상0.5s | [전](before/knight.paladin.dawn_burst.png) · [후](after/knight.paladin.dawn_burst.png) |
| 21. OATHBREAKER STRIKE | 검격을 수직 내려찍기 실루엣으로 변경. `cleave`, 폭0.32, 잔상0.4s | [전](before/knight.paladin.oathbreaker_strike.png) · [후](after/knight.paladin.oathbreaker_strike.png) |
| 22. SHIELD VERDICT | Shield Verdict는 좁고 강한 방패 전면. `guard`, 폭0.3, 잔상0.38s | [전](before/knight.paladin.shield_verdict.png) · [후](after/knight.paladin.shield_verdict.png) |
| 23. GUARDIAN SLASH | 보호가 붙은 전방 검격의 칼날 호 분리. `crescent`, 폭0.21, 잔상0.43s | [전](before/knight.paladin.guardian_slash.png) · [후](after/knight.paladin.guardian_slash.png) |
| 24. RADIANT CHARGE | 성광 돌진은 전진축 방패 면을 유지. `guard`, 폭0.2, 잔상0.32s | [전](before/knight.paladin.radiant_charge.png) · [후](after/knight.paladin.radiant_charge.png) · [마지막](last-pulse/knight.paladin.radiant_charge.png) |
| 25. VALIANT ADVANCE | 다대상 전진을 넓고 얇은 방패 압력으로 구분. `guard`, 폭0.16, 잔상0.42s | [전](before/knight.paladin.valiant_advance.png) · [후](after/knight.paladin.valiant_advance.png) |
| 26. DAWN SPIRAL | 반복 나선은 펄스별 위상 변경. `holy`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.dawn_spiral.png) · [후](after/knight.paladin.dawn_spiral.png) · [마지막](last-pulse/knight.paladin.dawn_spiral.png) |
| 27. SUNWARD CROSS | Sunward Cross는 실제 교차하는 두 검광. `cross`, 폭0.23, 잔상0.38s | [전](before/knight.paladin.sunward_cross.png) · [후](after/knight.paladin.sunward_cross.png) · [마지막](last-pulse/knight.paladin.sunward_cross.png) |
| 28. OATHBOUND ASSAULT | 세 번 맹세 공격의 교대 검격. `slash`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.oathbound_assault.png) · [후](after/knight.paladin.oathbound_assault.png) · [마지막](last-pulse/knight.paladin.oathbound_assault.png) |
| 29. OATH OF DAWN | 맹세 궁극기는 중앙이 빈 방사형 성광 인장. `holy`, 폭0.23, 잔상0.7s | [전](before/knight.paladin.oath_of_dawn.png) · [후](after/knight.paladin.oath_of_dawn.png) · [마지막](last-pulse/knight.paladin.oath_of_dawn.png) |
| 30. DRIVING THRUST | Driving Thrust는좁은6stud 찌르기. `thrust`, 폭0.19, 잔상0.32s | [전](before/knight_driving_thrust.png) · [후](after/knight_driving_thrust.png) |
| 31. CRESCENT CUT | Crescent Cut은전방110도 단일호. `crescent`, 폭0.25, 잔상0.38s | [전](before/knight_crescent_cut.png) · [후](after/knight_crescent_cut.png) |
| 32. GUARDED STRIKE | Guarded Strike는단일 방패 접점과 방어호. `guard`, 폭0.19, 잔상0.34s | [전](before/knight_guarded_strike.png) · [후](after/knight_guarded_strike.png) |
| 1. OVERHEAD SMASH | Overhead Smash의 수직 궤적과 접점. `cleave`, 폭0.32, 잔상0.42s | [전](before/dwarf.common.overhead.png) · [후](after/dwarf.common.overhead.png) |
| 2. AXE THROW | 실제 도끼 투척의 회전 후류. `axe`, 폭0.14, 잔상0.38s | [전](before/dwarf.common.throw.png) · [후](after/dwarf.common.throw.png) |
| 3. GROUND SLAM | Ground Slam은 시전자 바닥 중심360도. `earth`, 폭0.18, 잔상0.48s | [전](before/dwarf.common.ground.png) · [후](after/dwarf.common.ground.png) |
| 4. ARMOR SPLITTER | 갑옷 파쇄는 도끼날의 수직 호. `cleave`, 폭0.32, 잔상0.38s | [전](before/dwarf.iron_axe.armor_splitter.png) · [후](after/dwarf.iron_axe.armor_splitter.png) |
| 5. RETURNING ECHO | 2펄스 복귀 방향을 실제로 반전. `axe`, 폭0.14, 잔상0.4s | [전](before/dwarf.iron_axe.returning_echo.png) · [후](after/dwarf.iron_axe.returning_echo.png) · [마지막](last-pulse/dwarf.iron_axe.returning_echo.png) |
| 6. MOUNTAIN SWEEP | Mountain Sweep은360도 원형 균열. `earth`, 폭0.16, 잔상0.46s | [전](before/dwarf.iron_axe.mountain_sweep.png) · [후](after/dwarf.iron_axe.mountain_sweep.png) |
| 7. CRAG CLEAVE | 전방 다대상 내려찍기를 쌍 수직 호로 표현. `cleave`, 폭0.25, 잔상0.42s | [전](before/dwarf.iron_axe.crag_cleave.png) · [후](after/dwarf.iron_axe.crag_cleave.png) |
| 8. BREAKER THROW | 강한 관통 투척을 긴 단일 도끼 후류로 구분. `axe`, 폭0.22, 잔상0.42s | [전](before/dwarf.iron_axe.breaker_throw.png) · [후](after/dwarf.iron_axe.breaker_throw.png) |
| 9. STONEBOUND LEAP | 착지 위치 중심으로 바깥 방향 파편. `earth`, 폭0.19, 잔상0.48s | [전](before/dwarf.iron_axe.stonebound_leap.png) · [후](after/dwarf.iron_axe.stonebound_leap.png) |
| 10. IRON SHOULDER | 어깨 밀기는 도끼 마법이 아닌 전방 충격. `guard`, 폭0.23, 잔상0.34s | [전](before/dwarf.iron_axe.iron_shoulder.png) · [후](after/dwarf.iron_axe.iron_shoulder.png) |
| 11. CROSSCUT AXE | 복귀/교차cut은 서버가 보낸 펄스 끝점을 유지. `axe`, 폭0.15, 잔상0.36s | [전](before/dwarf.iron_axe.crosscut_axe.png) · [후](after/dwarf.iron_axe.crosscut_axe.png) · [마지막](last-pulse/dwarf.iron_axe.crosscut_axe.png) |
| 12. MOUNTAIN STRIKE | 전방120도 이내로만 산맥 균열 전개. `earth`, 폭0.23, 잔상0.48s | [전](before/dwarf.iron_axe.mountain_strike.png) · [후](after/dwarf.iron_axe.mountain_strike.png) |
| 13. SHATTER BLOW | 지정 지점의 반경4 파쇄로 장거리 균열 방지. `earth`, 폭0.18, 잔상0.52s | [전](before/dwarf.iron_axe.shatter_blow.png) · [후](after/dwarf.iron_axe.shatter_blow.png) |
| 14. TWIN AXE PATH | 두 투척 펄스의 궤적과 회전 위상 구분. `axe`, 폭0.14, 잔상0.3s | [전](before/dwarf.iron_axe.twin_axe_path.png) · [후](after/dwarf.iron_axe.twin_axe_path.png) · [마지막](last-pulse/dwarf.iron_axe.twin_axe_path.png) |
| 15. TREMOR GUARD | 보호 부여는 낮은 바닥 진동 고리로 유지. `earth`, 폭0.14, 잔상0.48s | [전](before/dwarf.iron_axe.tremor_guard.png) · [후](after/dwarf.iron_axe.tremor_guard.png) |
| 16. MOUNTAIN COLLAPSE | 산맥 궁극기는 원형이 아닌 전방120도 대형 균열. `earth`, 폭0.25, 잔상0.66s | [전](before/dwarf.iron_axe.mountain_collapse.png) · [후](after/dwarf.iron_axe.mountain_collapse.png) · [마지막](last-pulse/dwarf.iron_axe.mountain_collapse.png) |
| 17. GUNNER SHOT | 한 발 총격의 짧은 총구와 얇은 탄도. `bullet`, 폭0.08, 잔상0.18s | [전](before/dwarf.gunner.gunner_shot.png) · [후](after/dwarf.gunner.gunner_shot.png) |
| 18. BOMB TOSS | 수류탄은 지정지점의 바깥 폭발과 파편. `blast`, 폭0.18, 잔상0.44s | [전](before/dwarf.gunner.bomb_toss.png) · [후](after/dwarf.gunner.bomb_toss.png) |
| 19. SHELL BURST | 포탄은 상공 낙하축과 접지 폭발. `mortar`, 폭0.2, 잔상0.4s | [전](before/dwarf.gunner.shell_burst.png) · [후](after/dwarf.gunner.shell_burst.png) |
| 20. QUICKFIRE | 속사는 펄스보다 짧은 탄도 수명. `bullet`, 폭0.06, 잔상0.13s | [전](before/dwarf.gunner.quickfire.png) · [후](after/dwarf.gunner.quickfire.png) · [마지막](last-pulse/dwarf.gunner.quickfire.png) |
| 21. SHRAPNEL TOSS | 산개된 실제 서버 중심마다 파편 폭발. `blast`, 폭0.13, 잔상0.32s | [전](before/dwarf.gunner.shrapnel_toss.png) · [후](after/dwarf.gunner.shrapnel_toss.png) · [마지막](last-pulse/dwarf.gunner.shrapnel_toss.png) |
| 22. BLAST STEP | 후퇴 폭발은 전방 부채꼴만 표시. `blast`, 폭0.19, 잔상0.38s | [전](before/dwarf.gunner.blast_step.png) · [후](after/dwarf.gunner.blast_step.png) |
| 23. SCATTER SHOT | 산탄은 한 직선 대신5개 부채꼴 탄도. `fan`, 폭0.07, 잔상0.19s | [전](before/dwarf.gunner.scatter_shot.png) · [후](after/dwarf.gunner.scatter_shot.png) |
| 24. SKIPPING CHARGE | 두 번 튀는 폭탄의 실제 산개 중심 유지. `blast`, 폭0.17, 잔상0.36s | [전](before/dwarf.gunner.skipping_charge.png) · [후](after/dwarf.gunner.skipping_charge.png) · [마지막](last-pulse/dwarf.gunner.skipping_charge.png) |
| 25. FIELD MORTAR | 포격은4회 각각 낙하 흔적. `mortar`, 폭0.17, 잔상0.42s | [전](before/dwarf.gunner.field_mortar.png) · [후](after/dwarf.gunner.field_mortar.png) · [마지막](last-pulse/dwarf.gunner.field_mortar.png) |
| 26. PIERCING ROUND | 관통탄은 가는 심과 압력 후류로 구분. `bullet`, 폭0.09, 잔상0.22s | [전](before/dwarf.gunner.piercing_round.png) · [후](after/dwarf.gunner.piercing_round.png) |
| 27. ROLLING CHARGE | 굴림 폭탄 폭발 중심은 서버 확정 지점. `blast`, 폭0.2, 잔상0.44s | [전](before/dwarf.gunner.rolling_charge.png) · [후](after/dwarf.gunner.rolling_charge.png) |
| 28. SIEGE PATTERN | 두 포격의 개별 서버 위치 표시. `mortar`, 폭0.18, 잔상0.43s | [전](before/dwarf.gunner.siege_pattern.png) · [후](after/dwarf.gunner.siege_pattern.png) · [마지막](last-pulse/dwarf.gunner.siege_pattern.png) |
| 29. SIEGE BARRAGE | 궁극기4펄스도 이전 포격 잔상이 겹치지 않게 제한. `mortar`, 폭0.23, 잔상0.46s | [전](before/dwarf.gunner.siege_barrage.png) · [후](after/dwarf.gunner.siege_barrage.png) · [마지막](last-pulse/dwarf.gunner.siege_barrage.png) |
| 30. HOOKING CHOP | Hooking Chop은짧은 갈고리형 수직호. `cleave`, 폭0.24, 잔상0.3s | [전](before/dwarf_hooking_chop.png) · [후](after/dwarf_hooking_chop.png) |
| 31. LOW SWEEP | Low Sweep은발목 높이 전방110도 호. `low`, 폭0.22, 잔상0.36s | [전](before/dwarf_low_sweep.png) · [후](after/dwarf_low_sweep.png) |
| 32. BRACED THROW | Braced Throw는26stud 관통 후류. `axe`, 폭0.2, 잔상0.42s | [전](before/dwarf_braced_throw.png) · [후](after/dwarf_braced_throw.png) |
| 1. AIMED SHOT | Aimed Shot은 굵은 단일 정밀 후류. `arrow`, 폭0.15, 잔상0.38s | [전](before/elf.common.aimed.png) · [후](after/elf.common.aimed.png) |
| 2. RAPID FIRE | Rapid Fire는 각 발사가 겹치지 않는 짧은 후류. `arrow`, 폭0.07, 잔상0.16s | [전](before/elf.common.rapid.png) · [후](after/elf.common.rapid.png) · [마지막](last-pulse/elf.common.rapid.png) |
| 3. MULTI SHOT | Multi Shot은 실제70도 범위의5방향 화살. `fan`, 폭0.08, 잔상0.28s | [전](before/elf.common.multi.png) · [후](after/elf.common.multi.png) |
| 4. WEAKPOINT SHOT | 약점 사격은 단일 정밀 후류. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.marksman.weakpoint_shot.png) · [후](after/elf.marksman.weakpoint_shot.png) |
| 5. MOVING VOLLEY | 이동3연사는 짧은 개별 사격. `arrow`, 폭0.08, 잔상0.2s | [전](before/elf.marksman.moving_volley.png) · [후](after/elf.marksman.moving_volley.png) · [마지막](last-pulse/elf.marksman.moving_volley.png) |
| 6. PIERCING LINE | 관통 직선의 두 가는 압력선. `arrow`, 폭0.09, 잔상0.34s | [전](before/elf.marksman.piercing_line.png) · [후](after/elf.marksman.piercing_line.png) |
| 7. HEAVY DRAW | 강하게 당긴 화살은 두꺼운 단일 관통 심. `arrow`, 폭0.17, 잔상0.42s | [전](before/elf.marksman.heavy_draw.png) · [후](after/elf.marksman.heavy_draw.png) |
| 8. PRECISION VOLLEY | 약점 소비3연사는 이전 꼬리를 빨리 제거. `arrow`, 폭0.1, 잔상0.24s | [전](before/elf.marksman.precision_volley.png) · [후](after/elf.marksman.precision_volley.png) · [마지막](last-pulse/elf.marksman.precision_volley.png) |
| 9. FAN BREAK | Fan Break의 실제 부채꼴 범위를 화살로 표현. `fan`, 폭0.09, 잔상0.3s | [전](before/elf.marksman.fan_break.png) · [후](after/elf.marksman.fan_break.png) |
| 10. HUNTER'S FOCUS | 집중 사격의 이중 후류와 실제 보호 표시. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.hunter_s_focus.png) · [후](after/elf.marksman.hunter_s_focus.png) |
| 11. RETREATING FIRE | 후퇴 이동은 현재 발사점에서 시작. `arrow`, 폭0.12, 잔상0.32s | [전](before/elf.marksman.retreating_fire.png) · [후](after/elf.marksman.retreating_fire.png) |
| 12. PIERCING VOLLEY | 45stud 관통 부채를 한 줄로 축소하지 않음. `fan`, 폭0.11, 잔상0.36s | [전](before/elf.marksman.piercing_volley.png) · [후](after/elf.marksman.piercing_volley.png) |
| 13. MARK BREAKER | 표식 파쇄는 굵은 단일 화살 접점. `arrow`, 폭0.18, 잔상0.38s | [전](before/elf.marksman.mark_breaker.png) · [후](after/elf.marksman.mark_breaker.png) |
| 14. CROSSFIRE | Crossfire의2펄스 교차 방향을 서버 그대로 사용. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf.marksman.crossfire.png) · [후](after/elf.marksman.crossfire.png) · [마지막](last-pulse/elf.marksman.crossfire.png) |
| 15. ARROW RAIN | Arrow Rain은 실제 지정지점에만 낙하. `rain`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.arrow_rain.png) · [후](after/elf.marksman.arrow_rain.png) · [마지막](last-pulse/elf.marksman.arrow_rain.png) |
| 16. GRAND VOLLEY | Grand Volley는90도 부채꼴3회로 구분. `fan`, 폭0.12, 잔상0.3s | [전](before/elf.marksman.grand_volley.png) · [후](after/elf.marksman.grand_volley.png) · [마지막](last-pulse/elf.marksman.grand_volley.png) |
| 17. ELEMENTAL ARROW | 자연 화살의 가는 마력 나선. `arrow`, 폭0.13, 잔상0.35s | [전](before/elf.magic_archer.elemental_arrow.png) · [후](after/elf.magic_archer.elemental_arrow.png) |
| 18. SPARK VOLLEY | 번개 속성 화살은 전기 가지가 달린 개별3연사. `arrow`, 폭0.08, 잔상0.22s | [전](before/elf.magic_archer.spark_volley.png) · [후](after/elf.magic_archer.spark_volley.png) · [마지막](last-pulse/elf.magic_archer.spark_volley.png) |
| 19. VINE TRAP | Vine Trap은 지정지점을 감싸는 뿌리. `vine`, 폭0.12, 잔상0.44s | [전](before/elf.magic_archer.vine_trap.png) · [후](after/elf.magic_archer.vine_trap.png) · [마지막](last-pulse/elf.magic_archer.vine_trap.png) |
| 20. BLOOM SHOT | Bloom Shot은 명중점의 꽃잎형3갈래 접점. `arrow`, 폭0.12, 잔상0.38s | [전](before/elf.magic_archer.bloom_shot.png) · [후](after/elf.magic_archer.bloom_shot.png) |
| 21. STORM ARROW | Storm Arrow는 상공에서 지정지점으로 낙뢰. `lightning`, 폭0.14, 잔상0.28s | [전](before/elf.magic_archer.storm_arrow.png) · [후](after/elf.magic_archer.storm_arrow.png) |
| 22. ROOTING FAN | Rooting Fan은 시전자 앞 부채꼴 뿌리. `vine`, 폭0.11, 잔상0.4s | [전](before/elf.magic_archer.rooting_fan.png) · [후](after/elf.magic_archer.rooting_fan.png) |
| 23. WARDEN ARROW | Warden Arrow는 보호 효과와 화살 궤적 분리. `arrow`, 폭0.11, 잔상0.34s | [전](before/elf.magic_archer.warden_arrow.png) · [후](after/elf.magic_archer.warden_arrow.png) |
| 24. GLIDING SHOT | 전진 사격은 현재 발사점 기준. `arrow`, 폭0.12, 잔상0.3s | [전](before/elf.magic_archer.gliding_shot.png) · [후](after/elf.magic_archer.gliding_shot.png) |
| 25. SPIRIT RAIN | Spirit Rain은 자연 팔레트의 낙하 화살. `rain`, 폭0.13, 잔상0.3s | [전](before/elf.magic_archer.spirit_rain.png) · [후](after/elf.magic_archer.spirit_rain.png) · [마지막](last-pulse/elf.magic_archer.spirit_rain.png) |
| 26. ELEMENTAL PIERCE | Elemental Pierce는 좁은 직선 관통. `arrow`, 폭0.14, 잔상0.36s | [전](before/elf.magic_archer.elemental_pierce.png) · [후](after/elf.magic_archer.elemental_pierce.png) |
| 27. ECHO ARROWS | 3회 Echo는 각 펄스 나선 위상을 변경. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.magic_archer.echo_arrows.png) · [후](after/elf.magic_archer.echo_arrows.png) · [마지막](last-pulse/elf.magic_archer.echo_arrows.png) |
| 28. VINE BURST | Vine Burst는 지점 중심의 뿌리 폭발. `vine`, 폭0.16, 잔상0.5s | [전](before/elf.magic_archer.vine_burst.png) · [후](after/elf.magic_archer.vine_burst.png) |
| 29. SPIRIT ARROWFALL | 궁극기는3회 지정지점 화살비와 개별접점. `rain`, 폭0.16, 잔상0.46s | [전](before/elf.magic_archer.spirit_arrowfall.png) · [후](after/elf.magic_archer.spirit_arrowfall.png) · [마지막](last-pulse/elf.magic_archer.spirit_arrowfall.png) |
| 30. RETREATING SHOT | Retreating Shot은뒤로 이동해도 발사 방향 유지. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf_retreating_shot.png) · [후](after/elf_retreating_shot.png) |
| 31. PINNING SHOT | Pinning Shot은끝점의 짧은 고정 접점. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf_pinning_shot.png) · [후](after/elf_pinning_shot.png) |
| 32. ARROW SCREEN | Arrow Screen은반경4의 가까운 화살비. `rain`, 폭0.08, 잔상0.34s | [전](before/elf_arrow_screen.png) · [후](after/elf_arrow_screen.png) · [마지막](last-pulse/elf_arrow_screen.png) |
| 1. MANA BOLT | Mana Bolt는 비전색 쌍 나선. `arcane`, 폭0.12, 잔상0.34s | [전](before/mage.common.mana_bolt.png) · [후](after/mage.common.mana_bolt.png) |
| 2. WATER BALL | Water Ball의 구면 물보라와 젖음 접점. `water`, 폭0.16, 잔상0.42s | [전](before/mage.common.water_ball.png) · [후](after/mage.common.water_ball.png) |
| 3. GRAVITY | Gravity는 확정 영역 안쪽으로 당기는 나선. `gravity`, 폭0.14, 잔상0.56s | [전](before/mage.common.gravity.png) · [후](after/mage.common.gravity.png) |
| 4. EMBER LANCE | Ember Lance는 뾰족한 전방 불꽃 창. `fire`, 폭0.15, 잔상0.36s | [전](before/mage.pyro.ember_lance.png) · [후](after/mage.pyro.ember_lance.png) |
| 5. STEAM BURST | Steam Burst의 물색 증기를 위로 올림. `steam`, 폭0.17, 잔상0.48s | [전](before/mage.pyro.steam_burst.png) · [후](after/mage.pyro.steam_burst.png) |
| 6. CINDER RING | Cinder Ring은 시전자 중심의 빈 원형 화염. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.cinder_ring.png) · [후](after/mage.pyro.cinder_ring.png) · [마지막](last-pulse/mage.pyro.cinder_ring.png) |
| 7. FLAME DART | 짧은 시전 Flame Dart는 가늘고 짧게. `fire`, 폭0.13, 잔상0.24s | [전](before/mage.pyro.flame_dart.png) · [후](after/mage.pyro.flame_dart.png) |
| 8. EARTH RISE | Earth Rise는 지점 중심의 솟는 암석. `earth`, 폭0.18, 잔상0.48s | [전](before/mage.pyro.earth_rise.png) · [후](after/mage.pyro.earth_rise.png) |
| 9. EMBER STEP | Ember Step은 이동 후가 아닌 서버의 출발장판 중심. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.ember_step.png) · [후](after/mage.pyro.ember_step.png) |
| 10. STONE LANCE | Stone Lance는 바닥 균열 대신 공중 돌창. `stone`, 폭0.23, 잔상0.42s | [전](before/mage.pyro.stone_lance.png) · [후](after/mage.pyro.stone_lance.png) |
| 11. SEARING WARD | Searing Ward는 원형 열기와 보호 부여를 구분. `fire`, 폭0.15, 잔상0.42s | [전](before/mage.pyro.searing_ward.png) · [후](after/mage.pyro.searing_ward.png) |
| 12. LAVA ERUPTION | Lava Eruption은 반경14 내 방사형 용암 균열. `lava`, 폭0.24, 잔상0.6s | [전](before/mage.pyro.lava_eruption.png) · [후](after/mage.pyro.lava_eruption.png) |
| 13. MAGMA SPEAR | Magma Spear는3겹 고온 창 심. `fire`, 폭0.18, 잔상0.44s | [전](before/mage.pyro.magma_spear.png) · [후](after/mage.pyro.magma_spear.png) |
| 14. MOLTEN LINE | Molten Line은3펄스의 실제 직선 유지. `fire`, 폭0.14, 잔상0.34s | [전](before/mage.pyro.molten_line.png) · [후](after/mage.pyro.molten_line.png) · [마지막](last-pulse/mage.pyro.molten_line.png) |
| 15. ASHFALL | Ashfall은 나선 광선 대신 지면에 떨어지는 불씨. `ash`, 폭0.12, 잔상0.4s | [전](before/mage.pyro.ashfall.png) · [후](after/mage.pyro.ashfall.png) · [마지막](last-pulse/mage.pyro.ashfall.png) |
| 16. CALDERA'S JUDGMENT | Caldera 궁극기는반경20 지점의 용암과 분출. `lava`, 폭0.26, 잔상0.68s | [전](before/mage.pyro.caldera_s_judgment.png) · [후](after/mage.pyro.caldera_s_judgment.png) · [마지막](last-pulse/mage.pyro.caldera_s_judgment.png) |
| 17. FROST LANCE | Frost Lance는 좁고 뾰족한 얼음 창. `frost`, 폭0.17, 잔상0.38s | [전](before/mage.cryo.frost_lance.png) · [후](after/mage.cryo.frost_lance.png) |
| 18. ICE SHARD | Ice Shard는3갈래 짧은 결정 파편. `frost`, 폭0.12, 잔상0.34s | [전](before/mage.cryo.ice_shard.png) · [후](after/mage.cryo.ice_shard.png) |
| 19. FROST RING | Frost Ring은 시전자 중심360도 서리. `frost`, 폭0.13, 잔상0.46s | [전](before/mage.cryo.frost_ring.png) · [후](after/mage.cryo.frost_ring.png) |
| 20. SHATTER DART | 표식 파쇄 얼음은 짧은 쌍 결정. `frost`, 폭0.16, 잔상0.32s | [전](before/mage.cryo.shatter_dart.png) · [후](after/mage.cryo.shatter_dart.png) |
| 21. CHAIN LIGHTNING | Chain Lightning은 확정된 적 사이만 연결. `lightning`, 폭0.12, 잔상0.2s | [전](before/mage.cryo.chain_lightning.png) · [후](after/mage.cryo.chain_lightning.png) |
| 22. FROST STEP | Frost Step은 서버 출발 중심의 서리. `frost`, 폭0.12, 잔상0.4s | [전](before/mage.cryo.frost_step.png) · [후](after/mage.cryo.frost_step.png) |
| 23. THUNDER SPEAR | Thunder Spear는 한 전방축의 전기 창. `lightning`, 폭0.19, 잔상0.26s | [전](before/mage.cryo.thunder_spear.png) · [후](after/mage.cryo.thunder_spear.png) |
| 24. ICE WARD | Ice Ward의 냉기와 보호 부여를 분리. `frost`, 폭0.14, 잔상0.44s | [전](before/mage.cryo.ice_ward.png) · [후](after/mage.cryo.ice_ward.png) |
| 25. FROSTSTORM | Froststorm은 지정지점 반경14의 서리 폭풍. `frost`, 폭0.18, 잔상0.56s | [전](before/mage.cryo.froststorm.png) · [후](after/mage.cryo.froststorm.png) |
| 26. GLACIAL SPIKE | Glacial Spike는 큰 단일 결정창. `frost`, 폭0.26, 잔상0.46s | [전](before/mage.cryo.glacial_spike.png) · [후](after/mage.cryo.glacial_spike.png) |
| 27. LIGHTNING LINE | Lightning Line은 직선 축 주위 전기 가지. `lightning`, 폭0.14, 잔상0.24s | [전](before/mage.cryo.lightning_line.png) · [후](after/mage.cryo.lightning_line.png) |
| 28. HAILFALL | Hailfall은 바닥 파편 대신 상공 낙하 결정. `hail`, 폭0.13, 잔상0.4s | [전](before/mage.cryo.hailfall.png) · [후](after/mage.cryo.hailfall.png) · [마지막](last-pulse/mage.cryo.hailfall.png) |
| 29. ETERNAL TEMPEST | Eternal Tempest는20반경 지점의 빈 중심 서리 인장. `frost`, 폭0.22, 잔상0.64s | [전](before/mage.cryo.eternal_tempest.png) · [후](after/mage.cryo.eternal_tempest.png) · [마지막](last-pulse/mage.cryo.eternal_tempest.png) |
| 30. WIND LANCE | Wind Lance의전용 공기리본을중복하지않음. 별도 공기 리본 유지 | [전](before/mage_wind_lance.png) · [후](after/mage_wind_lance.png) |
| 31. TIDAL RING | Tidal Ring은시전자중심5stud 물결. `water`, 폭0.19, 잔상0.46s | [전](before/mage_tidal_ring.png) · [후](after/mage_tidal_ring.png) |
| 32. ARCANE WARD | Arcane Ward는시전점중심 보호리본. `ward`, 폭0.12, 잔상0.56s | [전](before/mage_arcane_ward.png) · [후](after/mage_arcane_ward.png) |

## mage

| 순서·스킬 | 개별 검토·조치 | 전 / 후 / 반복 마지막 |
| --- | --- | --- |
| 1. SHIELD BASH | Shield Bash는 방패 진행축에 수직인 접점. `guard`, 폭0.24, 잔상0.32s | [전](before/knight.common.bash.png) · [후](after/knight.common.bash.png) |
| 2. WHIRLWIND | Whirlwind의360도 검 궤적. `spin`, 폭0.21, 잔상0.38s | [전](before/knight.common.whirlwind.png) · [후](after/knight.common.whirlwind.png) |
| 3. PROVOKE | 도발은 피해광선 대신 발밑 함성 파문. `warcry`, 폭0.14, 잔상0.48s | [전](before/knight.common.provoke.png) · [후](after/knight.common.provoke.png) |
| 4. COUNTER SLASH | 반격의 짧은 칼날과 방어 호를 분리. `counter`, 폭0.19, 잔상0.42s | [전](before/knight.steel_knight.counter_slash.png) · [후](after/knight.steel_knight.counter_slash.png) |
| 5. STEEL SWEEP | 전방 부채꼴 끝을 잇는 낮은 강철 초승달. `crescent`, 폭0.25, 잔상0.4s | [전](before/knight.steel_knight.steel_sweep.png) · [후](after/knight.steel_knight.steel_sweep.png) |
| 6. CHALLENGING STRIKE | 도발 공격을 한 번의 검격과 발밑 압력으로 구분. `slash`, 폭0.22, 잔상0.42s | [전](before/knight.steel_knight.challenging_strike.png) · [후](after/knight.steel_knight.challenging_strike.png) |
| 7. TWIN CYCLONE | 두 펄스의 회전 위상을 바꿔 Twin Cyclone의 박자 표시. `spin`, 폭0.21, 잔상0.34s | [전](before/knight.steel_knight.twin_cyclone.png) · [후](after/knight.steel_knight.twin_cyclone.png) · [마지막](last-pulse/knight.steel_knight.twin_cyclone.png) |
| 8. SHIELD BREAKER | 한 대상 방패 파쇄의 전방 수직 면과 접점 집중. `guard`, 폭0.26, 잔상0.34s | [전](before/knight.steel_knight.shield_breaker.png) · [후](after/knight.steel_knight.shield_breaker.png) |
| 9. GUARDIAN COUNTER | 반격 궤적 뒤에 아군 보호와 구분되는 개인 방어 호. `counter`, 폭0.16, 잔상0.46s | [전](before/knight.steel_knight.guardian_counter.png) · [후](after/knight.steel_knight.guardian_counter.png) |
| 10. RALLYING SLASH | 넓은 선동 베기의 두 겹 전방 호. `areslash`, 폭0.18, 잔상0.44s | [전](before/knight.steel_knight.rallying_slash.png) · [후](after/knight.steel_knight.rallying_slash.png) |
| 11. BREAKER CHARGE | 돌진 두 펄스마다 진행축에 수직인 방패 파동. `guard`, 폭0.21, 잔상0.3s | [전](before/knight.steel_knight.breaker_charge.png) · [후](after/knight.steel_knight.breaker_charge.png) · [마지막](last-pulse/knight.steel_knight.breaker_charge.png) |
| 12. VANGUARD STRIKE | 일반 검광 대신 좁은 전방 찌르기. `thrust`, 폭0.16, 잔상0.36s | [전](before/knight.steel_knight.vanguard_strike.png) · [후](after/knight.steel_knight.vanguard_strike.png) |
| 13. BLADE STORM | 4회 박자마다 회전 위상 변경과 짧은 잔상. `spin`, 폭0.16, 잔상0.28s | [전](before/knight.steel_knight.blade_storm.png) · [후](after/knight.steel_knight.blade_storm.png) · [마지막](last-pulse/knight.steel_knight.blade_storm.png) |
| 14. SWEEPING BREAK | 전방 베기와 구별되는 바닥360도 파쇄 호. `crescent`, 폭0.25, 잔상0.46s | [전](before/knight.steel_knight.sweeping_break.png) · [후](after/knight.steel_knight.sweeping_break.png) |
| 15. WARCRY ASSAULT | 3회 함성 공격의 전방 압력 파문. `warcry`, 폭0.16, 잔상0.32s | [전](before/knight.steel_knight.warcry_assault.png) · [후](after/knight.steel_knight.warcry_assault.png) · [마지막](last-pulse/knight.steel_knight.warcry_assault.png) |
| 16. UNYIELDING FRONT | 궁극기의 원형 방어진과 전진 방패를 함께 표현. `guard`, 폭0.24, 잔상0.55s | [전](before/knight.steel_knight.unyielding_front.png) · [후](after/knight.steel_knight.unyielding_front.png) · [마지막](last-pulse/knight.steel_knight.unyielding_front.png) |
| 17. OATHBLADE | 맹세의 두 검격은 펄스별 좌우 반전. `slash`, 폭0.18, 잔상0.38s | [전](before/knight.paladin.oathblade.png) · [후](after/knight.paladin.oathblade.png) · [마지막](last-pulse/knight.paladin.oathblade.png) |
| 18. RADIANT SWEEP | 금빛 전방 호와 표식 접점을 짧게 유지. `crescent`, 폭0.28, 잔상0.45s | [전](before/knight.paladin.radiant_sweep.png) · [후](after/knight.paladin.radiant_sweep.png) |
| 19. OATH CHALLENGE | 맹세 소비는 전방 성광 압력으로 구분. `warcry`, 폭0.18, 잔상0.44s | [전](before/knight.paladin.oath_challenge.png) · [후](after/knight.paladin.oath_challenge.png) |
| 20. DAWN BURST | Dawn Burst는 시전자 중심 방사형 성광. `holy`, 폭0.18, 잔상0.5s | [전](before/knight.paladin.dawn_burst.png) · [후](after/knight.paladin.dawn_burst.png) |
| 21. OATHBREAKER STRIKE | 검격을 수직 내려찍기 실루엣으로 변경. `cleave`, 폭0.32, 잔상0.4s | [전](before/knight.paladin.oathbreaker_strike.png) · [후](after/knight.paladin.oathbreaker_strike.png) |
| 22. SHIELD VERDICT | Shield Verdict는 좁고 강한 방패 전면. `guard`, 폭0.3, 잔상0.38s | [전](before/knight.paladin.shield_verdict.png) · [후](after/knight.paladin.shield_verdict.png) |
| 23. GUARDIAN SLASH | 보호가 붙은 전방 검격의 칼날 호 분리. `crescent`, 폭0.21, 잔상0.43s | [전](before/knight.paladin.guardian_slash.png) · [후](after/knight.paladin.guardian_slash.png) |
| 24. RADIANT CHARGE | 성광 돌진은 전진축 방패 면을 유지. `guard`, 폭0.2, 잔상0.32s | [전](before/knight.paladin.radiant_charge.png) · [후](after/knight.paladin.radiant_charge.png) · [마지막](last-pulse/knight.paladin.radiant_charge.png) |
| 25. VALIANT ADVANCE | 다대상 전진을 넓고 얇은 방패 압력으로 구분. `guard`, 폭0.16, 잔상0.42s | [전](before/knight.paladin.valiant_advance.png) · [후](after/knight.paladin.valiant_advance.png) |
| 26. DAWN SPIRAL | 반복 나선은 펄스별 위상 변경. `holy`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.dawn_spiral.png) · [후](after/knight.paladin.dawn_spiral.png) · [마지막](last-pulse/knight.paladin.dawn_spiral.png) |
| 27. SUNWARD CROSS | Sunward Cross는 실제 교차하는 두 검광. `cross`, 폭0.23, 잔상0.38s | [전](before/knight.paladin.sunward_cross.png) · [후](after/knight.paladin.sunward_cross.png) · [마지막](last-pulse/knight.paladin.sunward_cross.png) |
| 28. OATHBOUND ASSAULT | 세 번 맹세 공격의 교대 검격. `slash`, 폭0.17, 잔상0.3s | [전](before/knight.paladin.oathbound_assault.png) · [후](after/knight.paladin.oathbound_assault.png) · [마지막](last-pulse/knight.paladin.oathbound_assault.png) |
| 29. OATH OF DAWN | 맹세 궁극기는 중앙이 빈 방사형 성광 인장. `holy`, 폭0.23, 잔상0.7s | [전](before/knight.paladin.oath_of_dawn.png) · [후](after/knight.paladin.oath_of_dawn.png) · [마지막](last-pulse/knight.paladin.oath_of_dawn.png) |
| 30. DRIVING THRUST | Driving Thrust는좁은6stud 찌르기. `thrust`, 폭0.19, 잔상0.32s | [전](before/knight_driving_thrust.png) · [후](after/knight_driving_thrust.png) |
| 31. CRESCENT CUT | Crescent Cut은전방110도 단일호. `crescent`, 폭0.25, 잔상0.38s | [전](before/knight_crescent_cut.png) · [후](after/knight_crescent_cut.png) |
| 32. GUARDED STRIKE | Guarded Strike는단일 방패 접점과 방어호. `guard`, 폭0.19, 잔상0.34s | [전](before/knight_guarded_strike.png) · [후](after/knight_guarded_strike.png) |
| 1. OVERHEAD SMASH | Overhead Smash의 수직 궤적과 접점. `cleave`, 폭0.32, 잔상0.42s | [전](before/dwarf.common.overhead.png) · [후](after/dwarf.common.overhead.png) |
| 2. AXE THROW | 실제 도끼 투척의 회전 후류. `axe`, 폭0.14, 잔상0.38s | [전](before/dwarf.common.throw.png) · [후](after/dwarf.common.throw.png) |
| 3. GROUND SLAM | Ground Slam은 시전자 바닥 중심360도. `earth`, 폭0.18, 잔상0.48s | [전](before/dwarf.common.ground.png) · [후](after/dwarf.common.ground.png) |
| 4. ARMOR SPLITTER | 갑옷 파쇄는 도끼날의 수직 호. `cleave`, 폭0.32, 잔상0.38s | [전](before/dwarf.iron_axe.armor_splitter.png) · [후](after/dwarf.iron_axe.armor_splitter.png) |
| 5. RETURNING ECHO | 2펄스 복귀 방향을 실제로 반전. `axe`, 폭0.14, 잔상0.4s | [전](before/dwarf.iron_axe.returning_echo.png) · [후](after/dwarf.iron_axe.returning_echo.png) · [마지막](last-pulse/dwarf.iron_axe.returning_echo.png) |
| 6. MOUNTAIN SWEEP | Mountain Sweep은360도 원형 균열. `earth`, 폭0.16, 잔상0.46s | [전](before/dwarf.iron_axe.mountain_sweep.png) · [후](after/dwarf.iron_axe.mountain_sweep.png) |
| 7. CRAG CLEAVE | 전방 다대상 내려찍기를 쌍 수직 호로 표현. `cleave`, 폭0.25, 잔상0.42s | [전](before/dwarf.iron_axe.crag_cleave.png) · [후](after/dwarf.iron_axe.crag_cleave.png) |
| 8. BREAKER THROW | 강한 관통 투척을 긴 단일 도끼 후류로 구분. `axe`, 폭0.22, 잔상0.42s | [전](before/dwarf.iron_axe.breaker_throw.png) · [후](after/dwarf.iron_axe.breaker_throw.png) |
| 9. STONEBOUND LEAP | 착지 위치 중심으로 바깥 방향 파편. `earth`, 폭0.19, 잔상0.48s | [전](before/dwarf.iron_axe.stonebound_leap.png) · [후](after/dwarf.iron_axe.stonebound_leap.png) |
| 10. IRON SHOULDER | 어깨 밀기는 도끼 마법이 아닌 전방 충격. `guard`, 폭0.23, 잔상0.34s | [전](before/dwarf.iron_axe.iron_shoulder.png) · [후](after/dwarf.iron_axe.iron_shoulder.png) |
| 11. CROSSCUT AXE | 복귀/교차cut은 서버가 보낸 펄스 끝점을 유지. `axe`, 폭0.15, 잔상0.36s | [전](before/dwarf.iron_axe.crosscut_axe.png) · [후](after/dwarf.iron_axe.crosscut_axe.png) · [마지막](last-pulse/dwarf.iron_axe.crosscut_axe.png) |
| 12. MOUNTAIN STRIKE | 전방120도 이내로만 산맥 균열 전개. `earth`, 폭0.23, 잔상0.48s | [전](before/dwarf.iron_axe.mountain_strike.png) · [후](after/dwarf.iron_axe.mountain_strike.png) |
| 13. SHATTER BLOW | 지정 지점의 반경4 파쇄로 장거리 균열 방지. `earth`, 폭0.18, 잔상0.52s | [전](before/dwarf.iron_axe.shatter_blow.png) · [후](after/dwarf.iron_axe.shatter_blow.png) |
| 14. TWIN AXE PATH | 두 투척 펄스의 궤적과 회전 위상 구분. `axe`, 폭0.14, 잔상0.3s | [전](before/dwarf.iron_axe.twin_axe_path.png) · [후](after/dwarf.iron_axe.twin_axe_path.png) · [마지막](last-pulse/dwarf.iron_axe.twin_axe_path.png) |
| 15. TREMOR GUARD | 보호 부여는 낮은 바닥 진동 고리로 유지. `earth`, 폭0.14, 잔상0.48s | [전](before/dwarf.iron_axe.tremor_guard.png) · [후](after/dwarf.iron_axe.tremor_guard.png) |
| 16. MOUNTAIN COLLAPSE | 산맥 궁극기는 원형이 아닌 전방120도 대형 균열. `earth`, 폭0.25, 잔상0.66s | [전](before/dwarf.iron_axe.mountain_collapse.png) · [후](after/dwarf.iron_axe.mountain_collapse.png) · [마지막](last-pulse/dwarf.iron_axe.mountain_collapse.png) |
| 17. GUNNER SHOT | 한 발 총격의 짧은 총구와 얇은 탄도. `bullet`, 폭0.08, 잔상0.18s | [전](before/dwarf.gunner.gunner_shot.png) · [후](after/dwarf.gunner.gunner_shot.png) |
| 18. BOMB TOSS | 수류탄은 지정지점의 바깥 폭발과 파편. `blast`, 폭0.18, 잔상0.44s | [전](before/dwarf.gunner.bomb_toss.png) · [후](after/dwarf.gunner.bomb_toss.png) |
| 19. SHELL BURST | 포탄은 상공 낙하축과 접지 폭발. `mortar`, 폭0.2, 잔상0.4s | [전](before/dwarf.gunner.shell_burst.png) · [후](after/dwarf.gunner.shell_burst.png) |
| 20. QUICKFIRE | 속사는 펄스보다 짧은 탄도 수명. `bullet`, 폭0.06, 잔상0.13s | [전](before/dwarf.gunner.quickfire.png) · [후](after/dwarf.gunner.quickfire.png) · [마지막](last-pulse/dwarf.gunner.quickfire.png) |
| 21. SHRAPNEL TOSS | 산개된 실제 서버 중심마다 파편 폭발. `blast`, 폭0.13, 잔상0.32s | [전](before/dwarf.gunner.shrapnel_toss.png) · [후](after/dwarf.gunner.shrapnel_toss.png) · [마지막](last-pulse/dwarf.gunner.shrapnel_toss.png) |
| 22. BLAST STEP | 후퇴 폭발은 전방 부채꼴만 표시. `blast`, 폭0.19, 잔상0.38s | [전](before/dwarf.gunner.blast_step.png) · [후](after/dwarf.gunner.blast_step.png) |
| 23. SCATTER SHOT | 산탄은 한 직선 대신5개 부채꼴 탄도. `fan`, 폭0.07, 잔상0.19s | [전](before/dwarf.gunner.scatter_shot.png) · [후](after/dwarf.gunner.scatter_shot.png) |
| 24. SKIPPING CHARGE | 두 번 튀는 폭탄의 실제 산개 중심 유지. `blast`, 폭0.17, 잔상0.36s | [전](before/dwarf.gunner.skipping_charge.png) · [후](after/dwarf.gunner.skipping_charge.png) · [마지막](last-pulse/dwarf.gunner.skipping_charge.png) |
| 25. FIELD MORTAR | 포격은4회 각각 낙하 흔적. `mortar`, 폭0.17, 잔상0.42s | [전](before/dwarf.gunner.field_mortar.png) · [후](after/dwarf.gunner.field_mortar.png) · [마지막](last-pulse/dwarf.gunner.field_mortar.png) |
| 26. PIERCING ROUND | 관통탄은 가는 심과 압력 후류로 구분. `bullet`, 폭0.09, 잔상0.22s | [전](before/dwarf.gunner.piercing_round.png) · [후](after/dwarf.gunner.piercing_round.png) |
| 27. ROLLING CHARGE | 굴림 폭탄 폭발 중심은 서버 확정 지점. `blast`, 폭0.2, 잔상0.44s | [전](before/dwarf.gunner.rolling_charge.png) · [후](after/dwarf.gunner.rolling_charge.png) |
| 28. SIEGE PATTERN | 두 포격의 개별 서버 위치 표시. `mortar`, 폭0.18, 잔상0.43s | [전](before/dwarf.gunner.siege_pattern.png) · [후](after/dwarf.gunner.siege_pattern.png) · [마지막](last-pulse/dwarf.gunner.siege_pattern.png) |
| 29. SIEGE BARRAGE | 궁극기4펄스도 이전 포격 잔상이 겹치지 않게 제한. `mortar`, 폭0.23, 잔상0.46s | [전](before/dwarf.gunner.siege_barrage.png) · [후](after/dwarf.gunner.siege_barrage.png) · [마지막](last-pulse/dwarf.gunner.siege_barrage.png) |
| 30. HOOKING CHOP | Hooking Chop은짧은 갈고리형 수직호. `cleave`, 폭0.24, 잔상0.3s | [전](before/dwarf_hooking_chop.png) · [후](after/dwarf_hooking_chop.png) |
| 31. LOW SWEEP | Low Sweep은발목 높이 전방110도 호. `low`, 폭0.22, 잔상0.36s | [전](before/dwarf_low_sweep.png) · [후](after/dwarf_low_sweep.png) |
| 32. BRACED THROW | Braced Throw는26stud 관통 후류. `axe`, 폭0.2, 잔상0.42s | [전](before/dwarf_braced_throw.png) · [후](after/dwarf_braced_throw.png) |
| 1. AIMED SHOT | Aimed Shot은 굵은 단일 정밀 후류. `arrow`, 폭0.15, 잔상0.38s | [전](before/elf.common.aimed.png) · [후](after/elf.common.aimed.png) |
| 2. RAPID FIRE | Rapid Fire는 각 발사가 겹치지 않는 짧은 후류. `arrow`, 폭0.07, 잔상0.16s | [전](before/elf.common.rapid.png) · [후](after/elf.common.rapid.png) · [마지막](last-pulse/elf.common.rapid.png) |
| 3. MULTI SHOT | Multi Shot은 실제70도 범위의5방향 화살. `fan`, 폭0.08, 잔상0.28s | [전](before/elf.common.multi.png) · [후](after/elf.common.multi.png) |
| 4. WEAKPOINT SHOT | 약점 사격은 단일 정밀 후류. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.marksman.weakpoint_shot.png) · [후](after/elf.marksman.weakpoint_shot.png) |
| 5. MOVING VOLLEY | 이동3연사는 짧은 개별 사격. `arrow`, 폭0.08, 잔상0.2s | [전](before/elf.marksman.moving_volley.png) · [후](after/elf.marksman.moving_volley.png) · [마지막](last-pulse/elf.marksman.moving_volley.png) |
| 6. PIERCING LINE | 관통 직선의 두 가는 압력선. `arrow`, 폭0.09, 잔상0.34s | [전](before/elf.marksman.piercing_line.png) · [후](after/elf.marksman.piercing_line.png) |
| 7. HEAVY DRAW | 강하게 당긴 화살은 두꺼운 단일 관통 심. `arrow`, 폭0.17, 잔상0.42s | [전](before/elf.marksman.heavy_draw.png) · [후](after/elf.marksman.heavy_draw.png) |
| 8. PRECISION VOLLEY | 약점 소비3연사는 이전 꼬리를 빨리 제거. `arrow`, 폭0.1, 잔상0.24s | [전](before/elf.marksman.precision_volley.png) · [후](after/elf.marksman.precision_volley.png) · [마지막](last-pulse/elf.marksman.precision_volley.png) |
| 9. FAN BREAK | Fan Break의 실제 부채꼴 범위를 화살로 표현. `fan`, 폭0.09, 잔상0.3s | [전](before/elf.marksman.fan_break.png) · [후](after/elf.marksman.fan_break.png) |
| 10. HUNTER'S FOCUS | 집중 사격의 이중 후류와 실제 보호 표시. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.hunter_s_focus.png) · [후](after/elf.marksman.hunter_s_focus.png) |
| 11. RETREATING FIRE | 후퇴 이동은 현재 발사점에서 시작. `arrow`, 폭0.12, 잔상0.32s | [전](before/elf.marksman.retreating_fire.png) · [후](after/elf.marksman.retreating_fire.png) |
| 12. PIERCING VOLLEY | 45stud 관통 부채를 한 줄로 축소하지 않음. `fan`, 폭0.11, 잔상0.36s | [전](before/elf.marksman.piercing_volley.png) · [후](after/elf.marksman.piercing_volley.png) |
| 13. MARK BREAKER | 표식 파쇄는 굵은 단일 화살 접점. `arrow`, 폭0.18, 잔상0.38s | [전](before/elf.marksman.mark_breaker.png) · [후](after/elf.marksman.mark_breaker.png) |
| 14. CROSSFIRE | Crossfire의2펄스 교차 방향을 서버 그대로 사용. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf.marksman.crossfire.png) · [후](after/elf.marksman.crossfire.png) · [마지막](last-pulse/elf.marksman.crossfire.png) |
| 15. ARROW RAIN | Arrow Rain은 실제 지정지점에만 낙하. `rain`, 폭0.1, 잔상0.34s | [전](before/elf.marksman.arrow_rain.png) · [후](after/elf.marksman.arrow_rain.png) · [마지막](last-pulse/elf.marksman.arrow_rain.png) |
| 16. GRAND VOLLEY | Grand Volley는90도 부채꼴3회로 구분. `fan`, 폭0.12, 잔상0.3s | [전](before/elf.marksman.grand_volley.png) · [후](after/elf.marksman.grand_volley.png) · [마지막](last-pulse/elf.marksman.grand_volley.png) |
| 17. ELEMENTAL ARROW | 자연 화살의 가는 마력 나선. `arrow`, 폭0.13, 잔상0.35s | [전](before/elf.magic_archer.elemental_arrow.png) · [후](after/elf.magic_archer.elemental_arrow.png) |
| 18. SPARK VOLLEY | 번개 속성 화살은 전기 가지가 달린 개별3연사. `arrow`, 폭0.08, 잔상0.22s | [전](before/elf.magic_archer.spark_volley.png) · [후](after/elf.magic_archer.spark_volley.png) · [마지막](last-pulse/elf.magic_archer.spark_volley.png) |
| 19. VINE TRAP | Vine Trap은 지정지점을 감싸는 뿌리. `vine`, 폭0.12, 잔상0.44s | [전](before/elf.magic_archer.vine_trap.png) · [후](after/elf.magic_archer.vine_trap.png) · [마지막](last-pulse/elf.magic_archer.vine_trap.png) |
| 20. BLOOM SHOT | Bloom Shot은 명중점의 꽃잎형3갈래 접점. `arrow`, 폭0.12, 잔상0.38s | [전](before/elf.magic_archer.bloom_shot.png) · [후](after/elf.magic_archer.bloom_shot.png) |
| 21. STORM ARROW | Storm Arrow는 상공에서 지정지점으로 낙뢰. `lightning`, 폭0.14, 잔상0.28s | [전](before/elf.magic_archer.storm_arrow.png) · [후](after/elf.magic_archer.storm_arrow.png) |
| 22. ROOTING FAN | Rooting Fan은 시전자 앞 부채꼴 뿌리. `vine`, 폭0.11, 잔상0.4s | [전](before/elf.magic_archer.rooting_fan.png) · [후](after/elf.magic_archer.rooting_fan.png) |
| 23. WARDEN ARROW | Warden Arrow는 보호 효과와 화살 궤적 분리. `arrow`, 폭0.11, 잔상0.34s | [전](before/elf.magic_archer.warden_arrow.png) · [후](after/elf.magic_archer.warden_arrow.png) |
| 24. GLIDING SHOT | 전진 사격은 현재 발사점 기준. `arrow`, 폭0.12, 잔상0.3s | [전](before/elf.magic_archer.gliding_shot.png) · [후](after/elf.magic_archer.gliding_shot.png) |
| 25. SPIRIT RAIN | Spirit Rain은 자연 팔레트의 낙하 화살. `rain`, 폭0.13, 잔상0.3s | [전](before/elf.magic_archer.spirit_rain.png) · [후](after/elf.magic_archer.spirit_rain.png) · [마지막](last-pulse/elf.magic_archer.spirit_rain.png) |
| 26. ELEMENTAL PIERCE | Elemental Pierce는 좁은 직선 관통. `arrow`, 폭0.14, 잔상0.36s | [전](before/elf.magic_archer.elemental_pierce.png) · [후](after/elf.magic_archer.elemental_pierce.png) |
| 27. ECHO ARROWS | 3회 Echo는 각 펄스 나선 위상을 변경. `arrow`, 폭0.11, 잔상0.32s | [전](before/elf.magic_archer.echo_arrows.png) · [후](after/elf.magic_archer.echo_arrows.png) · [마지막](last-pulse/elf.magic_archer.echo_arrows.png) |
| 28. VINE BURST | Vine Burst는 지점 중심의 뿌리 폭발. `vine`, 폭0.16, 잔상0.5s | [전](before/elf.magic_archer.vine_burst.png) · [후](after/elf.magic_archer.vine_burst.png) |
| 29. SPIRIT ARROWFALL | 궁극기는3회 지정지점 화살비와 개별접점. `rain`, 폭0.16, 잔상0.46s | [전](before/elf.magic_archer.spirit_arrowfall.png) · [후](after/elf.magic_archer.spirit_arrowfall.png) · [마지막](last-pulse/elf.magic_archer.spirit_arrowfall.png) |
| 30. RETREATING SHOT | Retreating Shot은뒤로 이동해도 발사 방향 유지. `arrow`, 폭0.1, 잔상0.3s | [전](before/elf_retreating_shot.png) · [후](after/elf_retreating_shot.png) |
| 31. PINNING SHOT | Pinning Shot은끝점의 짧은 고정 접점. `arrow`, 폭0.1, 잔상0.34s | [전](before/elf_pinning_shot.png) · [후](after/elf_pinning_shot.png) |
| 32. ARROW SCREEN | Arrow Screen은반경4의 가까운 화살비. `rain`, 폭0.08, 잔상0.34s | [전](before/elf_arrow_screen.png) · [후](after/elf_arrow_screen.png) · [마지막](last-pulse/elf_arrow_screen.png) |
| 1. MANA BOLT | Mana Bolt는 비전색 쌍 나선. `arcane`, 폭0.12, 잔상0.34s | [전](before/mage.common.mana_bolt.png) · [후](after/mage.common.mana_bolt.png) |
| 2. WATER BALL | Water Ball의 구면 물보라와 젖음 접점. `water`, 폭0.16, 잔상0.42s | [전](before/mage.common.water_ball.png) · [후](after/mage.common.water_ball.png) |
| 3. GRAVITY | Gravity는 확정 영역 안쪽으로 당기는 나선. `gravity`, 폭0.14, 잔상0.56s | [전](before/mage.common.gravity.png) · [후](after/mage.common.gravity.png) |
| 4. EMBER LANCE | Ember Lance는 뾰족한 전방 불꽃 창. `fire`, 폭0.15, 잔상0.36s | [전](before/mage.pyro.ember_lance.png) · [후](after/mage.pyro.ember_lance.png) |
| 5. STEAM BURST | Steam Burst의 물색 증기를 위로 올림. `steam`, 폭0.17, 잔상0.48s | [전](before/mage.pyro.steam_burst.png) · [후](after/mage.pyro.steam_burst.png) |
| 6. CINDER RING | Cinder Ring은 시전자 중심의 빈 원형 화염. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.cinder_ring.png) · [후](after/mage.pyro.cinder_ring.png) · [마지막](last-pulse/mage.pyro.cinder_ring.png) |
| 7. FLAME DART | 짧은 시전 Flame Dart는 가늘고 짧게. `fire`, 폭0.13, 잔상0.24s | [전](before/mage.pyro.flame_dart.png) · [후](after/mage.pyro.flame_dart.png) |
| 8. EARTH RISE | Earth Rise는 지점 중심의 솟는 암석. `earth`, 폭0.18, 잔상0.48s | [전](before/mage.pyro.earth_rise.png) · [후](after/mage.pyro.earth_rise.png) |
| 9. EMBER STEP | Ember Step은 이동 후가 아닌 서버의 출발장판 중심. `fire`, 폭0.16, 잔상0.38s | [전](before/mage.pyro.ember_step.png) · [후](after/mage.pyro.ember_step.png) |
| 10. STONE LANCE | Stone Lance는 바닥 균열 대신 공중 돌창. `stone`, 폭0.23, 잔상0.42s | [전](before/mage.pyro.stone_lance.png) · [후](after/mage.pyro.stone_lance.png) |
| 11. SEARING WARD | Searing Ward는 원형 열기와 보호 부여를 구분. `fire`, 폭0.15, 잔상0.42s | [전](before/mage.pyro.searing_ward.png) · [후](after/mage.pyro.searing_ward.png) |
| 12. LAVA ERUPTION | Lava Eruption은 반경14 내 방사형 용암 균열. `lava`, 폭0.24, 잔상0.6s | [전](before/mage.pyro.lava_eruption.png) · [후](after/mage.pyro.lava_eruption.png) |
| 13. MAGMA SPEAR | Magma Spear는3겹 고온 창 심. `fire`, 폭0.18, 잔상0.44s | [전](before/mage.pyro.magma_spear.png) · [후](after/mage.pyro.magma_spear.png) |
| 14. MOLTEN LINE | Molten Line은3펄스의 실제 직선 유지. `fire`, 폭0.14, 잔상0.34s | [전](before/mage.pyro.molten_line.png) · [후](after/mage.pyro.molten_line.png) · [마지막](last-pulse/mage.pyro.molten_line.png) |
| 15. ASHFALL | Ashfall은 나선 광선 대신 지면에 떨어지는 불씨. `ash`, 폭0.12, 잔상0.4s | [전](before/mage.pyro.ashfall.png) · [후](after/mage.pyro.ashfall.png) · [마지막](last-pulse/mage.pyro.ashfall.png) |
| 16. CALDERA'S JUDGMENT | Caldera 궁극기는반경20 지점의 용암과 분출. `lava`, 폭0.26, 잔상0.68s | [전](before/mage.pyro.caldera_s_judgment.png) · [후](after/mage.pyro.caldera_s_judgment.png) · [마지막](last-pulse/mage.pyro.caldera_s_judgment.png) |
| 17. FROST LANCE | Frost Lance는 좁고 뾰족한 얼음 창. `frost`, 폭0.17, 잔상0.38s | [전](before/mage.cryo.frost_lance.png) · [후](after/mage.cryo.frost_lance.png) |
| 18. ICE SHARD | Ice Shard는3갈래 짧은 결정 파편. `frost`, 폭0.12, 잔상0.34s | [전](before/mage.cryo.ice_shard.png) · [후](after/mage.cryo.ice_shard.png) |
| 19. FROST RING | Frost Ring은 시전자 중심360도 서리. `frost`, 폭0.13, 잔상0.46s | [전](before/mage.cryo.frost_ring.png) · [후](after/mage.cryo.frost_ring.png) |
| 20. SHATTER DART | 표식 파쇄 얼음은 짧은 쌍 결정. `frost`, 폭0.16, 잔상0.32s | [전](before/mage.cryo.shatter_dart.png) · [후](after/mage.cryo.shatter_dart.png) |
| 21. CHAIN LIGHTNING | Chain Lightning은 확정된 적 사이만 연결. `lightning`, 폭0.12, 잔상0.2s | [전](before/mage.cryo.chain_lightning.png) · [후](after/mage.cryo.chain_lightning.png) |
| 22. FROST STEP | Frost Step은 서버 출발 중심의 서리. `frost`, 폭0.12, 잔상0.4s | [전](before/mage.cryo.frost_step.png) · [후](after/mage.cryo.frost_step.png) |
| 23. THUNDER SPEAR | Thunder Spear는 한 전방축의 전기 창. `lightning`, 폭0.19, 잔상0.26s | [전](before/mage.cryo.thunder_spear.png) · [후](after/mage.cryo.thunder_spear.png) |
| 24. ICE WARD | Ice Ward의 냉기와 보호 부여를 분리. `frost`, 폭0.14, 잔상0.44s | [전](before/mage.cryo.ice_ward.png) · [후](after/mage.cryo.ice_ward.png) |
| 25. FROSTSTORM | Froststorm은 지정지점 반경14의 서리 폭풍. `frost`, 폭0.18, 잔상0.56s | [전](before/mage.cryo.froststorm.png) · [후](after/mage.cryo.froststorm.png) |
| 26. GLACIAL SPIKE | Glacial Spike는 큰 단일 결정창. `frost`, 폭0.26, 잔상0.46s | [전](before/mage.cryo.glacial_spike.png) · [후](after/mage.cryo.glacial_spike.png) |
| 27. LIGHTNING LINE | Lightning Line은 직선 축 주위 전기 가지. `lightning`, 폭0.14, 잔상0.24s | [전](before/mage.cryo.lightning_line.png) · [후](after/mage.cryo.lightning_line.png) |
| 28. HAILFALL | Hailfall은 바닥 파편 대신 상공 낙하 결정. `hail`, 폭0.13, 잔상0.4s | [전](before/mage.cryo.hailfall.png) · [후](after/mage.cryo.hailfall.png) · [마지막](last-pulse/mage.cryo.hailfall.png) |
| 29. ETERNAL TEMPEST | Eternal Tempest는20반경 지점의 빈 중심 서리 인장. `frost`, 폭0.22, 잔상0.64s | [전](before/mage.cryo.eternal_tempest.png) · [후](after/mage.cryo.eternal_tempest.png) · [마지막](last-pulse/mage.cryo.eternal_tempest.png) |
| 30. WIND LANCE | Wind Lance의전용 공기리본을중복하지않음. 별도 공기 리본 유지 | [전](before/mage_wind_lance.png) · [후](after/mage_wind_lance.png) |
| 31. TIDAL RING | Tidal Ring은시전자중심5stud 물결. `water`, 폭0.19, 잔상0.46s | [전](before/mage_tidal_ring.png) · [후](after/mage_tidal_ring.png) |
| 32. ARCANE WARD | Arcane Ward는시전점중심 보호리본. `ward`, 폭0.12, 잔상0.56s | [전](before/mage_arcane_ward.png) · [후](after/mage_arcane_ward.png) |
