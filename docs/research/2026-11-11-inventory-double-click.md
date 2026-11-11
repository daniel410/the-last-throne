# TLT-043 · 장비 더블 클릭 착용 조사

확인일: 2026-11-11. 사용자 지정 입력 개선이며 PC Gear/Bag의 선택→착용 단계를 단축한다.

- Diablo III 2.5.0 공식 [Armory 소개](https://news.blizzard.com/en-us/article/20597130/first-look-patch-2-5-0)는 버튼으로 저장한 장비 구성을 교체하고 교체품을 기존 보관 위치로 보내는 흐름을 설명한다. 역사적 패치 사례이며 현재 라이브나 더블 클릭 동작의 근거로 사용하지 않는다.
- Roblox 공식 [GuiButton API](https://create.roblox.com/docs/reference/engine/classes/GuiButton#Activated)는 Activated의 InputObject와 clickCount를 제공한다. 현재 구현은 첫 선택에서 버튼을 재생성하므로 아이템ID·프로필 revision·화면 모드·시간을 별도로 추적한다. 다른 RPG의 자동 대상 선택 비교는 [기존 장신구 조사](2026-11-05-accessory-auto-equip.md)를 재사용한다.

해석·적용: 빠른 교체라는 원리만 참고하고 사용자 지시의 왼쪽 더블 클릭을 채택한다. 전체 빌드 교체와 창고 직접 착용은 도입하지 않는다. 한 번 클릭의 상세 비교와 기존 EQUIP 버튼을 유지하므로 터치·패드 입력을 추가로 요구하지 않는다. 서버가 자격·소유권·자동 슬롯을 확정한다.

비용·위험: 클라이언트 입력 처리만 변경한다. 카드 재생성 후 연속 클릭 누락, 다른 아이템 간 오인, 삼중 클릭 중복, 전투/클래스/레벨 제한 우회가 검증 대상이다. 수용 조건은 같은 아이템0.35초 이내2회만 착용 요청1회, 다른 행동 실행0회다. 실제 PC 조작·네트워크 지연·터치/패드 회귀는 QA 후속이다. [검증](../evidence/inventory-double-click-20261111/README.md).
