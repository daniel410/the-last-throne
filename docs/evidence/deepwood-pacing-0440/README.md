# 0.44.0 유한 증원·보급·실제 능력치·무기 시각 v2

2026-10-31 · TLT-005/028/031/032/033/043/046/050/052/055/057/061/073/084 부분 구현. ENG/ART 자체 검증이며 상위 수용/QA 독립 게이트는 열려 있다.

## 플레이어 변화

Deepwood 일반 적 전체는 이전231→462명, 보스는5명으로 총467명이다. 메인/선택/보스 체력 증원 합산이며 총96유한 웨이브다. 초반2~3, 중반4~6, 후반7~9명 상한(보스 포함)과 짧은 진입 유예를 적용한다. 보스 조기 처치도 남은 증원을 건너뛰지 않는다. 교전 총 처치 XP/Gold·스토리 보상은 유지한다. 일부 개체 Gold는0이 될 수 있다.

TD 보스 곡 Throne Under Siege(120016858360297)를 개인 모험/거리/생존/보스 상태에 따라 전환한다. 새 영웅 MP 물약은 Mage만 지급하고 저장분은 보존한다. HP/MP 각4크기 구매와 All/Weapons/Armor/Accessories/Potions 필터를 추가했다. 원자 구매/재시도/스택 규칙을 유지한다. 가방 비교 밑에 실제5능력치 현재→선택과 증감을 보여준다. MP 보너스가 없는 현재 장비는0으로 표시한다.

기사 Azure Oathblade·드워프 Embercleaver·마법사 Ember Crown Staff의 최신 TD Meshy v2 모델/PBR을 실제 플레이어 외형 v2에 연결했다. 엘프는 기존 메시와 개선 활 변형/시위/화살 액션을 사용한다. 캐릭터 몸체 신규 제작은 아니다. [원본/해시/Blender](../../../assets/shared/td-refined-player-weapons/README.md) · [조사/판단](../../research/2026-10-31-deepwood-supplies-and-refined-weapons.md).

## 검증

순수 Lua11개 스위트 결과는 [pure-tests.json](pure-tests.json)과 개별 로그에 있다. 명령은 각 항목에 기록했다. 총량/보상/웨이브3103, 보스96, 진행570, 퀘스트31, 영웅656, 인벤토리265, 경제26, 새 물약170, 장비 영향44, 음악 정책13, 스탯 공식954개 통과.

네이티브 명령은 run-in-roblox --place <source fixture 또는 고정 Battle> --script tests/<name>.luau 이며 다음은 실제 Roblox 인스턴스/모듈 검사다.

| 검사 | 결과 | 범위 |
| --- | --- | --- |
| deepwood-service-native | 2455 통과 | 실제 몬스터·서버7메인/선택보스·웨이브 상한·중복/보상·조기 보스 사망 |
| deepwood-supplies-audio-native | 358 통과 | 실제 상점 GUI·4클래스/5카테고리/8물약·Sound/Tween 선택·두 곡 로딩 |
| inventory-impact-native | 32 통과 | 실제 가방 GUI의 비교 아래5개 능력치/부호/최대치 설명,4클래스 |
| refined-player-weapons-native | 116 통과 | 실제 새 메시/PBR·R6/R15·장착 관찰자·v1교체·소켓 복구·재장착·리스폰 |
| weapon-render-loop-native | 3 통과 | start()의 실제 두 프레임 콜백·반복 시작 보호 |
| 전체 무기 동작 회귀 | 29,549 통과 | 새 원본 포함 melee3204/Blender2772/dwarf1642/elf4844/mage17087 |

Studio0.43.4 실행 로그에서 bowRest의 제거된 캐시 참조가 매 프레임 오류를 내는 것을 발견하고 구식 정리 루프1줄을 제거했다. 새 프레임 검사로 동일 오류를 재현한 뒤 수정본3프레임 통과를 확인했다(render-loop-first.log/render-loop.log). 기존 동작 샘플 검사는 start() 콜백을 호출하지 않아 이 결함을 잡지 못했다.

초기 가방 검사 실패2회는 테스트 스냅샷의 opened/용량 누락이 원인으로 테스트 입력을 수정했다. 초기 오디오 시간 경과 볼륨 검사는 Studio 편집 시간에서 Tween이 진행하지 않아 실패했다. Sound/Tween 생성·선택 검증으로 범위를 명시하고 시간별 음량은 아래 실제 Client 검사에서 후속 확인했고 청취 수용은 남겨 두었다. 최초 실패 로그를 보존한다. 기존 아이콘203785492의 자산 유형 경고는 이번 검사에도 나타났으며 원본 아이콘 문제는 이번 범위 밖이다.

초기 service fixture는 native-source-manifest.json에 해시를 기록했다. 최종 고정 Battle에서 서비스2455·부트10·상점/오디오358·가방32·무기116·프레임3개를 다시 통과했다. 전체 동작29,549개도 수정된 프레임 코드로 재검사했다. [최종 명령/결과](final-native.json), [최종 서비스](final-service.log), [소스 일치](source-verification.json)에 연결하며 motion fixture26개 입력 해시와 두 빌드의 변경14개 모듈 일치를 확인했다. 버전 없는 QA fixture를 릴리스라고 부르지 않는다.

Blender MCP 내부 API로 새 무기 검토 씬을 가져오기/배치/저장했다. weapons-review/save 호출과 결과·refined-weapons-blender.png가 증거다. 새 업로드/TD 수정은 없다. 모델 네이티브 로딩과 보스 곡 IsLoaded=true/60초는 로컬 Studio에서 확인했다.

## 빌드와 남은 수용

VERSION0.44.0/소스30074afc2fbc68d7c7c885ef80808333ce9d2c63을 고정해 Rojo7.7.1로 Lobby/Battle을 만들었다. [build.json](build.json)에 명령·산출물 SHA-256·입력 LFS7개를 기록했다. 소스 main 푸시와 새 LFS3개/62MB 전송 및 원격 커밋 일치를 확인했다. [Lobby](../../../builds/0.44.0/TheLastThrone-Lobby-0.44.0.rbxlx) / [Battle](../../../builds/0.44.0/TheLastThrone-Battle-0.44.0.rbxlx). 로컬 시험판이며 이번 작업은 Roblox 게시/릴리스 태그를 만들지 않는다.

실제 게시 RPG 클라이언트의 메시/오디오 권한, 물리적 청취, Lv1 솔로 정상7스토리 전투 시간·사망률,4인+AI1/저사양 FPS, 실제 Gold 구매/판매 입력·모바일 화면, 주관적 무기 자연스러움·최종 미술 수용은 미검증이다. 자동 엔진 fixture의 fake Player/스냅샷은 실제 계정 저장/입력 수용을 대신하지 않는다. 다음 QA/디자인/기획은 이 조건을 같은 고정 빌드로 확인한다.

## 실제 Studio Client 확인

새 Lobby0.44.0을 별도 Studio로 열어 실제 Player에 네 클래스를 정상 요청으로 생성했다. 각 영웅이 훈련장으로 정상 입장하고 새 모델 MeshId/서버 승인 Attack 상태를 확인했다. Mage의 지팡이 초점도 생성됐다. 동일 세션의 실제 InventoryRequest/InventoryState로 Knight/Elf/Dwarf의 최초MP 물약0개·Mage7개를 확인했다. 영웅 생성/장면/재접속 테스트는 Studio 세션 저장이며 실제 계정 영구 저장은 아니다. [Client 결과](studio-client.json).

상점 열기→POTIONS·가방 열기→Tempered Axe 선택→세부 스크롤을 실제 버튼/휠 입력으로 확인했다. 드워프 실제 비교는 Physical/Magic Attack100→110(+10), Defense0→0, Max HP200→200, Max MP0→0이었다. [드워프 플레이](client-dwarf.jpg) · [물약 카테고리](client-potion-shop.jpg) · [가방5능력치](client-bag-impact-full.jpg). Gold0 세션이므로 실제 구매 입력 성공을 주장하지 않는다.

실제 Client의 별도 테스트 Sound 이름으로 production create()를 사용해1.7초 간격 전환을 확인했다. 일반곡 Volume0.2/보스0 → 일반0/보스0.2 → 일반0.2/보스0이고 비선택 곡은 일시정지됐다. 실제 원본 곡 로딩·재생/시간별 Tween 검증이며 보스 진행과의 전체 정상 전투 청취 수용은 아니다. 테스트 Sound/모듈은 제거하고 기본 게임 카메라도 복구했다.

직접 Server MCP에서 InventoryService.snapshot을 호출한 진단은 plugin require()의 별도 모듈 상태 때문에 settings가 없어 실패했다. 정상 Client Remote 요청은 성공했으며 이 진단 오류는 studio-client.json에 기록했다. 새로운 플레이의 console에는 기존 아이콘 유형 경고·이 단일 진단 오류 외 bowRest 반복 오류가 없었다. 최종 푸시 뒤 다음 QA/디자인/기획이 위 남은 수용을 담당한다.
