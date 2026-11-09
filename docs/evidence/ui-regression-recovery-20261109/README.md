# 장비·상점·HUD 실패 검사 복구

2026-11-09 · TLT-028/041/043/052/057/084 · ENG/QA · 검사 수정 완료 · 게임0.88.4 유지

사용자 “실패한곳부터 다시 작업” 지시로 직전 작업의 실패3건부터 복구했다. 0.88.4의98개 단위/표시 검사는 이미 통과했고 소스/증거 커밋ce6cb9a1도 origin/main과 일치함을 먼저 확인했다.

## 원인과 수정

- `tests/equipment-impact.spec.lua`: Fine기본 무기·방어구·장신구 자동 착용 전의 상태와 옛10%/HP40을 기대했다. 현재 자동 착용 상태에서 같은 장비의 차이가0임을 검사하고, Fine3%→Veteran4%의 실제 공격력 차이1%, 장착 후 재비교0, 구무기 하향 비교, 빈 몸통 슬롯의 방어2/HP20을 각각 확인한다. 현재 카탈로그 수치와 신규 영웅 계약을 유지한다.
- `tests/blacksmith-native.luau`: 판매 종료된 Lv10상품을 포함한12/11/5개와 Guardian Charm을 기대했다. 기존115개 서버 상점 검사의 현행 정본8/6/2개와 실제 판매 중인 Amber Charm의HP30 pts로 갱신했다. 분류별 모든 카드/Gold가격, TD 목적지 아이콘 로드는 계속 검사한다.
- `tests/k0-resource-ui-native.luau`: 안내문 배경을 옛30%이하 투명도로 기대했다. 현행60%와 굵은 글자/외곽선을 검사하며 투명 모드·일반 모드 복귀·지우기도 확인한다. Roblox float속성 오차를 허용하는 작은 허용치를 사용한다. 다음 단계에서 최신 로비의 InventoryState 구독을 fixture가 제공하지 않아 WaitForChild에서 대기하는 문제도 발견해, 해당 구독만 무동작 대역으로 주입했다. 생성자·상태 갱신 검사는 실제 모듈을 사용하며 네트워크 수신/전달 수용을 주장하지 않는다. PlayerGui를 생성 시 캡처하고 Destroying콜백을 마친 뒤 모듈을 정리해 검사 종료 후 오류도 제거했다.

## 검증

기존 고정 산출물 `builds/0.88.4/TheLastThrone-0.88.4.rbxlx`를 사용했다. 게임 입력 소스는33cf377edf41eca6b07f9ef423479a8367630b12다. 이번 변경은 테스트/문서만이며 새 빌드나 VERSION 증가를 만들지 않는다.

- `lua tests/equipment-impact.spec.lua`:52검사 PASS ([로그](equipment-impact.log)).
- `lua tests/blacksmith-stock.spec.lua`:서버 구매/가격/재요청/판매 등115검사 PASS ([로그](blacksmith-stock.log)).
- `run-in-roblox --place builds/0.88.4/TheLastThrone-0.88.4.rbxlx --script /tmp/tlt-blacksmith-recovery.luau`:수정한blacksmith-native의 반환 report를 출력/검증하는 래퍼로49검사 PASS·TD아이콘AssetFetchStatus.Success ([로그](blacksmith-native.log)). 래퍼는 아래 재현 코드로 생성할 수 있다.
- `run-in-roblox --place builds/0.88.4/TheLastThrone-0.88.4.rbxlx --script tests/k0-resource-ui-native.luau`:22,122검사 PASS·failures빈 배열·종료 후 추가 오류 없음 ([로그](resource-ui-native.log)).
- `git diff --check`:PASS. 총22,338검사 PASS. 실패 시점의 과거 증거는 덮어쓰지 않았다. 신규 LFS자산 없음.

```python
from pathlib import Path
source = Path('tests/blacksmith-native.luau').read_text()
Path('/tmp/tlt-blacksmith-recovery.luau').write_text(
    'local report=(function()\n' + source +
    '\nend)()\nprint(game.HttpService:JSONEncode(report));assert(report.pass)\n'
)
```

게임 실행 로직/상품/저장/원격권리와 Studio 사용자 세션을 변경하지 않았다. 실제 플레이·실기기·시각 가독성·게시 클라이언트 수용은 미검증이다. 다음 담당QA는0.88.4의 하단HUD와4.0%표시를 실제 기기에서 확인한다. 부모 티켓 완료/Roblox 게시/릴리스 태그 없음.
