# 로비 메뉴·QUEST 통일·포션 키/수량 가독성

2026-11-01 · TLT-028/031/043/050/061/084 · DES/ENG → QA · 0.58.36 로컬 시험판

사용자의 이어진3개 요청을 반영한다. SKILLS·전직 통합은 앞선0.58.35에 포함돼 이번 빌드에서도 유지한다.

- 포션 카드의 작은 Z/C 글자와 수량을 불투명 잉크색·테두리·굵은 글꼴 배지로 교체했다. 키16px/24px 높이,수량14px/24px 높이이며 아이템 그림 위에 그린다. 키는 이름 바로 위 왼쪽,수량은 위 오른쪽에 표시한다. Z/C 동시 배정·미배정·잠금·99개 물약·999개 재료를 구분한다. 잠금은 기존 LOCK 표기를 보존한다. 선택한 포션 상세 정보에도16px 키 안내와 QUANTITY를 추가했다. 배정·사용·서버 소유권 계약은 유지한다.
- 로비 MENU·배틀 추가 메뉴·모바일 라벨·로비/본편 퀘스트 화면 제목과J 안내를 QUEST로 통일했다. 기존 J단축키·내부 Journal 액션/데이터ID와 Chronicle 기록 하위 탭은 유지한다. 메뉴 이름을 바꾸는 작업이며 저장 스키마/퀘스트 진행을 변경하지 않는다.
- TD UIController의 메뉴 리스트를 읽어 SUPPLIES의 Diamond Shop과 PROGRESS의 Login Rewards(기존 왼쪽 REWORDS와 같은 목적지)를 추가했다. 기존 TD shop/login_rewards 원본 아이콘·52px 행·프레임/섹션 문법을 재사용한다. 6행이 있는 데스크톱 최대 높이452px,작은 화면에서는 기존 스크롤로 줄어든다. 기존 가방·상태·QUEST·설정과 왼쪽 아이콘은 유지한다. init → LobbyMenuBridge → LobbyCommerce의 기존 상점/보상 열기로 연결하고 거점 상태를 확인한다. 구매/수령을 자동 실행하지 않는다.

TD 참조의 경로/해시는 td-source.json에 남겼다. TD UIIconAssets 전체 파일은 RPG의 고정본과 해시가 다르지만, 이번에 재사용한 shop/login_rewards의 atlas/image/영역은 현재 TD와 동일함을 확인했다. TD 운영 소스는 수정하지 않았다. 새 그림은 생성하지 않았다. [TD 적용 조사](../../research/2026-11-01-td-lobby-menu-shortcuts.md).

검증: 격리 SkillsAdvancementQA Studio Edit native8종 합계322개, Lua inventory271·daily-login73 통과. 배지의 색/굵기/크기/실제 TextFits·셀 경계·아이템 이름과 겹침 없음·Z/C/수량/잠금,기존 보상 중복 방지·QUEST/배틀/가방 회귀를 검사했다. 기존 실제 Play 컨트롤러와 로컬 RemoteEvents/합성 스냅샷으로 메뉴 Diamond Shop/Login Rewards/QUEST를 실제 클릭해 기존 목적지가 열리는 것을 확인했다. 계정 서버나 DataStore는 없고 구매/보상 수령은 실행하지 않았다. 포션 클릭 시 Quick slot: Z / QUANTITY: 99,두 텍스트16px를 확인했다. [메뉴 실제 화면](menu.jpg) · [포션 실제 화면](potions.jpg).

Device Simulator iPhone17 Pro 가로에서 실제 보고 viewport750×381,메뉴232×255/스크롤452를 확인했다. 모든 메뉴 캡션이 들어가고 마지막 Settings까지 스크롤로 접근했다. 기본 viewport를 복원하고 Play를 중지한 후 이번 임시 fixture PID34356만 종료한다. 사용자의0.58.34 Studio는 건드리지 않는다. 실제 기기·게시 클라이언트·정상 계정 저장·독립 QA/사용자 수용은 미검증이다. 다음 담당 QA는 새 빌드에서 실기기 가독성과 정상 진입/수령을 확인하며 상위 티켓은 닫지 않는다.

검사 한계: fixture에서 InventoryOpenStorage 이벤트를 생략해 InventoryState 구독 후 대기 경고가 났다. 실제 계정/창고 회귀를 이 Play로 통과시키지 않는다. 원래 자산 타입/일부HTTP502 경고가 있었으나 새 메뉴 아이콘과 포션 아트는 캡처에서 렌더됐다. 최초 새 배지 fixture의 Equipment 필터 가정을 All로 수정한 후75개가 통과했고,1405275자짜리 변경 없는 모듈의 Source 재할당 제한은 변경한 모듈만 할당하도록 수정해 우회했다. 결과는 native.json을 따른다.

고정 소스 Lobby/Battle 빌드와 SHA-256은 build.json에 기록한다. 미게시·릴리스 태그 없음. 다른 미커밋 작업은 포함하지 않는다.
