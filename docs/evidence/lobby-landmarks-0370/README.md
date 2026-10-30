# Dawnspire 원정 포탈·훈련장·대장간

2026-10-30 · TLT-011/028/040/041/042/053/084 · DES/ENG → QA/DIR.
[컨셉 적용/조사](../../research/2026-10-30-dawnspire-facilities.md) · [재화·원정 계약](../../production/lobby-economy-and-expeditions.md).

최신 로컬 시험판은 **0.37.1**, 소스 `17f49ee8f77af2bbd0bfeb72181597e50711d199`이다. [Lobby](../../../builds/0.37.1/TheLastThrone-Lobby-0.37.1.rbxlx) · [Battle](../../../builds/0.37.1/TheLastThrone-Battle-0.37.1.rbxlx) · [최신 빌드/해시](0371-build.json) · [매핑 LFS5파일 대조](0371-inputs.json). 미게시·릴리스 태그 없음. 이전0.37.0의 [메타데이터](build.json)/[입력](inputs.json)도 보존한다.

## 변경과 조작

- **원정 포탈:** 안뜰 왼쪽 뒤 석조 아치·보라색 막·회전 룬7개·금색 왕관 간판. 가까이서 **F / 패드 X / 터치** → 기존 Solo/2~4인 원정 메뉴. 포탈 접촉만으로 출발하지 않는다.
- **훈련장:** 왼쪽 앞 모래 바닥·울타리·과녁3개·허수아비3개·교차 검 간판. 입구에서 같은 입력 → 선택 영웅의 기존 전투 훈련장. 영웅 소유·준비·로비·파티/이동 잠금 검사를 재사용한다. 로비 허수아비는 장식이고 실제 전투 연습은 입장 후 기존 훈련 적으로 한다.
- **대장간:** 오른쪽 파란 지붕·금색 테두리·화로/불꽃·굴뚝·모루·망치·상인과 TD 무기 원본 전시4개. 카운터에서 같은 입력 → 기존 Gold/Diamonds 무기 구매·Gold 매각. 제작/강화는 이번 구현 범위가 아니다.

기존 안뜰160×160·스폰·안전벽/창고를 유지하고 접근 길과 후면 클래스 배너 배치를 조정했다. 네이티브 지오메트리와 기존 TD 무기/공통 UI를 사용한다. 외부 자산 업로드·TD Place/소스·잔액 변경은 없다. 각 시설은 서버에서 실제 거리·생명·생성 준비·로비/여행 잠금을 검사한다. 룬 회전은 근거리 클라이언트20Hz이며 장식은 충돌/공격 쿼리를 막지 않는다.

![실제 로비 세 시설](overview.png)

이 전체 화면은0.37.0의 실제 Studio Player에서 카메라만 높여 촬영했다.0.37.1의 시설/배치/초기화/서버 접근 코드가 같음을 [SHA256 대조](unchanged-facilities.json)로 확인한다. 컨셉 전체 왕성이나 최종 미술 수용을 의미하지 않는다.

## 검증

소스/VERSION 커밋·원격 푸시 후 Git archive로 고정하고 LFS5개를 해당 포인터 해시와 대조했다. Rojo7.7.1로 Lobby/Battle 빌드를 각각 만들었다. 아래 Studio 실행기 검사는 모두 **종료0**이다.

| 명령/환경 | 결과 |
| --- | --- |
|0.37.1 Lobby + `tests/lobby-landmarks-native.luau` | **194개 통과**. 실제 지오메트리/영문 간판·접근 바닥/통행 raycast·수직 포탈·TD 전시·실제 서비스 콜백과 Player 대역으로 정상/먼 위치/모험/여행/사망/미준비 거부. [로그](0371-native.log) |
| 같은 Lobby + `tests/lobby-services-native.luau` | **132개 통과**. 전체 모듈/진입점 컴파일·GUI/상점·실제 TD 전시·20/4명 입장 대역. [로그](0371-services.log) |
| 같은 Lobby + `tests/expedition-service-native.luau` | **13개 통과**. 포탈 메뉴 열기/로비 외 거부·같은 예약 목적지·개인 티켓·전체 출발 잠금·부분 실패 복구/리조인. 실제 Teleport는 대역이다. [로그](0371-expedition.log) |
| 고정 소스 `lua tests/{economy,expedition-store,inventory,hero-progression,k0-hero-session}.spec.lua` 각각 | **26/43/265/81/97개 통과**. [로그](0371-pure.log) |
|0.37.0 Battle + `tests/battle-bootstrap-native.luau` | **10개 통과**, Lobby 미구성·캠페인/리모트 시작. 후속 버전의 서버 초기화/시설 코드 동일. [로그](battle.log) |
| 실제 Studio Player0.37.0 | 정상 Knight 생성/선택 클릭·포탈 F로 원정 메뉴·대장간 F로 상점·훈련 F로 Tutorial/Training 경로 진입. [원정 화면](portal-f.png) · [상점 화면](blacksmith-f.png) · [관찰](actual-player.json) |
| 실제 Studio Player0.37.1 | 정상 Knight 생성/선택과 훈련장 F 진입 재확인. `Tutorial / Training / knight`, `TRAINING GROUNDS / HERO PRACTICE`2개 및 잘못된 `EPIC 1 COMPLETE`0개 확인. [수정 화면](training-0371.png) |

Player는 QA 서버에서 각 시설 접근 지점으로 이동시켰고 이후 F키/버튼은 정상 입력을 사용했다. 시설 간 정상 도보 입력·실제 게시 이동을 모두 검증했다는 뜻은 아니다. 거래의 실제 구매/판매 근거는 [이전0.36.0](../lobby-0360/README.md)과 이번 순수/네이티브 회귀를 구분한다. 실행 후 Play와 시험 bridge는 명시적으로 정지했다.

## 발견·수정과 남은 수용

0.37.0 실제 Player에서 훈련장 HUD가 `EPIC 1 COMPLETE`로 되돌아가는 기존 문제를 발견했다. 훈련 응답 render 뒤에 호출하던 tracker가 이를 덮어쓰던 원인이었으며0.37.1에서 훈련/미준비 응답을 분기하고 훈련 제목·조작 목표를 유지한다. [이전 화면](training-0370.png)과 수정 화면을 보존한다.

최초 시설 검사의194번째 검사는 BindableEvent가 Player 대역 테이블을 복사하여 원래 테이블의 notice를 검사한 시험 오류였다. QA 서비스의 outgoing notice를 기록하도록 수정했다. [초기 실패](initial-landmark-fixture-failure.log). 최초 원정 회귀는 계측 시 publish~advertise 사이에 새 openMenu까지 지워버린 시험 오류였으며 계측 경계를 고쳤다. [초기 실패](initial-expedition-fixture-failure.log). 두 경우 게임 소스를 바꿔 통과시키지 않았다. 최신 빌드에는 수정된 시험 소스가 커밋돼 있다.

MCP의 특권 require를 이용한 최초 계정 읽기는 별도 모듈 문맥이라 settings nil 오류가 났다. 일반 서버 Script로 실제 실행 문맥에서 계정 준비/선택 Knight를 재확인했으며 게임 부트스트랩 오류와 구분한다. 기존203785492 자산 타입 경고·Roblox MaterialManager의 profileEnd 진단도 남아 있다.

QA/DIR 후속: 모바일/패드 조작·20명 부하·최종 미술 수용·정상 도보 가독성/카메라. 전투 Place ID는 계속0이다. Studio 강제 재시작 후 임시 API 생성 재시도는403으로 실패했고 API 접근은 OFF로 복구했다. 직접 새 Place 저장은 자산 사용 권한 승인 대기 상태다. [최신 과정/화면](../battle-place-provisioning/README.md). **게시 원정 이동/서버 간 파티/리조인은 여전히 미검증이고 최신 소스도 미게시다.** 이번 시설 구현으로 상위 티켓/출시 게이트를 Done으로 바꾸지 않는다.
