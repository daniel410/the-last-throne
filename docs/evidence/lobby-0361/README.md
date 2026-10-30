# 출발 명단 잠금·저장 lease 복구0.36.1

2026-10-30 · TLT-016/041/047/053/084 · ENG → QA/DIR.
[이전 실제 Player/설정 증거](../lobby-0360/README.md) · [실행 계약](../../production/lobby-economy-and-expeditions.md) · [고정 입력/해시](build.json) · [LFS 대조](inputs.json).

최신 로컬 빌드는 **0.36.1**, 소스 `0c793a08f52cb4d35a0fd379454e73b7df384180`이다. 소스/VERSION 원격 푸시 뒤 Git archive로 분리하고 매핑 LFS5개를 커밋 포인터와 대조해 Rojo7.7.1로 만들었다. [Lobby](../../../builds/0.36.1/TheLastThrone-Lobby-0.36.1.rbxlx) · [Battle](../../../builds/0.36.1/TheLastThrone-Battle-0.36.1.rbxlx). 미게시·릴리스 태그 없음.

출발 시 MemoryStore/DataStore가 yield하기 전에 전체 로컬 파티원 영웅을 잠근다. 저장 lease 해제 결과가 불명하면 이전 캐시를 계속 사용하지 않고 같은 계정 소유를 안전하게 재확보한다. 다른 서버가 이미 소유하면 입력을 풀지 않는다. 이전0.36.0의 지갑·상점·원정 구현과 UI는 유지한다.

| 명령/조건 | 결과 |
| --- | --- |
| 고정 소스 `lua tests/economy.spec.lua` | **26개 통과**. 구매/판매 중복·용량·가격·소유권·이전·저장 장애·해제 불명 복구. [로그](pure.log) |
| 같은 소스 `expedition-store.spec.lua` | **43개 통과**, 좌석/토큰·출발·가짜 티켓·lease/리조인 경쟁. [로그](pure.log) |
| 같은 소스 inventory / hero-progression / deepwood-progress / quests / bosses / hero-session | **265/81/570/31/96/97개 통과**. [로그](pure.log) |
| Lobby + `expedition-service-native.luau` | **11개·실행기 종료0**. 실제 서비스 소스와 네이티브 TeleportOptions, Player/Teleport/저장 대역으로2인 같은 예약 목적지·개인 티켓·전원 영웅 잠금·부분 실패의 개인 복구·같은 티켓 재시도·리조인 권한. [로그](expedition.log) |
| Lobby + `lobby-services-native.luau` | **126개·실행기 종료0**, 컴파일/GUI·실제 TD 무기 전시·20/4명 입장 대역. [로그](native.log) |
| Battle + `battle-bootstrap-native.luau` | **10개·실행기 종료0**. 로비 미구성·캠페인/리모트 시작 검사이며 실제 입장과 구분한다. [로그](battle-boot.log) |

실행기는 sandbox의 Roblox Plugins 폴더 쓰기 제한으로 최초 실행 전 실패했다. 격리된 RPG 빌드 실행 권한으로 재시도했다. Roblox MaterialManager 플러그인의 profileEnd 진단과 기존203785492 자산 타입 경고는 게임 검사 실패와 구분한다. 이전 광범위 테스트의 기존 대역 누락2건은 [0.36.0 기록](../lobby-0360/README.md)을 따른다.

**미완료:** 별도 Battle Place 없음·ID0, 생성에 필요한 Studio API 접근 일시 허용 여부 대기. RPG 로비 최대 인원20 설정만 저장됐고 최신 게임 소스는 게시하지 않았다. 실제 게시 Solo 왕복·타 로비 합류·2~4인·재접속/저장 장애·실기기·20명 부하 수용은 QA/DIR 후속이다. 상위 티켓은 부분 구현이며 Done으로 바꾸지 않는다.
