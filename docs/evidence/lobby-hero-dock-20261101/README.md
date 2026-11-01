# TLT-028/031/052/084 — TD 하단 영웅/PLAY 적용

2026-11-01 · 0.58.22 · 로컬 시험판, 미게시.

사용자 첨부 TD 화면과 현재 TD `LobbyHomeUI`/`LobbyHomeArt`를 비교해 하단 중앙 PLAY, HEROES, 영웅 카드, 이름표·선택 체크·파란 테두리, XP 표시를 적용했다. TD의 화면 크기별 카드/버튼 치수·간격·하단12px 규칙을4명에 적용했다. Knight → Elf → Dwarf → Mage 순서이며 Priestess는 제외한다. Mage는 `pyromancer` 대신 기존 `arcanist` 아틀라스 원본을 쓴다. 카드와 상세 영웅창을 같은 초상으로 맞추며 클래스 ID/이름과 전직 계약은 유지한다.

초기 영웅 상세창은 접고 하단 카드를 표시한다. 카드 클릭은 기존 서버 권위 CreateHero/SelectHero 절차를 사용한다. PLAY는 기존 모험/파티 선택창을 연다. 영웅이 없으면 기존 영웅창을 안내한다. 기존 하단 ADVENTURES 진입은 PLAY로 대체하고 왼쪽 HEROES 상세창과 훈련은 유지한다. SpawnFailed는 기존 재시도창을 연다. XP는 RPG InventoryState의 선택 영웅 progression만 표시하며 이전 영웅 값·오래된 revision은 표시하지 않는다. 다른 상세창·MENU·이동 잠금·전투에서는 하단을 숨긴다.

## 근거/원본

직접 지정된 TD의 기존 기능을 이식하는 작업이다. [원본 조사](../../research/2026-11-01-td-hero-dock.md), [원본 해시/파생 범위](td-source-provenance.json). TD 저장소·Experience·잔액·상품은 수정하지 않았다. 자산은 기존 공유 레지스트리/TDUI에 있는 원본을 재사용하며 신규 업로드는 없다.

## 검증

- `tests/lobby-hero-dock-native.luau`: 로컬 Edit에서47개 assertion 통과. 1920×1080 /1280×720 /844×390 /390×844 치수,4클래스, Arcanist crop, PLAY 원본, 실제 XP, 오래된 revision, 이전 영웅 XP 가림,7종 패널/잠금, busy, 전투/단계 가림을 확인했다.
- 첫 fixture 실행은 존재하지 않는 자식을 `.HomeXPFill`로 검사한 테스트 오류로 중단했다. 해당 불필요한 검사만 제거하고47개 검사를 통과했다. 제품 수정으로 통과시킨 것이 아니다.
- Studio 실제 Play: 로컬 `.0.58.16` 문서의 누적 수정 환경에 이번5개 클라이언트 모듈을 반영했다. 새 소스 전체 빌드 실행과 구분한다. 1392×707 뷰포트에서4초상 및 PLAY 이미지 로딩, Knight/Mage 카드 클릭 생성·선택, 기존 Knight 재선택, PLAY → 모험창, 닫기 → 하단 복원을 확인했다. 실제 Teleport는 실행하지 않았다. [도구 결과](studio-results.json) · [실제 화면](studio-desktop.jpg).
- 고정된 커밋으로 로비·배틀 빌드와 SHA-256을 기록한다: [빌드 결과](build.json).

실기기 터치/게임패드 사용성, 게시된 클라이언트/Teleport, 영구 저장/재접속은 이번 검증 범위 밖이다. 다음 담당 QA: 모바일 가로 실제 터치, 게임패드 포커스, 사용자 시각 수용. 기존 상위 티켓/릴리스 게이트는 완료로 변경하지 않는다.
