# Ember Caldera 로컬 구현

2026-10-31 · TLT-063/057/084 · ENG/ART/QA · 0.51.0 로컬 시험판, 미게시

## 플레이와 구현

Frozen Vale 완료 저장에서 EC-01로 이어진다. Ash Gate→Forge City→Collapsed Resonance Mine→Split Coolant Canals→Ancestral Design Vault→Geothermal Heart Testworks→Great Furnace의7본편과3선택 지역/4선택 퀘스트·7체크포인트를 구현했다. 최신 승인대로 광부 구조→냉각 복구→Magma Golem/Inferno Overlord 격파→도시 복구→열쇠를 쫓아 Gloamwood로 향하는 단서를 잇는다. Gloamwood 자체는 아직 미구현이다.

- 기존 EC 안정ID·고정3883XP/4640Gold와 기존 두 에픽 저장/선택을 유지한다. 선택 퀘스트 고정 예산0은 미확정 예산을 새로 배정하지 않는 시험값이며 처치 보상은 별도다. 클래스/전직/재화 공유 계약은 변경하지 않는다.
- 광부 Orik 개인 호위·거리/위협 시 정지·단계 저장, 솔로 순차 밸브/시험 장치, 수리 저장 확정 후 승강기의 도시 안전 체크포인트 이동을 연결했다. 도보 길도 제공하며 물리 승강기 탑승/다중 플레이어 동기화가 완성됐다고 보고하지 않는다.
- 지속 지반/넓은 현무암 길·용암 배경/광산 지지대/냉각 수로/도시 작업장/시험로/대용광로, NPC5명과 창고/기존 Selene 편성 게시판을 적용했다. 현재4인/AI전체1명 제한을 유지한다. 개인 완료 장치/용광로 복구색을 서버 저장 스냅샷에 따라 표시한다.
- Inferno Overlord는65%/30%에서 치명타를 단계 경계로 제한하고 유한 증원을 예약한다. 주황 지면 경고는 기존2초 예고/서버 피해 계약을 쓴다. 화산 보스는 격파 전투이며 Frozen Vale의 비살상 처리와 분리한다. 보스 격파 후 미보고/재접속도 저장된 목표에서 계속한다.

## TD 자산과 Blender

[원본/해시/삼각형/권한 범위](../../../assets/shared/td-ember-caldera/manifest.json): Imp/Lava Slime/Golem/Magma Worm/Volcano Shaman/Magma Imp/Magma Golem/Inferno Overlord/Caldera Titan/King Volcano Shaman10종을 현재 TD 런타임에서 추출했다. 메시·텍스처 ID와 원본 GLB/geometry를 고정하며 실행 코드를 반입하지 않는다. TD 운영 소스/게시/상품은 변경하지 않았다.

Blender MCP에서 별도 `TLT_EmberCaldera_Monsters_v1` 장면을 만들고70논리 클립/350 Action/채널당201표본을 제작했다. 대기/보행/일반2/강공격2/스턴,슬라임 압축/도약·벌레 몸 공격·주술사 시전·큰 적 준비/타격/회수와 원본 무기 끝 소켓을 적용했다. 서버 접촉 시점은.62표본에 대응한다. [모션 GLB](../../../assets/animations/ember-caldera-v1/ember-caldera-motion.glb) · [곡선/해시](../../../assets/animations/ember-caldera-v1/manifest.json).

현재 Blender의 다른 TD 작업 장면과 원본 파일을 보존했다. 활성 장면만 GLB로 내보내고 코드/JSON을 재현 원본으로 보존한다. 단일 GLB 리뷰 릴의 애니메이션 트랙 수와70개 논리 클립 수는 다르다. NLA: Idle0/Walk140/Attack280/AttackAlt420/Heavy560/HeavyAlt700/Stunned840,각120프레임,120fps.

재현: `python3 tools/prepare-ember-caldera-assets.py` → manifest를 INPUT 상수로 `tools/author-ember-caldera-motion.py`를 Blender MCP에서 실행 → scene의 ember_export/ember_sockets를 clips.json/sockets.json으로 수신 → `python3 tools/export-ember-caldera-motion.py`. 별도 Blender 프로세스로 동작을 합성하거나 새 Roblox 에셋을 업로드하지 않았다.

## 검증과 한계

최종 소스/빌드/SHA는 build.json,검사 결과는 final-validation.json과 각 로그에 기록한다. 미게시 로컬 Studio의 실제 지반/메시/관절/GUI·서버 콜백 검증과 가상 플레이어/계정 의존성을 구분한다. 가상 플레이어의 승강기 이동은 저장 후 이동 요청/목적지를 검증하는 mock이며 실제 플레이어의 CombatService 이동 수용은 후속이다. 일반 공격 타이밍/거리·영웅 전투 회귀는 별도 네이티브 검사로 확인한다.

미검증: 실제 플레이어 정상 전투 완주/Lv30 성장·실계정 장애 저장/재접속·PC/패드/터치 입력·4인+AI 성능·경사 IK·게시 Experience의 메시/텍스처 권한·최종 미술/난이도 수용. 지형/소품은 네이티브 파트 시험 미술이고, 손목/팔꿈치 스키닝과 독립 화염 투사체는 새로 완성하지 않았다. Lava Slime은 이번 버전에서 강체 압축/도약 동작이며 신규 분열 메커니즘은 미구현이다.

TLT-063/057/084 부모 작업은 In Progress를 유지한다. 다음 담당은 QA/DES이며 정상 입력·실기기·다인 수용을 진행한다. 일반 로컬 빌드이므로 Roblox 게시/릴리스 태그를 만들지 않는다. 관련 소스·자산·증거만 커밋/푸시하고 기존 미커밋 로비/이동 변경은 제외한다.

## 고정 빌드와 최종 결과

소스 `fb68f86`만 Git archive로 추출하고 모델9개의 LFS OID를 커밋과 대조해 Lobby/Battle0.51.0을 생성했다. 초기 미커밋 로비/이동 변경은 빌드에도 포함하지 않았다. [빌드/SHA256](build.json) · [최종 검사 요약](final-validation.json).

| 검사 | 실제 결과 |
| --- | --- |
| Ember Caldera 지반/연결길/10종 리그·30/60/144Hz·7본편/4선택·개인 광부 호위/장치/저장 후 이동 요청·보스 단계/유한 증원/정확한 중복 배제 보상·재개 목적지 | 4,300개 통과 |
| Frozen Vale7본편/4선택·비살상 보스·기존 저장·다음 에픽 진입 회귀 | 4,083개 통과 |
| 기존 Deepwood 동작/소켓·무기 회귀 | 3,122개 통과 |
| 기존 전투 타이밍·기본기/스킬·서버 피해 | 110 + 947개 통과 |
| 기존 퀘스트 UI·지도4크기·Selene 지원 | 5 + 91 + 33개 통과 |
| Ember Caldera 저널7스토리·선택4·지도30지역 | 40개 통과 |
| Ember 진행/자산 정적 | 598 + 71개 통과 |
| Frozen 진행/자산 정적 회귀 | 460 + 71개 통과 |
| 고정 소스 Lua 회귀 | 25개 중23개 통과.2개는 기존0.50.0 소스에서도 동일 mock API 누락으로 실패함을 재현 |

[신규 네이티브 결과](native.json) · [Frozen 회귀](frozen-vale-regression.json) · [기타 회귀](native-regressions.json) · [GUI 결과](ui-native.json) · [GUI 재현](ui-native.luau) · [Lua 전체](lua-specs.json) · [기존 오류 기준 재현](baseline-fixture-errors.json).

시험 과정에서 승강기 이동 검사가 처음 실패했다. 가상 플레이어는 실제 CombatService playerStates에 등록되지 않기 때문이었고, 테스트의 이동 의존성을 저장 확정/올바른 목적지를 검사하는 mock으로 교정했다. 실제 플레이어의 이동 수용을 통과로 바꾸지 않았다. Inferno Overlord의 원본 강체 분할에서 큰 팔 회전 시 이음새가 벌어져 준비 각도와 회전축을 보정했다. GLB 최초 내보내기의 다중 NLA 스트립 경고는 SCENE 릴 내보내기로 수정했고,최종42트랙/38메시·8초 릴을 확인했다.

![Blender MCP 강공격의 준비·타격·회수](inferno-heavy-review.png)

소스 푸시는 LFS13개22MB 전송을 포함해 성공했다. 증거 마감도 같은 원격 main에 푸시하며 Roblox 게시/릴리스 태그는 없다. 위 실계정/실기기/정상 전투·최종 수용 제한은 유지한다.
