# 장비 보너스 단위 명확화

2026-11-08 · TLT-028/041/043/052/057/084 · ENG/DES → QA · 0.88.3 · 미게시

사용자 제보: 무기 정보의 +4가 포인트인지 퍼센트인지 모호하다. 실제 `SkillStatPreview.derived`와 서버 전투 계약은 power/100을 공격력 배율에 더하고 armor/health는 고정 수치로 더한다. Veteran 무기의 power4는 물리/마법 공격력 +4%다. 상점의 `Power +4.00`에는 %가 빠져 있었다.

상점은 `Attack +4.00%`, `Defense +4 pts`, `Max HP +4 pts`로 표시한다. 가방 비교는 `Attack bonus`의 현재/선택 값에 %, 차이에 pp(percentage points), 방어/HP에 pts를 표시한다. 예: 공격 보너스3%→4%는 +1pp다. 장착 후 실제 전투 수치 변화는 제목/요약에 pts를 명시한다. 강화 미리보기의 공격 보너스는(%), 방어/HP는(pts)로 표시하고, 영웅 장비 출처 목록의 고정 수치에도 pts를 붙였다. 가방 안내문은 단위와 비회복/스킬 배율 이전 계약을 설명하며 내용 높이를 측정한다. 수치·가격·강화·전투·저장 규칙은 바꾸지 않았다. 원인이 명확한 표시 결함으로 제작 스킬의 별도 리서치 예외를 적용했다.

변경: `ArmoryView`, `InventoryGui`, `InventoryText`, `AdventureText`, `CombatStatText`, `EquipmentImpact`, `VERSION`. 연결된 The Last Throne Battles Studio Edit 소스에도 해당 변경 문맥만 대조해 적용했다. 기존 사용자 변경/자산은 포함하지 않았다.

검증:

- `rojo build default.project.json -o /tmp/tlt-equipment-units.rbxlx` 성공.
- `run-in-roblox --place /tmp/tlt-equipment-units.rbxlx --script docs/evidence/equipment-units-20261108/units-probe.luau`: 실제4클래스 Veteran무기4%=1.04배·방어/HP고정4·상점 생성자 문구·강화 라벨49검사 PASS. [로그](units-native.log).
- 같은 Place의 [bag-probe.luau](bag-probe.luau): 기존 가방 fixture에 명시적인 Veteran 아이템을 넣고4클래스 실제 생성자의 %/pp/pts·실제 변화·회복 안내40검사 PASS. [로그](bag-native.log). Player/스냅샷은 대역이며 거래를 보내지 않는다.
- `lua tests/skill-stat-preview.spec.lua`:1392검사 PASS. [로그](skill-stat.log).
- 기존 `tests/equipment-impact.spec.lua`는 기본 무기와 Fine무기 차이를10%로 가정하는 옛 기대에서 실패했다. [로그](equipment-impact-existing.log). 기존 `tests/blacksmith-native.luau`도 현재 품목 수와 다른 고정 수량 기대에서23검사 후 실패했다. [로그](blacksmith-native.log). 해당 기존 검사 통과로 보고하지 않으며 이번 표시 변경과 분리한다.

미검증: 실제 화면 렌더/줄바꿈과 실기기·게시 클라이언트·사용자 수용. Studio Edit 적용은 Play 재시작/Place 저장·게시를 뜻하지 않는다. QA는 상점·가방·강화에서 긴 이름/고강화 소수/좁은 화면의 가독성을 확인한다. 부모 티켓 완료·릴리스 태그 없음.
