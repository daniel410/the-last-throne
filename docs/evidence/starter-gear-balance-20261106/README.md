# 기본 지급 장비 효과 하향

2026-11-06 · TLT-027/029/041/052/084 · ENG → QA · 0.78.5 · 부모 티켓 In Progress.

사용자가 기본 제공 무기·장비 효과가 과도하다고 지적했다. 첨부와 실제 서버 장비 합산에서 무강화 구성은 공격력18%·HP100·방어6이며, 기본HP100인 Mage의 HP가 두 배가 된다. [비교 조사·적용 판단](../../research/2026-11-06-starter-gear-balance.md).

| 아이템 | 이전 | 조정 |
| --- | --- | --- |
| 네 클래스 Tempered 무기 | 공격력10% | 3% |
| Traveler's Hood | 방어2 | 1 |
| Traveler's Coat | HP40·방어2 | HP10·방어1 |
| Traveler's Gloves | 공격력3% | 1% |
| Traveler's Boots | 방어2 | 1 |
| Copper Ring | 공격력5% | 1% |
| Amber Charm | HP60 | 15 |
| 무료 Lv5 Veteran's Hood | 방어6 | 3 |

첨부와 같은 Lv1 무강화 구성의 합계는 공격력5%·HP25·방어3이다. Lv5 무료 후드로 교체하면 방어5다. 영웅마다 최초1회 지급·아이템 안정ID/소유권·강화단계·물약/재료·보상·캐릭터 기본치·STR/VIT 계산을 유지한다. 유료/상자/보상에도 같은 정의ID가 사용되면 이번 기본치 조정이 적용된다. 기존 보유품은 접속/장비 재계산 시 현재 정의로 계산하며 저장 데이터 마이그레이션이나 live DataStore 쓰기를 수행하지 않는다. 이미 실행 중인 구버전 서버에는 적용되지 않는다.

## 검증

- `lua tests/inventory.spec.lua`:271 PASS.
- `lua tests/skill-stat-preview.spec.lua`:1392 PASS.
- `lua tests/difficulty-enhancement.spec.lua`:125 PASS. Tempered +3의 공격력은3×1.09=3.27%이며 강화 비율·소비·회수는 유지한다.
- `lua tests/starter-potions-and-shop.spec.lua`:316 PASS.
- `lua tests/hero-progression.spec.lua`:656 PASS.
- `lua tests/economy.spec.lua`:42 PASS.
- `lua tests/store-split.spec.lua`:14 PASS.
- `lua tests/retired-forge-equipment.spec.lua`:486 PASS.
- `lua tests/starter-gear-balance.spec.lua`:45 PASS. 네 클래스의 실제 Equip reducer→서버 합산→UI 계산·기존 버전 인스턴스·물약 보존 검사.
- 합계3347검사. `git diff --check` 통과.

입력 소스 `ba1898528cea74d6e4b7ef2ebfb578d93d12be1a`를 origin/main에 푸시한 뒤 단일 빌드0.78.5 성공. [빌드 기록](build.json)의 산출물 SHA-256은 `9d5a28a4cd5e3b8d61fa13adbc4721b1202807e6bc1b735d7d8cb058dacc437d`이다. XML의 ItemCatalog가 검증한 소스와 바이트 일치한다.

`run-in-roblox --place builds/0.78.5/TheLastThrone-0.78.5.rbxlx --script tests/starter-gear-balance.spec.lua`로 격리 Studio Luau에서도45검사 PASS. [엔진 결과](native.json). 기존203785492 자산 타입 경고가 발생했으며 장비 계산 검사는 통과했다. 실제 계정/실행 중 사용자 세션은 수정하지 않았다. 기존 Blender 변경과 미추적 산출물은 포함하지 않는다. 미게시·릴리스 태그 없음. 실제 게시 클라이언트/실기기·Deepwood 전투·사용자 최종 수치 수용은 미검증이며 QA→사용자 후속이다.
