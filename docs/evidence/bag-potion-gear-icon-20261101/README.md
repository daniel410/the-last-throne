# 가방 포션 배정 상태·Gear & Bag 전용 아이콘

2026-11-01 · TLT-028/043/084 · ENG/DES → QA · 0.58.26 로컬 UI 조정

## 변경

- 가방 목록의 포션에 현재 영웅의 Z/C 배지를, 상세 상단에 배정 또는 미배정 상태를 표시한다. 배정된 버튼은 ASSIGNED Z/C와 금색 글자로 상태를 보여 주며 중복 배정 저장을 막는다. 다른 슬롯 배정은 기존 안전·저장 조건을 따른다. 서버 확정 snapshot으로 갱신하고 definitionId 기반 배정·스택·수량·소유권·저장 스키마는 유지한다.
- 사용자 첨부 로비 메뉴의 동전 주머니를 [배낭·검·방패 아이콘](../../../assets/ui/gear-bag-icon-v1/README.md)으로 교체한다. 내장 image_gen으로 생성한 1254×1254 투명 PNG다. 기존 TD 버튼·메뉴 배치·40×40 엠블럼·기능은 유지한다. RPG 전용 이미지 97083585932775의 유형1·사용자9156786071 소유·Studio preload Success·IsLoaded=true를 확인했다. TD 운영 원본은 변경하지 않았다.
- [조사와 적용 판단](../../research/2026-11-01-bag-potion-assignment.md), 최종 프롬프트·이미지 해시는 연결된 자산 폴더에 보존한다.

## 검증

기존 0.58.24 Battle 산출물의 별도 `/tmp/TLT-GearBag-UI-QA.rbxlx`에 변경 모듈을 주입하고 Roblox MCP Edit에서 검사했다. Player·전송은 대역이다. [원시 로그](native.log).

| 검사 | 결과 |
| --- | --- |
| 실제 가방 생성자·InventoryRules로 Z/C/둘다/미배정·재배정 후 배지 제거·영웅별 분리·장비 구분·아이콘 ID 조회 |12개 통과 |
| `tests/inventory-mobile-layout-native.luau` |13개 통과. 750×323 가방·장비8슬롯·상세/버튼 영역 |
| `tests/potion-request-recovery-native.luau` |12개 통과. Busy·늦은 응답·unknown 유지 |
| `tests/lobby-top-menu-native.luau` |45개 통과. TD 메뉴 크기·동작·네 해상도 |
| `lua tests/inventory.spec.lua` |271개 통과 |
| `git diff --check` |통과 |

초기 fixture의 Equipment 필터, 부동소수점 완전 일치 비교, ModuleScript wrapper의 return 누락을 교정했다. 제품 코드를 실패에 맞춰 바꾸지 않았다. run-in-roblox 연결 timeout 후 직접 연 별도 Studio에서 통과했다. 로그의 기존 203785492 자산 유형 경고와 파괴된 fixture의 지연 resize에서 발생한 Eyebrow 조회 경고는 보존했다. 전체 실행 무오류를 뜻하지 않는다.

실제 마우스·터치·패드, 라이브 DataStore, 게시 클라이언트는 미검증이다. Edit screen_capture에는 CoreGui가 담기지 않아 UI 시각 수용 증거로 쓰지 않았다. 다음 QA는 실제 재배정·영웅 전환·재접속 상태 표시와 작은 화면의 아이콘 식별성을 확인한다. 상위 티켓은 미완료다. 검사에 사용한 별도 Studio PID21108을 종료하고 기존 사용자·TD Studio는 보존한다.

[빌드 기록](build.json)에 고정 입력 커밋·버전·산출물 해시를 남긴다. Roblox Place 게시·릴리스 태그는 생성하지 않는다.
