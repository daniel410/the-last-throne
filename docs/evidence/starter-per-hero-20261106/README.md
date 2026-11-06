# 시작 보급을 영웅마다 최초1회 지급

2026-11-06 · TLT-029/041/043/052/084 · ENG → QA · 0.78.2 · 부모 티켓 In Progress.

## 원인과 승인

사용자는 “기존 시작 장비 세트와 물약이 수정 빌드에 없다”고 보고했다. 실행 중인 `TheLastThrone-0.78.1.rbxlx` Client의 읽기 전용 Inventory GetState 응답에서 Mage와 Knight2명, 선택 Knight의 가방0/기본 검·방패만 보유를 확인했다. 계정 첫 영웅만 보급하던 앞선 해석 때문에 두 번째 영웅이 빠졌다. 사용자는 **영웅마다 최초1회 지급**을 확인했다. 원인이 명확한 지급 조건 수정이므로 별도 게임성 비교 조사는 하지 않았다.

## 변경

- `InventoryRules.addHero`는 계정 첫 영웅 여부와 무관하게 각 신규 영웅에게 기존 보급을 지급한다. Training 기본 무기/기사 방패·Tempered 무기·기존7종 키트·HP Small3/Medium2/Large1/XL1·Mage MP동일7개·Iron Ore24/Soft Hide8 구성은 유지한다. HP/MP 자연회복·추가 미수령HP5개·퀘스트 보상은 변경하지 않는다.
- `hero.starterSuppliesClaimed`를 보급 아이템과 같은 계정 갱신에 저장한다. 같은 클래스 재생성·기존 heroId 덮어쓰기를 거절하며 재접속·선택·소진으로 지급하지 않는다. 계정의 기존 수령표시는 하위 호환용으로 보존한다. 마이그레이션은 기존 영웅의 수령표시를 기록하고 아이템을 보충하지 않는다.
- 기존 저장은 소진/폐기 후 물품과 미수령을 구별할 원본 영수증이 없어 자동 복구하지 않는다. 실제 저장의 누락 복구에는 별도 지급 이력 확인이 필요하다. 현재 확인한 Studio는 세션 어댑터이므로 새 빌드 새 Play에서 생성한 영웅마다 정상 지급한다. 실행 중인0.78.1 세션 데이터는 수정하지 않았다.
- AGENTS·결정표·README/plan/backlog 최신 진입점에 계정1회에서 영웅1회로 정정했다. 이전 증거 문서는 당시 상태로 보존한다.

## 검증

- `lua tests/starter-potions-and-shop.spec.lua`:316검사 PASS.4클래스 최초 지급·12가지 후속 생성 순서·영웅별 수령표시·중복 클래스/ID 거부·소진/재접속 무보충·기존 아이템 보존·구매 원자성/불명 저장 복구를 검사한다.
- `lua tests/inventory.spec.lua`:271검사 PASS.
- `lua tests/hero-progression.spec.lua`:656검사 PASS.
- `lua tests/advanced-skills.spec.lua`:1435검사 PASS. 합계2678검사.
- Studio0.78.0 Edit에서 수정 InventoryRules 소스 전체를 loadstring/실행한 순수 fixture: Mage→Knight 둘 다 물약/장비 지급·프로필 유효성·재개방 무변경·소진 후 무보충·중복 생성 거절 PASS. 실제 계정/DataModel은 변경하지 않았다.
- `git diff --check` 통과. 입력 소스 `f1bcb5232a852987f50843f045812ed6d045a00d`를 커밋·푸시한 뒤0.78.2 단일 빌드 성공. [build.json](build.json)에 버전·소스·산출물 SHA-256을 기록했다. 실제 산출물 역할10/로딩108검사 PASS 및 XML InventoryRules Source가 검증한 파일과 바이트 일치함을 확인했다. 수정 빌드를 OS 열기 명령으로 Studio에 열었다. 미게시이며 릴리스 태그 없음.

## 다음 담당과 미검증

0.78.2를 Studio에 열고 새 Play에서 실제 CreateHero RemoteEvent로 Mage→Knight를 생성했다. 두 번째 Knight 가방14칸·HP물약3/2/1/1·Tempered Sword1, Mage 가방18칸·HP/MP Small3·Tempered Staff1 지급 PASS. 실제 SelectHero로 Mage→Knight 왕복 후 가방14칸·Small HP3 유지 PASS. 클라이언트 가방 렌더링도 `BAG  14 / 60`과 HP물약4등급 이름을 확인했다. [Studio Client 결과](studio-client.json). 자동 B키 입력 뒤 가방 열림 속성은false였으므로 키를 통한 열림 수용은 통과로 보고하지 않는다. 새 빌드 Play는 Knight 선택 상태로 남겼다. QA의 물약 사용/장비 장착·재접속 및 실제 게시 DataStore/실기기/운영 계정 누락 복구·Place 게시·릴리스 태그는 미실행이다. 새 빌드와 이전 실행 세션을 구별한다.
