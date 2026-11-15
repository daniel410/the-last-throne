# 베테란 투구 기본 지급 제거

- 작업ID: TLT-041/043 (서버 프로필·장비). 2026-11-14 사용자 요청.
- 변경: 공통 `ItemCatalog.kit`에서 `veteran_hood`를 제거해 네 클래스의 신규/후속 영웅 자동 지급을 중단한다. 기사·드워프는 이 ID를 헬멧으로 표시한다.
- 기존 지급분: 사용자 후속 정정에 따라 계정 로드 시 삭제하지 않는다. `starter:` 출처를 포함해 가방·창고·미수령·착용 위치와 잠금·강화 상태를 그대로 보존한다. 기존 지급분 제거 코드는 철회했다.
- 보존: 구매/보상/출처 미상 보유품·상점 상품·장비 정의와 외형·다른 기본 장비·보급품·재화·완료 영수증. 기존 지급품은 회수하지 않는다.
- 저장: 기존 AccountStore 계정 lease와 UpdateAsync 내부 이관을 사용한다. 중복 콜백/저장 응답 유실 뒤 재시도/재접속은 멱등이며 다른 활성 세션은 거부한다. Roblox 게시와 라이브 DataStore 변경은 실행하지 않았다.

## 검증

로컬 Lua 회귀 검사 9개, 총 2,145검사 통과.

| 명령 | 통과 검사 |
| --- | ---: |
| `lua tests/starter-veteran-removal.spec.lua` | 13 |
| `lua tests/starter-gear-balance.spec.lua` | 202 |
| `lua tests/equipment-families.spec.lua` | 514 |
| `lua tests/mage-hats.spec.lua` | 129 |
| `lua tests/inventory.spec.lua` | 276 |
| `lua tests/starter-potions-and-shop.spec.lua` | 316 |
| `lua tests/economy.spec.lua` | 38 |
| `lua tests/retired-forge-equipment.spec.lua` | 486 |
| `lua tests/deleted-equipment.spec.lua` | 171 |

새 회귀 검사는 모든 클래스 신규 지급0, 위치별 기존 기본 지급분 보존, 잠금/강화 상태 보존, Gold/Diamonds 구매품·보상품 보존, 지갑/구매 영수증 보존, 저장 응답 유실·중복 콜백·활성 세션 충돌·재접속을 확인한다. 기존 이관/착용 검사에는 기본 지급을 가정하던 Veteran 보유품을 명시적 구매품 fixture로 분리했다. 작업 파일 `git diff --check`도 통과했다.

## 미검증·다음 담당

게임 빌드·Studio·Roblox 게시·게시 클라이언트·실기기·사용자 수용은 실행하지 않았다. VERSION/릴리스 태그 변경 없음. 다음 ENG/QA는 배포 빌드에서 신규 영웅의 Veteran 지급0과 기존 지급분/구매품 보존을 실제 클라이언트로 확인한다. 부모 티켓의 게이트 상태는 변경하지 않는다.
