# Deepwood 몬스터 동작·5초 스턴·초반 변주·메뉴

2026-10-31 · TLT-005/031/032/033/050/057/061/084 · 로컬 시험 구현, 게시 아님.

사용자 최종 입력: **H → STATS & SKILLS / T → ULTIMATE / B → GEAR & BAG**. 기존 HERO/BAG 메뉴 버튼과 미니맵 메뉴·레벨업 안내를 변경한다. 궁극기 Lv80 해금과 D-Pad Up/터치는 유지한다. 선택 화면의 HEROES는 별도의 영웅 선택 의미라 유지한다.

[조사/원천과 적용 구분](../../research/2026-10-31-deepwood-monster-motion.md) · [Blender 원본/해시](../../../assets/animations/deepwood-monsters-v1/manifest.json).

## 변경

- Blender MCP 내부 API로 TD 원본 메시10종, 대기/걷기/일반 공격/강공격/스턴50개 논리 클립(5컨트롤러씩250 Action)을 제작했다. 실제 이동 거리 기반 보행, 몸통 회전·무게 이동, 서버 타격 시각 기반 준비→타격→회수, 슬라임 압축/도약을 연결한다. 기존 메시/PBR/서버 충돌 리그는 보존한다.
- 포즈는 PreSimulation에 적용한다. 실제 메시 경계로 발의 지면 관통을 보정하며260stud 밖은 평가를 생략한다. 분리되지 않은 로브·몸체는 독립 사지 리그가 완성된 것으로 보고하지 않는다.
- 드워프 Ground Slam과 root3 계열10개 기술은 실제 피해 적용 시5초 스턴. 반복 타격은 최근 시각+5초로 갱신한다. 이동/공격/경로 작업을 취소하고 만료/리셋/사망 시 해제한다. 보스도 동일하며 실제 난이도 수용은 후속이다.
- DW-01 웨이브를 Goblin→Slime→Goblin→혼합 순서로 반복한다. 인원 상한·유한 증원·레벨·총XP/Gold를 유지한다.

## 검증

로컬 소스 QA fixture `/private/tmp/tlt-motion-0450-qa.rbxlx`는 버전 고정 정식 빌드와 구분한다.

| 명령/조건 | 결과 |
| --- | --- |
| `lua tests/dwarf-stun-and-first-story.spec.lua` | 57개 통과: root3 전체/다른 계열 제외, 웨이브 종류·레벨·보상 계약 |
| `lua tests/deepwood-encounter-balance.spec.lua` | 3,103개 통과: 유한 총량/상한/보상 유지 |
| `lua tests/advanced-skills.spec.lua` | 1,435개 통과 |
| `run-in-roblox --place <fixture> --script tests/deepwood-monster-motion-native.luau` | 9,525개 통과: 실제 TD10종 모터·발높이·서버 루트 불변·타격 시각/늦은 관찰자·30/144Hz. 최대 음수 발높이 오차0.000009stud 미만 |
| `tests/deepwood-service-native.luau` | 2,463개 통과: 실제 첫4웨이브 교대, 전체 유한 스토리/추가 보스·중복 사망 보상 |
| `tests/k0-timing-native.luau` | 110개 통과: 순서가 앞선 Ground Slam이 뒤의 대기 적 타격을 취소함을 추가 |
| `tests/dwarf-stun-native.luau` | 36개 통과: 실제 피해/AI,5초 경계·중복/재타격·보스·리셋·기본기 제외 |

Blender5.2의 Action API 변경(fcurves→layer/strip/channelbag, group_name)과 내보내기 원본의 누락된 해시 필드를 수정했다. 첫 검토 이미지에서 부모 행렬 평가 전 바인딩으로 파츠가 벌어진 문제를 발견하여 depsgraph 평가 후 정확한 inverse parent 변환으로 고쳤다. 런타임 곡선 수치는 이 수정으로 변하지 않는다. Native 초기 스턴 fixture 오류(feedbackSeq 누락)는 테스트 상태를 보완했고 최초 로그를 보존한다. Studio MaterialManager 플러그인/203785492 asset-type 로그는 테스트 실패와 구분한다.

고정 빌드·실제 Client 입력·추가 검증은 최종 기록에 덧붙인다. 미검증: 실기기/네트워크 다인 성능, 서버↔클라이언트 지연 시각 수용, 지형 발 IK·분할 메시 경계의 최종 미술,5초 보스 스턴 밸런스. 실제 Roblox 게시/릴리스 태그는 수행하지 않는다. 다음 담당은 QA/DES다.

추가 `tests/k0-basic-attacks-native.luau`는933개를 통과했다(기본기/계열·중복 타격/서버 범위·영웅 전환 회귀). Blender 최종 [Goblin 공격 검토](blender-attack.png)는 부모 행렬 오류 수정 후 원본 파츠가 맞물리는 상태를 확인했다. 곡선 JSON SHA256은 수정 전후 동일한6bd7dd81bb7d13f87170619e8d1b96b2c4eebf875a59f51fc0a554d7389f15bd다.
