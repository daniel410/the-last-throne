# 영웅128기술 VFX 아트 리뷰

TLT-033/054/055/056/057 · ART/DES 독립 리뷰 · 2026-11-13 · 소스 `974c2553639691eea8141c2302a09b2d257f4850` / `0.104.25`

4클래스32기술씩128개를 소스 목록과 최신8개 시트/128개 PNG로 전수 검토하고 Quickfire의 .035초 추가 장면을 함께 봤다. 결과는 **개선22 / 유지 후보106 / 자료 보류0**다. 유지 후보는 주 형상을 보존하자는 미술 판단이며 최종 승인/PASS가 아니다. 전체 티켓·실제 플레이·기기 미술 수용은 보류한다. 게임 코드·수치·버전·원본 자산은 변경하지 않았다.

## 검토 방법과 범위

기준은 [원소 미술 계약](../../production/element-vfx.md), [현재 제품 계약](../../product-contracts.md), `agents/roles/game-designer.md`와 `modeling-artist.md`다. K0Config → PixelFXCatalog/SkillPresentation → SkillVFXProfiles의128개 대응을 읽고 HeroVFX/AdvancedSkillVisual/PixelFX/CuratedVFX의 합성 경로를 확인했다. [개별 판정/진단/해시](hero-review.json), [실제 캡처 입력/진단](hero/manifest.json).

회색 모형·첫 펄스·Hero/Wind/Pixel .10초 샘플 정지. AdvancedSkillVisual Tween층은 초기 상태. 준비/후속·막펄스/실제 영웅·무기·이동/대상 피격·위험 바닥/다인·기기/최종 사용자 수용 미검증.

기술 캡처는 기본 points={}이며 체인3점/Multishot 확정 fan에만 회색 목표 가이드를 둔다. 가이드는 실제 적/피격 반응이 아니다. 초기 임의3점 시도나 예전 캡처의 떠 보이는 인물/문자는 최신 기술 장면에서 재현되지 않아 현재 결함 근거에서 제외했다. 실제 명중 효과의 아틀라스는 공통 효과 리뷰 범위다.

관찰은 기술별 주 형상/원소/색·단일 장면 밀도·공간 위계에 한정한다. 타격감, 흐름 속도, 전체 펄스 차이, 위험 바닥 가림, 발광/GPU 부담은 정지 PNG나 인스턴스 수만으로 합격/실패를 판정하지 않는다. 기술별 자동 카메라 확대율이 달라 멀리 잡힌 궁극기의 픽셀 수를 실제 게임 카메라의 가독성 수치로 취급하지 않았다.

## 유지할 방향

- 전방 방패/초승달/찌르기/내려치기의 주 형상은 서로 구별된다. 물리 기사의 청색과 성기사13기술의 금빛은 유지한다.
- 불의 꼬리·물의 열린 물결·바람의 축을 감는 기류·번개의 꺾인 분기·얼음의 결정·대지의 암석 면은 현재 장면에서 구별된다.
- 중앙이 빈 물/냉기/성속성 인장은 모형을 읽히게 한다. 이 관찰을 다인 위험 바닥 가림 합격으로 확대하지 않는다.
- 물리 화살의 밝은 촉과 자연 마법 화살의 민트 감김은 보존할 후보다. 빠른 사격/이동/표식 소모는 실제 동작 차이 검토가 남는다.

## 우선 미술 항목

| 코드 | 우선·근거 수준 | 관찰과 다음 비교 | 대표 증거 |
| --- | --- | --- | --- |
| HV-A01 | P1 · 정지 화면 관찰+소스 | **전방 기술의 원형 채움/고리 때문에 방향 의미가 섞임**. 실제 전방 경계는 유지하고 장식 채움/나선을 전방 섹터로 제한하거나 뒤쪽 강도를 낮춘다. 단일/다인 위험 바닥 위에서 전방/주변을 구별하는지 재검토. | [elf.magic_archer.rooting_fan](hero/elf.magic_archer.rooting_fan.png) |
| HV-A02 | P2 · 정지 화면 관찰+소스 | **산탄이 큰 화살촉 다섯 개로 읽힘**. 산탄은 화살촉 삼각면을 빼고 짧은 탄흔·작은 파편 묶음을 주형으로 비교. 실제 총 프롭을 든 영웅으로 물리 활의 Fan Break와 나란히 검토. | [dwarf.gunner.scatter_shot](hero/dwarf.gunner.scatter_shot.png) |
| HV-A03 | P2 · 정지 화면 관찰+소스 | **포격의 긴 세로 기둥이 포탄보다 마법 레이저로 읽힘**. 포탄 본체→짧은 꼬리→접촉 섬광을 주형으로 두고 중복된 긴 세로 기둥을 보조화. 시전부터 착탄/회수까지 실제 재생에서 검토. | [dwarf.gunner.field_mortar](hero/dwarf.gunner.field_mortar.png) |
| HV-A04 | P2 · 정지 화면 관찰+소스 | **자연 구속이 식물보다 민트 스프링/고리로 읽힘**. 지면에 붙은 뿌리의 분기·두께 변화·짧은 가시/잎 단서를 주형으로 비교. 대상 발밑에서 자라게 하고 큰 공중 나선은 보조화. | [elf.magic_archer.rooting_fan](hero/elf.magic_archer.rooting_fan.png) |
| HV-A05 | P2 · 정지 화면 관찰+소스 | **증기가 물결+흰 막대에 머묾**. 얇고 짧은 상승 기체 흐름/희미한 응결 단서를 주형으로 비교. 물의 청색 질량은 줄이고 냉기 결정과 다른 흐름을 유지. 넓은 흰 화면 덮개는 피함. | [mage.pyro.steam_burst](hero/mage.pyro.steam_burst.png) |
| HV-A06 | P2 · 정지 화면 관찰+소스 | **광역 화염이 주황 판/울타리로 읽힘**. 네 수직 판의 각도/형상/시간 차를 화염 혀와 상승 흐름으로 정리. 기존 열린 중심과 위험 범위 선은 유지하고 불/얼음 흑백 구분을 확인. | [mage.pyro.cinder_ring](hero/mage.pyro.cinder_ring.png) |
| HV-A07 | P2 · 정지 화면 관찰+소스 | **용암 계열의 바위/고리 구조가 대지와 많이 겹침**. 바위 면과 갈라진 뜨거운 틈/짧은 분출을 주형으로 대비. 단순 주황 고리 추가보다 표면 흐름을 비교하되 실제 earth 판정/범위는 유지. | [mage.pyro.caldera_s_judgment](hero/mage.pyro.caldera_s_judgment.png) |
| HV-A08 | P2 · 첫 펄스 관찰 한정 | **궁극기의 첫 박자 형상/초점 위계가 일반 기술과 가까움**. 일반 기술 장식 강도를 먼저 낮추고 궁극기별 한 개의 주 형상/진입 초점을 추가하는 비교. 준비→첫 타격→중간/마지막 펄스→회수를 실제로 재생한 뒤 최종 판단. 이 정지컷만으로 궁극기 전체 실패를 선언하지 않음. | [dwarf.gunner.siege_barrage](hero/dwarf.gunner.siege_barrage.png) |
| HV-S01 | P2 · 소스에서 확인한 미술 연속성 위험/실제 명중 미관찰 | **드워프 steel 기술의 주황 skill 장식과 청색 contact 장식**. skill의 dwarf/steel 팔레트 덮어쓰기와 contact를 실제 같은 타격에서 비교. 이 리뷰의 기술 캡처만으로 현재 명중 결함 확정하지 않음. | [dwarf.common.overhead](hero/dwarf.common.overhead.png) |
| HV-L01 | P3 · 정지 화면 미술 다듬기 후보 | **넓은 검기의 삼각 면 분할과 평평한 발광 면이 도드라짐**. 큰 실루엣은 보존하고 삼각 면 사이의 밝기/겹침과 하이라이트 폭을 정리. 더 많은 광량/면을 추가하는 방식보다 동일 화면 A/B로 비교. | [dwarf.iron_axe.crag_cleave](hero/dwarf.iron_axe.crag_cleave.png) |

P1은 현재 미술 작업 순서의 우선순위이며 게임 기능 차단/보안 심각도 판정이 아니다. `HV-S01`은 소스 위험, `HV-L01`은 선택적 다듬기로 개별 정지 장면의 개선 수에는 포함하지 않았다. P1/P2를 해결하려고 서버 범위나 펄스를 바꾸지 않는다.

## 관찰 한계·미검증

`dwarf.gunner.quickfire`는 [.035초 추가 장면](hero-early/dwarf.gunner.quickfire.png)에서 작은 총구 섬광과 탄흔을 직접 확인해 유지 후보로 판단했다. [추가 진단](hero-early/manifest.json)은4개 ImageLabel 모두 loaded=true다. [.10초 재촬영](hero-retry/dwarf.gunner.quickfire.png)의 세 flare는 loaded=false지만 life=.13의 u=.769가 flare 종료(u=.65) 뒤라 계산상 투명도1이다. 이를 로딩장애/미술 결함으로 분류하지 않는다. 원본·늦은 재촬영·이른 추가 장면은 각각 보존했다. 나머지127개 원본 프레임의 기록된 ImageLabel은 loaded=true이며 이것이 게시 Experience 권한 증명은 아니다.

실제 TD 영웅/8슬롯 장비·총/도끼/활 소켓, 밝고 어두운 지역, 준비→첫 펄스→중간/막펄스→회수, 실제 적 피격·표식/보호·중단, 4인+AI·터치/패드·실기기/GPU·색각/흑백·최종 사용자 미술 수용은 미검증이다.

## 128개 개별 판정

### knight

[앞16개 시트](hero/knight-1.png) · [뒤16개 시트](hero/knight-2.png)

| 번호·기술 | 판정 | 관찰 | 연결 항목 |
| --- | --- | --- | --- |
| 1. [SHIELD BASH](hero/knight.common.bash.png) | 유지 후보 | 전방 청색 방패판이 작고 분명해 기본 방패 공격으로 읽힌다. | — |
| 2. [WHIRLWIND](hero/knight.common.whirlwind.png) | 유지 후보 | 흰 환형 검기와 빈 중앙으로 회전 공격 범주가 읽힌다. 삼각 면 분할은 다듬기 후보다. | — |
| 3. [PROVOKE](hero/knight.common.provoke.png) | 유지 후보 | 금빛 동심원과 채움으로 주변 도발 범주는 읽힌다. 실제 적의 도발 상태 표시는 이 화면에 없다. | — |
| 4. [COUNTER SLASH](hero/knight.steel_knight.counter_slash.png) | 유지 후보 | 짧은 흰 검기와 방어선이 겹쳐 반격 계열의 근거리 방향은 읽힌다. | — |
| 5. [STEEL SWEEP](hero/knight.steel_knight.steel_sweep.png) | 유지 후보 | 넓고 끝이 가는 흰 초승달 면으로 전방 베기가 읽힌다. | HV-L01 |
| 6. [CHALLENGING STRIKE](hero/knight.steel_knight.challenging_strike.png) | 유지 후보 | 짧은 흰 초승달로 근거리 공격은 읽힌다. 도발/약화 부가 의미는 실제 대상 관찰이 필요하다. | — |
| 7. [TWIN CYCLONE](hero/knight.steel_knight.twin_cyclone.png) | 유지 후보 | 겹친 환형 검기로 다회 회전의 원형은 보인다. 두 번째 펄스는 관찰하지 않았다. | — |
| 8. [SHIELD BREAKER](hero/knight.steel_knight.shield_breaker.png) | 유지 후보 | 청색 방패 접촉면이 검기와 구별된다. 자세 파괴의 상대 반응은 별도다. | — |
| 9. [GUARDIAN COUNTER](hero/knight.steel_knight.guardian_counter.png) | 유지 후보 | 짧은 검기와 작은 보호 고리가 함께 보여 일반 베기와 구별된다. | — |
| 10. [RALLYING SLASH](hero/knight.steel_knight.rallying_slash.png) | 유지 후보 | 큰 흰 베기 면은 분명하다. 아군 지원/도발의 대상 상태는 이 정지컷에 없다. | — |
| 11. [BREAKER CHARGE](hero/knight.steel_knight.breaker_charge.png) | 유지 후보 | 전방 방패판과 부채꼴 경계가 돌파 방향을 보여 준다. 실제 이동은 미관찰이다. | — |
| 12. [VANGUARD STRIKE](hero/knight.steel_knight.vanguard_strike.png) | 유지 후보 | 가늘고 길게 수렴하는 흰 찌르기 면이 초승달 베기와 구별된다. | — |
| 13. [BLADE STORM](hero/knight.steel_knight.blade_storm.png) | 유지 후보 | 큰 환형 검기 중앙에 영웅이 남는다. 지속 펄스와 이동의 시간 위계는 미관찰이다. | — |
| 14. [SWEEPING BREAK](hero/knight.steel_knight.sweeping_break.png) | 유지 후보 | 환형 베기가 넓게 읽힌다. Blade Storm과의 시간/회전 차이는 동작 검토가 필요하다. | — |
| 15. [WARCRY ASSAULT](hero/knight.steel_knight.warcry_assault.png) | 개선 | 전방 곡선 뒤에 넓은 원형 채움이 남아 전방 공격인지 주변 공격인지 시각 메시지가 섞인다. | HV-A01 |
| 16. [UNYIELDING FRONT](hero/knight.steel_knight.unyielding_front.png) | 개선 | 작은 방패와 겹친 고리가 주형이라 궁극기의 첫 박자 초점이 일반 방어 기술에 가깝다. | HV-A08 |
| 17. [OATHBLADE](hero/knight.paladin.oathblade.png) | 유지 후보 | 금빛 짧은 검기로 물리 기사와 성기사 계열이 색으로 구별된다. | — |
| 18. [RADIANT SWEEP](hero/knight.paladin.radiant_sweep.png) | 유지 후보 | 넓은 금빛 초승달이 전방 공격 방향을 분명하게 보여 준다. | HV-L01 |
| 19. [OATH CHALLENGE](hero/knight.paladin.oath_challenge.png) | 개선 | 전방 곡선과 시전자 뒤까지 퍼지는 원형 금빛 채움이 함께 보여 공격 방향 의미가 섞인다. | HV-A01 |
| 20. [DAWN BURST](hero/knight.paladin.dawn_burst.png) | 유지 후보 | 열린 금빛 인장과 상승광으로 물/냉기 광역과 구별된다. | — |
| 21. [OATHBREAKER STRIKE](hero/knight.paladin.oathbreaker_strike.png) | 유지 후보 | 위에서 내려오는 금빛 곡선 면이 수평 베기와 구별된다. | — |
| 22. [SHIELD VERDICT](hero/knight.paladin.shield_verdict.png) | 유지 후보 | 금빛 전방 방패판이 물리 방패의 청색과 분명히 구별된다. | — |
| 23. [GUARDIAN SLASH](hero/knight.paladin.guardian_slash.png) | 유지 후보 | 금빛 초승달과 작은 보호 고리의 결합이 보인다. 대상 보호/도발 상태는 미관찰이다. | — |
| 24. [RADIANT CHARGE](hero/knight.paladin.radiant_charge.png) | 유지 후보 | 전방 금빛 방패판과 부채꼴 경계는 읽힌다. 이동/두 번째 타격은 미관찰이다. | — |
| 25. [VALIANT ADVANCE](hero/knight.paladin.valiant_advance.png) | 유지 후보 | 전방 금빛 방패와 발밑 보호 고리가 보인다. 실제 전진 동작과의 연결은 별도다. | — |
| 26. [DAWN SPIRAL](hero/knight.paladin.dawn_spiral.png) | 유지 후보 | 열린 금빛 인장을 유지한다. 첫 프레임은 Dawn Burst와 닮았으며 회전/다회 펄스 차이는 미관찰이다. | — |
| 27. [SUNWARD CROSS](hero/knight.paladin.sunward_cross.png) | 유지 후보 | 교차하는 두 금빛 면이 다른 성기사 베기와 구별된다. | — |
| 28. [OATHBOUND ASSAULT](hero/knight.paladin.oathbound_assault.png) | 유지 후보 | 겹친 금빛 검기가 공격성을 보여 준다. 연속 펄스의 대비는 미관찰이다. | — |
| 29. [OATH OF DAWN](hero/knight.paladin.oath_of_dawn.png) | 개선 | Dawn Burst와 같은 크기 계열의 금빛 인장/방사선이 주형이라 첫 펄스 궁극기 위계가 약하다. | HV-A08 |
| 30. [DRIVING THRUST](hero/knight_driving_thrust.png) | 유지 후보 | 곧은 쐐기형 흰 면으로 전진 찌르기 방향이 분명하다. | — |
| 31. [CRESCENT CUT](hero/knight_crescent_cut.png) | 유지 후보 | 넓고 가늘어지는 흰 초승달이 단발 전방 베기로 읽힌다. | HV-L01 |
| 32. [GUARDED STRIKE](hero/knight_guarded_strike.png) | 유지 후보 | 작은 청색 방패판으로 방어 부가 공격이라는 범주가 읽힌다. | — |

### dwarf

[앞16개 시트](hero/dwarf-1.png) · [뒤16개 시트](hero/dwarf-2.png)

| 번호·기술 | 판정 | 관찰 | 연결 항목 |
| --- | --- | --- | --- |
| 1. [OVERHEAD SMASH](hero/dwarf.common.overhead.png) | 유지 후보 | 주황빛 하강 곡면이 무거운 내려치기 방향을 보여 준다. 실제 도끼/피격 연속성은 별도다. | HV-S01 |
| 2. [AXE THROW](hero/dwarf.common.throw.png) | 유지 후보 | 직선 꼬리와 회전 끝점이 보인다. 실제 도끼 모델이 없는 모형 캡처이므로 무기 실루엣은 승인하지 않는다. | — |
| 3. [GROUND SLAM](hero/dwarf.common.ground.png) | 유지 후보 | 시전자 주변 균열선과 갈색 돌 조각으로 지면 충격이 읽힌다. | — |
| 4. [ARMOR SPLITTER](hero/dwarf.iron_axe.armor_splitter.png) | 유지 후보 | 짧고 두꺼운 주황 하강 면이 내려치기 공격으로 읽힌다. | HV-S01 |
| 5. [RETURNING ECHO](hero/dwarf.iron_axe.returning_echo.png) | 유지 후보 | 직선 꼬리와 회전 끝점은 읽힌다. 회수 펄스와 실제 도끼는 이 컷에 없다. | — |
| 6. [MOUNTAIN SWEEP](hero/dwarf.iron_axe.mountain_sweep.png) | 유지 후보 | 열린 주황 띠와 돌 조각으로 주변 지면 충격이 읽힌다. | HV-S01 |
| 7. [CRAG CLEAVE](hero/dwarf.iron_axe.crag_cleave.png) | 유지 후보 | 겹친 하강 곡면으로 전방 중량 베기가 읽힌다. | HV-S01, HV-L01 |
| 8. [BREAKER THROW](hero/dwarf.iron_axe.breaker_throw.png) | 유지 후보 | 강한 직선 꼬리와 끝점 강조가 보인다. 실제 도끼/표식 소모 반응은 미관찰이다. | — |
| 9. [STONEBOUND LEAP](hero/dwarf.iron_axe.stonebound_leap.png) | 유지 후보 | 주변 돌과 열린 띠가 착지 충격 범주를 보여 준다. 도약 동작은 미관찰이다. | HV-S01 |
| 10. [IRON SHOULDER](hero/dwarf.iron_axe.iron_shoulder.png) | 유지 후보 | 청색 전방 방패판은 돌파/방어 범주로 읽힌다. 도끼 계열의 실제 어깨 모션은 미관찰이다. | — |
| 11. [CROSSCUT AXE](hero/dwarf.iron_axe.crosscut_axe.png) | 유지 후보 | 첫 직선 도끼 경로는 읽힌다. 회수와 두 번째 교차 경로는 미관찰이다. | — |
| 12. [MOUNTAIN STRIKE](hero/dwarf.iron_axe.mountain_strike.png) | 유지 후보 | 전방 부채꼴의 균열과 돌 조각으로 공격 방향이 구별된다. | HV-S01 |
| 13. [SHATTER BLOW](hero/dwarf.iron_axe.shatter_blow.png) | 유지 후보 | 작은 중심 충격과 둘레 돌이 원거리 지점 파쇄로 읽힌다. | HV-S01 |
| 14. [TWIN AXE PATH](hero/dwarf.iron_axe.twin_axe_path.png) | 유지 후보 | 직선 투척 경로는 읽힌다. 두 번째 도끼 경로/대상 반응은 미관찰이다. | — |
| 15. [TREMOR GUARD](hero/dwarf.iron_axe.tremor_guard.png) | 유지 후보 | 주변 돌과 작은 보호 고리로 충격+방어 범주가 읽힌다. | HV-S01 |
| 16. [MOUNTAIN COLLAPSE](hero/dwarf.iron_axe.mountain_collapse.png) | 개선 | 긴 전방 균열과 희소한 돌 조각이 주형이라 거대한 붕괴의 첫 박자 무게 중심이 약하다. | HV-A08, HV-S01 |
| 17. [GUNNER SHOT](hero/dwarf.gunner.gunner_shot.png) | 유지 후보 | 가는 황색 직선 탄흔으로 단일 사격 범주가 읽힌다. | — |
| 18. [BOMB TOSS](hero/dwarf.gunner.bomb_toss.png) | 유지 후보 | 작은 중심 폭발·파편과 열린 경계로 폭탄 착탄은 읽힌다. 큰 구형 덮개가 없다. | — |
| 19. [SHELL BURST](hero/dwarf.gunner.shell_burst.png) | 개선 | 굵고 긴 주황 세로 기둥이 주 인상이라 포탄보다 마법 낙뢰/레이저에 가깝게 읽힌다. | HV-A03 |
| 20. [QUICKFIRE](hero/dwarf.gunner.quickfire.png) | 유지 후보 | .035초 추가 장면에서 작은 총구 섬광과 가는 탄흔이 분명하다. .10초 컷은 정상적으로 섬광이 끝난 뒤다. | — |
| 21. [SHRAPNEL TOSS](hero/dwarf.gunner.shrapnel_toss.png) | 유지 후보 | 열린 띠·작은 불꽃으로 폭발 범주가 읽힌다. 반복 폭발의 박자 차이는 미관찰이다. | — |
| 22. [BLAST STEP](hero/dwarf.gunner.blast_step.png) | 유지 후보 | 전방 열린 충격 띠와 짧은 불꽃으로 전방 폭파 범주가 읽힌다. 실제 후퇴는 미관찰이다. | — |
| 23. [SCATTER SHOT](hero/dwarf.gunner.scatter_shot.png) | 개선 | 부채꼴 큰 삼각 촉 다섯 개가 화살처럼 보여 산탄의 무기 정체성이 약하다. | HV-A02 |
| 24. [SKIPPING CHARGE](hero/dwarf.gunner.skipping_charge.png) | 유지 후보 | 작은 중심 폭발과 열린 경계는 읽힌다. 산개한 두 번째 착탄은 미관찰이다. | — |
| 25. [FIELD MORTAR](hero/dwarf.gunner.field_mortar.png) | 개선 | 대상 위 긴 주황 기둥이 지배해 떨어지는 포탄의 본체/무게가 약하다. | HV-A03 |
| 26. [PIERCING ROUND](hero/dwarf.gunner.piercing_round.png) | 유지 후보 | 가는 황색 직선은 단일 관통 사격 범주로 읽힌다. 관통 대상 반응은 미관찰이다. | — |
| 27. [ROLLING CHARGE](hero/dwarf.gunner.rolling_charge.png) | 유지 후보 | 작은 중심 폭발과 열린 띠로 착탄은 읽힌다. 구르는 준비/이동 구간은 미관찰이다. | — |
| 28. [SIEGE PATTERN](hero/dwarf.gunner.siege_pattern.png) | 개선 | 넓은 원 안에 같은 세로 기둥·작은 폭발이 보여 포격 산개 패턴은 첫 컷만으로 드러나지 않는다. | HV-A03 |
| 29. [SIEGE BARRAGE](hero/dwarf.gunner.siege_barrage.png) | 개선 | 큰 범위에 작은 중심과 세로 기둥만 보여 궁극기 초점/밀도 위계가 약하다. | HV-A03, HV-A08 |
| 30. [HOOKING CHOP](hero/dwarf_hooking_chop.png) | 유지 후보 | 굽은 주황 하강 면으로 근거리 도끼 베기가 읽힌다. | HV-S01 |
| 31. [LOW SWEEP](hero/dwarf_low_sweep.png) | 유지 후보 | 낮은 높이의 넓은 주황 곡면으로 하단 휩쓸기가 구별된다. | HV-S01 |
| 32. [BRACED THROW](hero/dwarf_braced_throw.png) | 유지 후보 | 직선 투척 꼬리는 읽힌다. 실제 도끼와 소켓/방향은 모형으로 수용하지 않는다. | — |

### elf

[앞16개 시트](hero/elf-1.png) · [뒤16개 시트](hero/elf-2.png)

| 번호·기술 | 판정 | 관찰 | 연결 항목 |
| --- | --- | --- | --- |
| 1. [AIMED SHOT](hero/elf.common.aimed.png) | 유지 후보 | 밝은 화살촉과 가는 궤적으로 기본 물리 화살이 읽힌다. | — |
| 2. [RAPID FIRE](hero/elf.common.rapid.png) | 유지 후보 | 가늘어진 궤적/촉이 보인다. 속사의 세 발 박자는 정지 컷에 없다. | — |
| 3. [MULTI SHOT](hero/elf.common.multi.png) | 유지 후보 | 확정된 다섯 갈래 화살과 목표 가이드로 다중 사격이 분명하다. | — |
| 4. [WEAKPOINT SHOT](hero/elf.marksman.weakpoint_shot.png) | 유지 후보 | 밝은 단일 촉과 직선으로 정밀 사격 범주는 읽힌다. 약점 표식은 실제 적 관찰이 필요하다. | — |
| 5. [MOVING VOLLEY](hero/elf.marksman.moving_volley.png) | 유지 후보 | 물리 화살은 분명하다. 사격 중 이동과 연속 박자는 미관찰이다. | — |
| 6. [PIERCING LINE](hero/elf.marksman.piercing_line.png) | 유지 후보 | 두꺼운 밝은 촉과 곧은 경로로 직선 관통 범주가 읽힌다. | — |
| 7. [HEAVY DRAW](hero/elf.marksman.heavy_draw.png) | 유지 후보 | 단일 물리 화살은 분명하다. 긴 준비 동작에서 중량을 쌓는지는 미관찰이다. | — |
| 8. [PRECISION VOLLEY](hero/elf.marksman.precision_volley.png) | 유지 후보 | 물리 화살 표현은 유지할 수 있다. 반복/표식 소모 차이는 실제 대상 관찰이 필요하다. | — |
| 9. [FAN BREAK](hero/elf.marksman.fan_break.png) | 유지 후보 | 부채꼴 다섯 갈래 촉이 단일 사격과 구별된다. | — |
| 10. [HUNTER'S FOCUS](hero/elf.marksman.hunter_s_focus.png) | 유지 후보 | 물리 화살에 작은 발밑 보호 고리가 더해져 방어 부가가 보인다. | — |
| 11. [RETREATING FIRE](hero/elf.marksman.retreating_fire.png) | 유지 후보 | 물리 화살은 분명하다. 후퇴 동작이 없는 모형이라 기동 타격감은 판단하지 않는다. | — |
| 12. [PIERCING VOLLEY](hero/elf.marksman.piercing_volley.png) | 유지 후보 | 넓은 부채꼴 경로는 보인다. 자동 원거리 카메라에서 촉이 작아 실제 카메라 거리 확인이 필요하다. | — |
| 13. [MARK BREAKER](hero/elf.marksman.mark_breaker.png) | 유지 후보 | 정밀한 물리 화살 범주는 읽힌다. 표식 소비의 차별성은 실제 대상 관찰이 필요하다. | — |
| 14. [CROSSFIRE](hero/elf.marksman.crossfire.png) | 유지 후보 | 첫 직선 사격은 보인다. 두 번째 18도 교차와 시간 연결은 미관찰이다. | — |
| 15. [ARROW RAIN](hero/elf.marksman.arrow_rain.png) | 유지 후보 | 황색/백색 낙하선과 가는 본체로 화살비가 읽힌다. | — |
| 16. [GRAND VOLLEY](hero/elf.marksman.grand_volley.png) | 개선 | 넓은 얇은 부채꼴 사격이 주형이라 일반 다중 사격 대비 첫 펄스 궁극기 초점이 약하다. | HV-A08 |
| 17. [ELEMENTAL ARROW](hero/elf.magic_archer.elemental_arrow.png) | 유지 후보 | 민트색 촉과 감기는 궤적으로 물리 화살과 마법 화살이 구별된다. | — |
| 18. [SPARK VOLLEY](hero/elf.magic_archer.spark_volley.png) | 유지 후보 | 청색 촉과 궤적으로 자연색 사격과 구별된다. 방전/반복 박자는 동작 검토가 필요하다. | — |
| 19. [VINE TRAP](hero/elf.magic_archer.vine_trap.png) | 개선 | 밝은 민트 나선 면이 공중 스프링처럼 보여 지면 뿌리/구속의 의미가 약하다. | HV-A04 |
| 20. [BLOOM SHOT](hero/elf.magic_archer.bloom_shot.png) | 유지 후보 | 민트 촉과 감기는 궤적은 읽힌다. 개화/표식 소모 의미는 실제 적 반응 확인이 필요하다. | — |
| 21. [STORM ARROW](hero/elf.magic_archer.storm_arrow.png) | 유지 후보 | 청색 꺾인 수직 방전으로 자연 화살비와 구별된다. 상단이 화면 밖이라 전체 실루엣 평가는 제한된다. | — |
| 22. [ROOTING FAN](hero/elf.magic_archer.rooting_fan.png) | 개선 | 전방 가는 가지보다 시전자 중심360도 민트 고리가 커서 전방 뿌리 부채꼴 의미가 약하다. | HV-A01, HV-A04 |
| 23. [WARDEN ARROW](hero/elf.magic_archer.warden_arrow.png) | 유지 후보 | 민트 화살과 발밑 보호 고리로 자연 사격+방어 부가가 읽힌다. | — |
| 24. [GLIDING SHOT](hero/elf.magic_archer.gliding_shot.png) | 유지 후보 | 민트 단일 사격은 분명하다. 실제 활공/전진은 미관찰이다. | — |
| 25. [SPIRIT RAIN](hero/elf.magic_archer.spirit_rain.png) | 유지 후보 | 녹색 낙하 형태와 지점 입자로 물리 화살비와 구별된다. | — |
| 26. [ELEMENTAL PIERCE](hero/elf.magic_archer.elemental_pierce.png) | 유지 후보 | 민트 촉과 길게 감기는 궤적으로 마법 관통 범주는 읽힌다. | — |
| 27. [ECHO ARROWS](hero/elf.magic_archer.echo_arrows.png) | 유지 후보 | 마법 화살 범주는 읽힌다. 세 발의 간격/반복 의미는 미관찰이다. | — |
| 28. [VINE BURST](hero/elf.magic_archer.vine_burst.png) | 개선 | 밝은 민트 나선 면과 고리가 식물 폭발보다 마법 스프링/울타리로 읽힌다. | HV-A04 |
| 29. [SPIRIT ARROWFALL](hero/elf.magic_archer.spirit_arrowfall.png) | 개선 | 넓은 빈 범위와 희소한 녹색 낙하선으로 첫 펄스 궁극기 초점이 약하다. | HV-A08 |
| 30. [RETREATING SHOT](hero/elf_retreating_shot.png) | 유지 후보 | 밝은 물리 화살촉은 분명하다. 실제 후퇴와의 연속성은 미관찰이다. | — |
| 31. [PINNING SHOT](hero/elf_pinning_shot.png) | 유지 후보 | 물리 화살촉과 두 줄 꼬리가 보인다. 둔화는 실제 적 상태 관찰이 필요하다. | — |
| 32. [ARROW SCREEN](hero/elf_arrow_screen.png) | 유지 후보 | 짧은 범위에 모인 밝은 낙하 촉과 황색 경계로 물리 화살비가 읽힌다. | — |

### mage

[앞16개 시트](hero/mage-1.png) · [뒤16개 시트](hero/mage-2.png)

| 번호·기술 | 판정 | 관찰 | 연결 항목 |
| --- | --- | --- | --- |
| 1. [MANA BOLT](hero/mage.common.mana_bolt.png) | 유지 후보 | 보라색 작은 중심과 두 감김 선으로 비전 투사체가 구별된다. | — |
| 2. [WATER BALL](hero/mage.common.water_ball.png) | 유지 후보 | 청색 물방울/물결 고리가 보인다. 작은 투사체 부피와 실제 이동의 물성은 동작 확인이 필요하다. | — |
| 3. [GRAVITY](hero/mage.common.gravity.png) | 유지 후보 | 보라색 수렴 나선으로 다른 원소와 구별된다. 흡입 방향의 연속 움직임은 미관찰이다. | — |
| 4. [EMBER LANCE](hero/mage.pyro.ember_lance.png) | 유지 후보 | 노랑/주황의 가늘어지는 꼬리와 끝의 불꽃으로 화염 투사체가 읽힌다. | — |
| 5. [STEAM BURST](hero/mage.pyro.steam_burst.png) | 개선 | 청색 물결과 흰 막대 세 개가 주형이라 증기 구름/상승 기체의 의미가 약하다. | HV-A05 |
| 6. [CINDER RING](hero/mage.pyro.cinder_ring.png) | 개선 | 상승 불꽃보다 수직 주황 판 네 개가 두드러져 불의 흐름이 약하다. | HV-A06 |
| 7. [FLAME DART](hero/mage.pyro.flame_dart.png) | 유지 후보 | 짧고 좁은 화염 꼬리와 불꽃으로 단발 화염 투사체가 읽힌다. | — |
| 8. [EARTH RISE](hero/mage.pyro.earth_rise.png) | 유지 후보 | 갈색 돌과 균열/열린 띠로 대지 속성이 구별된다. | — |
| 9. [EMBER STEP](hero/mage.pyro.ember_step.png) | 개선 | 주변의 주황 수직 판이 두드러진다. 이동 흔적보다 고정 울타리처럼 읽힌다. | HV-A06 |
| 10. [STONE LANCE](hero/mage.pyro.stone_lance.png) | 유지 후보 | 갈색 각진 길쭉한 몸체와 돌 파편으로 돌창이 구별된다. | — |
| 11. [SEARING WARD](hero/mage.pyro.searing_ward.png) | 개선 | 주황 판과 고리는 보이지만 열기/화염 흐름보다 울타리 인상이 강하다. | HV-A06 |
| 12. [LAVA ERUPTION](hero/mage.pyro.lava_eruption.png) | 개선 | 바위·방사선·주황 고리가 주형이라 Earth Rise와 대비되는 용암 흐름/분출 의미가 약하다. | HV-A07 |
| 13. [MAGMA SPEAR](hero/mage.pyro.magma_spear.png) | 유지 후보 | 더 넓은 주황 화염 꼬리와 불꽃으로 화염 창이 읽힌다. | — |
| 14. [MOLTEN LINE](hero/mage.pyro.molten_line.png) | 유지 후보 | 화염 궤적이 직선 방향을 보여 준다. 다회 펄스/지속 작열은 미관찰이다. | — |
| 15. [ASHFALL](hero/mage.pyro.ashfall.png) | 유지 후보 | 주황 낙하 막대와 불티로 낙하 화염 범주는 읽힌다. 재/연기의 연속 물성은 미관찰이다. | — |
| 16. [CALDERA'S JUDGMENT](hero/mage.pyro.caldera_s_judgment.png) | 개선 | 바위/방사 고리 구조가 Lava Eruption과 닮아 궁극기의 분출 초점이 약하다. | HV-A07, HV-A08 |
| 17. [FROST LANCE](hero/mage.cryo.frost_lance.png) | 유지 후보 | 각진 얼음 몸체와 측면 결정으로 물/불 투사체와 구별된다. | — |
| 18. [ICE SHARD](hero/mage.cryo.ice_shard.png) | 유지 후보 | 각진 얼음 창과 측면 결정이 읽힌다. 기본 Frost Lance와의 차이는 정지 컷에서 작다. | — |
| 19. [FROST RING](hero/mage.cryo.frost_ring.png) | 유지 후보 | 열린 중앙과 분리된 지면 결정으로 물의 고리와 구별된다. | — |
| 20. [SHATTER DART](hero/mage.cryo.shatter_dart.png) | 유지 후보 | 뾰족한 청백색 결정으로 냉기 투사체가 읽힌다. 표식 소모 반응은 미관찰이다. | — |
| 21. [CHAIN LIGHTNING](hero/mage.cryo.chain_lightning.png) | 유지 후보 | 꺾인 주 경로/붙은 분기와 목표 가이드로 체인 연결이 분명하다. | — |
| 22. [FROST STEP](hero/mage.cryo.frost_step.png) | 유지 후보 | 열린 지면 결정 경계가 냉기로 읽힌다. 출발점 잔상과 실제 이동은 미관찰이다. | — |
| 23. [THUNDER SPEAR](hero/mage.cryo.thunder_spear.png) | 유지 후보 | 청색 꺾인 방전과 가는 가지로 얼음창과 구별된다. | — |
| 24. [ICE WARD](hero/mage.cryo.ice_ward.png) | 유지 후보 | 냉기 경계와 추가 보호 고리가 보인다. 실제 보호 지속/피격 반응은 미관찰이다. | — |
| 25. [FROSTSTORM](hero/mage.cryo.froststorm.png) | 유지 후보 | 지면 결정과 작은 중앙 냉기 입자로 광역 냉기는 읽힌다. 전체 폭풍 흐름은 미관찰이다. | — |
| 26. [GLACIAL SPIKE](hero/mage.cryo.glacial_spike.png) | 유지 후보 | 뾰족한 냉기 창은 읽힌다. Frost Lance와 몸체가 비슷해 상위 기술 중량은 추가 검토가 필요하다. | — |
| 27. [LIGHTNING LINE](hero/mage.cryo.lightning_line.png) | 유지 후보 | 꺾인 청색 주 경로와 가지로 짧은 전기 방전이 읽힌다. | — |
| 28. [HAILFALL](hero/mage.cryo.hailfall.png) | 유지 후보 | 두께가 있는 푸른 낙하 결정과 잔광으로 화살비와 구별된다. | — |
| 29. [ETERNAL TEMPEST](hero/mage.cryo.eternal_tempest.png) | 개선 | 넓은 빈 영역·희소한 결정·작은 중심으로 첫 펄스가 Froststorm과 거의 같은 구조로 읽힌다. | HV-A08 |
| 30. [WIND LANCE](hero/mage_wind_lance.png) | 유지 후보 | 발사축을 감는 민트/백색 기류 면으로 바람의 방향이 분명하다. | — |
| 31. [TIDAL RING](hero/mage_tidal_ring.png) | 유지 후보 | 중앙이 열린 청색 물결과 곡면으로 지면과 영웅을 읽을 수 있다. | — |
| 32. [ARCANE WARD](hero/mage_arcane_ward.png) | 유지 후보 | 보라색 열린 방어 면이 몸 주위를 둘러 비전 보호 범주가 읽힌다. | — |

## 다음 담당·수용 조건

1. DES/ENG: `HV-A01` 전방/주변 의미 혼선부터 같은 범위·같은 카메라 A/B로 정리한다. 선택 장식을 줄이더라도 기존 실제 범위 정보는 남긴다.
2. ART/ENG: 산탄/포격→자연 뿌리→증기/광역 화염→궁극기 첫 박자 순으로 주 형상을 한 개씩 정하고 중복 레이어를 보조화한다.
3. ART/QA: 실제 영웅/장비·밝고 어두운 지역·위험 예고 위에 아군 효과를 겹쳐 원소와 방향을 색 없이도 구별하는지 확인한다. 같은 기기의 동시 교전 프레임 시간과 첫 로드도 별도 측정한다.
4. QA: 전체 준비/연속·막펄스/회수·중단을 실제 재생하고 적 상태·피격 반응과 연결한다. 정지 리뷰가 끝났다는 이유로 TLT-033/057 또는 최종 미술 수용을 닫지 않는다.
