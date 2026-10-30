# Deepwood 보스전 호위·증원 확대

2026-10-29 · TLT-014/027/041/050/052/061/084 · PLAN/ENG → QA. [사용자 요청·조사·구성표](../../../research/2026-10-29-boss-populations.md) · [빌드0.35.2](../../../../builds/0.35.2/TheLastThrone-0.35.2.rbxlx) · [입력/해시](build.json) · [LFS 대조](inputs.json). 미게시·릴리스 태그 없음.

최종 검증/기록 마감: 2026-10-30 America/Toronto.

## 변경

기존 보스 포함 최대2/3/3/1/3마리였던 Orc Warlord / King Shaman / Goblin King / King Ogre / Enraged Warlord를 **7/10/9/8/12마리**로 늘렸다. 시작4/4/6/5/6마리와 체력 구간별3마리 증원1~2회다. TD Goblin/Orc/Shaman의 기존 원본과 전투 행동을 사용한다. 일반 필드전 수와 보스 HP/공격력은 유지한다.

각 증원은 시도당 한 번이며 등장 후 약1.43~1.79초 준비 시간과 영어 안내를 준다. 보스만 처치하고 호위가 살아 있으면 완료하지 않는다. 기존 King Shaman 방패/기둥·최종 국면과 구출 지원을 유지한다. 승인 초회 XP1,173/Coins2,290·아이템은 보존하며 추가 정상 처치의 기존 처치 XP/Coins는 늘어난다. 무한 시간제 소환은 추가하지 않았다.

## 검증

커밋 `e428193`을 원격에 푸시한 뒤 Git archive로 입력을 분리했다. Rojo7.7.1, 매핑 LFS5파일의 SHA256을 해당 커밋의 포인터와 대조했다. 빌드1,483,901bytes·SHA256은 [메타데이터](build.json)에 기록했다.

| 명령/조건 | 결과 |
| --- | --- |
| 고정 소스 `lua tests/deepwood-bosses.spec.lua` | **96개 통과**: 다섯 초기/전체 수·유한/내림차순 체력 구간·지원 레벨/일반전 불변·초회 XP/저장 형식. [로그](pure.log) |
| 같은 입력 `deepwood-progress.spec.lua` / `deepwood-quests.spec.lua` | **570 /31개 통과**, 승인 보상·진행/수주·단서 계약 회귀. [로그](pure.log) |
| `run-in-roblox --place builds/0.35.2/TheLastThrone-0.35.2.rbxlx --script <고정 소스>/tests/deepwood-service-native.luau` | **126개 통과·실행기 종료0**. 실제 TD 리그/CombatService 사망 콜백,7본편+4선택 진행·다섯 보스 초기/전체 수·체력 증원 중복 거부·공격 준비·보스 먼저 사망 시 미완료·전 호위 처치 후 완료/보고·초회 Coins 불변. [로그](service.log) |
| 같은 빌드 + `tests/deepwood-native.luau` | **615개 통과·실행기 종료0**, 실제 월드·TD 원본 리그·서버 진행 계약 회귀.58목표/60활동 유지. [로그](world.log) |

서버 검사는 Player/계정 대역을 사용하고 적 HP/사망을 시험에서 직접 조작한다. 실제 플레이어가 정상 공격으로 확대된 보스전을 완주했다는 증거가 아니다. 기존 `203785492` 자산 타입 경고는 별개로 남아 있다. 초기 sandbox 실행은 Studio 플러그인 파일 생성 권한으로 실행 전 실패했고, 승인된 실행 권한으로 재시도했다.

## 미검증·다음 담당

QA는 정상 성장의 네 클래스 솔로/4인 전멸률·전투 시간·광역 기술/방어/회피의 효용, 모바일 프레임과 경고 가독성, 추가 처치 XP/Coins의 성장 속도를 관찰한다. 보스전의 최종 난이도·재미·실기기 성능 수용은 남아 있다. 확대된 수주/저널과 보스전은 상위 티켓의 부분 구현이며 Done으로 바꾸지 않는다.
