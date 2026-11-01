# TLT-028/031/052/084 — TD 하단 로비 원본 비교

확인일2026-11-01. 사용자가 직접 지정한 Throne Defense의 현재 로컬 원본과 첨부 화면을 조사했다. 외부 사례로 디자인을 바꾸는 작업이 아니라 지정된 원본의 치수/미술/입력을 재사용한다.

관찰: TD `LobbyHomeUI`는 PLAY → HEROES → 카드 → 레벨/XP를 하단 중앙에 놓고 화면 폭·높이에 따라 같은 치수 규칙을 사용한다. `LobbyHomeArt.enamel`은 금속 프레임/골드 안쪽/남색 내부와3겹 그림자를 구성하며 PLAY는 전용 아틀라스를 로딩한다. `SelectionCheck`는 폰트 대신2개 네이티브 스트로크를 쓴다. TD는5클래스 중 Mage의 `pyromancer` 초상을 사용한다. RPG는4플레이어 클래스와 별도 NPC Priestess 계약이다.

적용: 같은 프레임·이미지·폰트·치수 규칙을4카드에 적용하고 Mage 초상은 기존 공유 `arcanist` crop으로 교체한다. TD 전용 성장/선택 서비스 대신 RPG의 서버 권위 요청과 InventoryState progression을 사용한다. PLAY는 기존 RPG 모험/파티 선택창에 연결한다. 기존 HEROES 상세창은 계속 제공한다.

비용/위험: TD 아틀라스 사용 권한/로딩은 환경별 확인이 필요하다. 모바일의 실제 터치 영역과 게임패드 탐색은 별도 수용이 필요하다. 최소 실험으로 Studio 이미지 로딩·실제 카드 클릭·모험창 연결과4개 화면 규격의 native 배치/가림/XP 상태를 확인했다. 결과와 원본 경로/해시는 [증거](../evidence/lobby-hero-dock-20261101/README.md)에 기록한다.
