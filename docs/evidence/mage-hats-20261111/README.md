# Mage Hat 4종 게임 등록

2026-11-11 · TLT-028/029/032/041/052/057/084 · 0.101.0 · ENG

사용자가 새로 추가한 Traveler/Tempered/Veteran/Sentinel Mage Hat PNG를 마법사 전용 머리 장비로 등록한다. [원본](../../../assets/concepts/2026-11-11-mage-hats-v1/README.md), [PNG 해시/아이템 연결](artwork.json), [업로드](uploaded.json), [리서치](../../research/2026-11-11-mage-hats.md).

| 안정 ID | 요구 레벨 / 희귀도 | 방어력 | 구매 |
| --- | --- | --- | --- |
| mage_traveler_hat | 1 / Common | 3 | 신규 마법사 최초 지급·착용 |
| mage_tempered_hat | 1 / Common | 6 | 300 Gold |
| mage_veteran_hat | 10 / Uncommon | 15 | 800 Gold |
| mage_sentinel_hat | 10 / Rare | 30 | 42 Diamonds |

기존 가족별 머리 장비 가격/능력치 정본을 사용한다. 서버의 클래스·레벨·소유권·거래/강화 규칙에 연결하며 특수 효과는 자동 배정하지 않는다. 기존 영웅의 후드·강화/잠금·잔액·영수증·Lv5 보너스 Veteran Hood는 보존한다. 새 마법사의 Traveler Hood 지급 자리만 Traveler Mage Hat으로 바꾸므로 추가 지급은 없다. 기존 계정 로드에 자동 모자 지급이나 후드 삭제를 추가하지 않는다.

PNG는 가방/상세·창고/미수령·PC/모바일 기어·대장간·강화의 공통 ItemSpriteAtlas에 등록했다. 기존 클래스별 헬멧/엘프 후드·다른 장비 이미지는 유지한다. 이 작업은 2D 메뉴와 실제 장비 데이터 연결이며 캐릭터 머리의 착용 3D 메시 제작은 별도다.

## 검증

- `lua tests/mage-hats.spec.lua`:22검사, 신규 마법사 기본 착용·서버 다른 클래스 거부·8슬롯 내 장착·재시도·후드 보유품 보존 통과.
- `lua tests/equipment-families.spec.lua`:492검사 통과.44개 계열 정의의 획득/착용·레벨/수치·저장 이관 회귀.
- `lua tests/starter-gear-balance.spec.lua`:206검사 통과. 기존4클래스 총 능력치·최초 지급 계약 유지.
- `lua tests/blacksmith-stock.spec.lua`:487검사 통과.36개 구매 가능 상품·서버 가격/통화·구매/판매 재시도.
- `lua tests/enhancement-current-equipment.spec.lua`:47개 장비·9단계 성공/실패 경계8,792검사 통과.
- `lua tests/inventory.spec.lua`:274검사, `lua tests/economy.spec.lua`:38검사 통과.
- PNG4개 업로드/최종 Approved 확인. Tempered는 최초 Reviewing 이후 `/assets/v1/assets/98802336961905` 재조회에서 Approved를 확인했다.

고정 소스 `9f4ee10109bb5f4954a4aecd83b48ff8df439394`, 버전0.101.0. [빌드 기록](build.json), SHA256 `5dd9181de85a12dba89d994cb31ddb2e3979cb015f366e918ccd64b37396b35b`.

- `run-in-roblox --place builds/0.101.0/TheLastThrone-0.101.0.rbxlx --script tests/four-family-armor-icons-native.luau`:275검사 통과. 모자4개 포함36개 이미지 ContentProvider Success. 실제 메뉴 생성기로 마법사 모자4개를 대장간/강화·가방/상세/착용·창고/미수령·PC/모바일 기어에서 검사했다. 다른3클래스 이미지 회귀 포함. [결과](native.json) / [원문](native.log). 로컬 복제 모듈의 테스트용 입력/원격 파사드를 사용한 엔진 검증이며 실제 유저 조작/기기 검증은 아니다.
- `python3 tests/single-build.spec.py --artifact builds/0.101.0/TheLastThrone-0.101.0.rbxlx`: 역할10/도착192·프로젝트/실제 산출물 검사 통과.
- [보존 검사](preservation.json): PNG4개 원본 해시·기존 Atlas 모든 행 유지 확인. 새 PNG 업로드만 수행해 추가 LFS 원본은 없다.

 실제 게시 클라이언트·실기기/미술 수용은 미검증이다. Place 게시/릴리스 태그는 수행하지 않는다. 다음 담당은 UI QA/3D ART다.

## MCP 권한 원인과 운영

Studio 전체 종료/재시작 뒤에도 로컬0.100.3의 Open Cloud asset:read 거부가 재현됐다. [Roblox 공식 문서](https://create.roblox.com/docs/studio/mcp-open-cloud)는 권한이 사용자·게임별로 저장되며 미게시 로컬 Place는 사용할 수 없다고 명시한다. 기존 TLT 클라우드 Place70829337938054/Universe10773575153로 연결한 뒤 asset:read/write GET 검사200과4개 PNG 업로드가 통과했다. 기존 허가가 사라진 것이 아니며 새 로컬 빌드마다 권한을 다시 요청할 필요가 없다. 업로드는 기존 TLT 클라우드 연결, 네이티브 검증은 로컬 고정 빌드를 사용한다.
