# 가방·장비·창고 간소화 콘셉트 v2

문서 묶음 v0.24 · 2026-10-27 · 상태: 사용자 요청 간소화 반영, 실제 Roblox 구현 전

[현재 보드](index.html) · [기능 기획](../../../docs/equipment-bag-and-storage.md) · [설계 데이터](inventory-design.json) · [이전 v1](../2026-10-27-equipment-storage-v1/index.html)

## 현재 콘셉트

- [가방 기본 화면](01-bag-simple.png): 장비 보기로 9슬롯 접기, 목록/선택 비교/장착에 집중. [프롬프트](01-bag-simple.prompt.txt).
- [거점 창고](02-storage-simple.png): 선택 아이템 이동, 스택만 수량 입력, 미수령 보상은 배지로 접기. [프롬프트](02-storage-simple.prompt.txt).
- 기본 메뉴 진입은 가방 하나다. 거점 보관함 진입/검토 설정은 게임의 상시 메뉴가 아니라 검토 보드용 제어다.

imagegen 스킬의 built-in image_gen으로 v1 장비/창고 이미지를 각각 참조해 생성했다. 같은 기사·남색/은색/금색 프레임·파란 버튼을 유지하고 화면 정보량을 줄였다. 원본 v1은 보존했다. 프로젝트 안에 결과/프롬프트를 저장했다.

생성 이미지의 아이템 수량/비교값/능력치는 예시이며 정확한 카탈로그가 아니다. 가방 그림의 장비 보기 버튼과 기사 크기는 미술 참고이며 HTML의 접힌 영역이 동작 기준이다. 실제 TD 아이콘/메뉴/3D는 공통 레지스트리 원본을 연결해야 하며 생성 이미지에서 잘라 대체하지 않는다. HTML은 승인 기사 원본과 TD 상태 아틀라스를 직접 참조한다.

## 검증과 한계

로컬 DOM 모형에서 초기 접힘, 검/투구 자동 슬롯 장착, 장신구 대상/중복 그룹 차단, 분류, 보관함/미수령 펼침, 장비 이동 수량1, 전투 중 보관함 차단을 검증했다. 브라우저의 실제 레이아웃·터치·컨트롤러와 Roblox 저장/결제/리셋권 사용/판매/장착 모델은 검증/구현 전이다. 모바일 CSS는 목록→상세 및 가방/창고 탭 전환을 제공한다. 60/120칸은 초안이다.

## 조사에 참고한 공개 자료

2026-10-27 문서 조사이며 직접 플레이 검증은 아니다. 개발사 공식 기록과 커뮤니티 설명을 구분했다. 커뮤니티의 칸수/최신 UI는 확정 근거로 쓰지 않았다.

- [Blox Fruits 개발사 2022 업데이트](https://gamerrobot.com/blogs/news/blog-title-1): NPC 방문 대신 메뉴에서 아이템 변경하도록 개선한 과거 사례.
- [Dungeon Quest 커뮤니티 Inventory](https://dungeonquestroblox.fandom.com/wiki/Inventory): 장착품/보유품 같은 탭, 고정 슬롯과 반지 대상 선택 구분.
- [World // Zero 커뮤니티 Bank](https://world-zero.fandom.com/wiki/Bank): 가방과 동일 계정 캐릭터 공유 은행 구분.
- [Vesteria 커뮤니티 Beginner Guide](https://vesteria.fandom.com/wiki/Beginner_Guide): 분류와 특수 아이템을 얻었을 때 해당 분류 표시.

이들 사례를 참고해 우리 게임의 간소화를 설계했으며 다른 게임의 방식을 유일한 정답이나 현재 Roblox 공통 표준으로 주장하지 않는다.
