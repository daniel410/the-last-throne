# 베테란 투구 기본 지급 제거

- 작업ID: TLT-041/043 (서버 프로필·장비). 2026-11-14 사용자 요청.
- 변경: 공통 `ItemCatalog.kit`에서 `veteran_hood`를 제거해 네 클래스의 신규/후속 영웅 자동 지급을 중단한다. 기사·드워프는 이 ID를 헬멧으로 표시한다.
- 기존 지급분: `InventoryRules.upgrade`가 `veteran_hood`이고 `sourceGrantId`가 비어 있지 않은 `starter:` 출처인 인스턴스만 제거한다. 가방·창고·미수령·착용·잠금·강화 상태에 공통 적용한다. 착용품 제거 후 머리 슬롯은 빈 슬롯으로 유지하며 다른 장비를 자동 지급하지 않는다.
- 보존: 구매/보상/출처 미상 보유품·상점 상품·장비 정의와 외형·다른 기본 장비·보급품·재화·완료 영수증. 삭제된 기본 지급품에 대한 소급 환급은 추가하지 않는다.
- 저장: 기존 AccountStore 계정 lease와 UpdateAsync 내부 이관을 사용한다. 중복 콜백/저장 응답 유실 뒤 재시도/재접속은 멱등이며 다른 활성 세션은 거부한다. 별도 라이브 DataStore 일괄 삭제는 실행하지 않았다.

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

새 회귀 검사는 모든 클래스 신규 지급0, 위치별 기존 기본 지급분 제거, 잠금/강화품 제거, Gold/Diamonds 구매품·보상품 보존, 지갑/구매 영수증 보존, 저장 응답 유실·중복 콜백·활성 세션 충돌·재접속을 확인한다. 기존 이관/착용 검사에는 기본 지급을 가정하던 Veteran 보유품을 명시적 구매품 fixture로 분리했다. 작업 파일 `git diff --check`도 통과했다.

## 미검증·다음 담당

게임 빌드·Studio·Roblox 게시·게시 클라이언트·실기기·사용자 수용은 실행하지 않았다. VERSION/릴리스 태그 변경 없음. 기존 접속 세션은 새 코드 배포 후 다시 계정을 로드해야 제거가 적용된다. 다음 ENG/QA는 배포 빌드에서 새 영웅 지급과 기존 기본 지급분 제거/구매품 보존을 실제 클라이언트로 확인한다. 부모 티켓의 게이트 상태는 변경하지 않는다.
