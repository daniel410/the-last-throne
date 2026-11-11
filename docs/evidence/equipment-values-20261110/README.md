# 장비 기본 수치 재지정

2026-11-10 · TLT-029/041/052/057/084 · 0.97.1 · ENG → QA

사용자가 직전 효과 표에서 Tempered +6/+4/+30, Veteran +15/+10/+50, Sentinel +30/+20/+80을 지정했다. [장비 정본](../../production/equipment-four-tier-reorganization-2026-11-09.md)과 `EquipmentFamilies` 버전5에 반영했다. 프로젝트 제작 스킬 적용. 직접 지정한 수치 조정으로 신규 리서치·효과를 임의 채택하지 않았다.

| 계열 | 무기 공격력 / 방패·투구 방어력 | 장갑 공격력 / 신발 방어력 | 상의 최대HP / 로브 최대MP |
| --- | ---: | ---: | ---: |
| Traveler | 3 | 2 | 20 |
| Tempered | 6 | 4 | 30 |
| Veteran | 15 | 10 | 50 |
| Sentinel | 30 | 20 | 80 |

강화는 기본 옵션3%/단계·최대+9(×1.27), 시도50Gold로 유지한다. +9의 세 묶음은 Tempered7.62/5.08/38.10, Veteran19.05/12.70/63.50, Sentinel38.10/25.40/101.60이다. 가격/등급/요구레벨·Traveler 지급/자동착용·장신구·모델/아이콘·삭제/퇴역 정의·스탯316·스킬/STR/INT 공식·효과 미배정 상태를 유지한다. 장비ID/인스턴스/강화단계/영수증을 재생성하지 않으며 기존 보유품은 현재 정의로 재계산한다. 현재HP/MP를 회복하거나 신규 MP 자원을 만들지 않는다.

검증: [각 명령·결과](tests.log). 순수 Lua12묶음 **6461검사 PASS**(인벤토리274, 특수효과277, 비교52, 고정공격110, 가족458, DEX130, 스킬1392, 강화2869, 은퇴486, 삭제171, 시작장비206, 재료36). 장비40종의 정확한 부위별 값/+9·획득/착용·구보유품 이관·시작 장비 보존과 슬롯 비교를 포함한다. Traveler→Veteran 무기 교체 기대는 공격력+7→+12, Tempered 출처 표시는5→6, Veteran 시작 보너스 투구는15로 수정했다. 원래 테스트 논리/경계·저장 복구 검사는 보존했다.

고정 소스 `0e7c50528753a8380e6fa0c91799f5053701b1d1`를 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/equipment-values-20261110/build.json`으로 단일 빌드 **0.97.1 성공**. 산출물 `builds/0.97.1/TheLastThrone-0.97.1.rbxlx`, SHA256 `6475c0f07f09c375e3ad67bfd9be69ca31ad478294b97628ee40cfcc68c711df`([빌드 기록](build.json)).

`python3 tests/single-build.spec.py --artifact builds/0.97.1/TheLastThrone-0.97.1.rbxlx`: 역할10/도착로딩192·마운트/실제구성 PASS. `run-in-roblox --place builds/0.97.1/TheLastThrone-0.97.1.rbxlx --script docs/evidence/equipment-values-20261110/native.luau`: 실제 모듈의 가족458/비교52/고정공격110/DEX130/시작장비206/효과289 = **1245검사 PASS**([로그](native.log)). 순수 테스트 논리의 dofile을 실제 require로 바꾼 격리 엔진 검사이며, 효과289에는 모듈 로딩·강화/상점 카드 설명과 높이 검사도 포함한다. 실제 플레이어 전투/시각 수용과 구분한다. Roblox 게시/릴리스 태그 없음. 연결된 사용자 Studio는 변경하지 않는다. 실계정/게시 클라이언트·PC/모바일/패드·실전 밸런스 수용은 후속이다. 다른 미커밋 자산은 커밋 범위에서 제외한다. 새 LFS 자산 없음.
