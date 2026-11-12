# 포션 사용 마시는 효과음

## 2026-11-12 음량 후속 조정

- 작업: TLT-005/028/032/057/084 · ENG → QA · 소스 적용.
- 근거/변경: 사용자의 “볼륨 조금 더” 요청으로 `PotionUseSound.Volume`을0.4→0.5(25% 증가)로 조정했다. 기존 단일 편집 음원과 재생·감쇠·소비 처리는 유지한다.
- 검증: `/private/tmp/td233-luau/luau-compile src/server/Combat/PotionUseSound.luau` 구문 컴파일 및 해당 파일의 `git diff --check` 통과.
- 미검증: Studio 실행·게시 클라이언트·실기기 청취·사용자 수용. 빌드·게시 없이 소스만 변경했으며 부모 티켓 상태는 유지한다.
- 다음 담당: QA/사용자가 HP·MP 물약 성공 시 전투 중 음량을 청취해 수용 여부를 확인한다.

2026-11-05 · TLT-005/028/032/057/084 · ENG → QA · 로컬 소스 적용·미게시

## 변경과 근거

사용자의 포션 마시는 소리 요청에 따라 [조사·선택 근거](../../research/2026-11-05-potion-drinking-sound.md)의 무료 ProSoundEffects 음원9114171855를 사용한다. `PotionUseSound`가 캐릭터 Head/루트에서 짧은 일회성 소리를 재생하며, 같은 발신원의 이전 음원을 정리하고 종료/5초 제한으로 제거한다. 음량0.4·선형 감쇠16~60stud다.

`CombatService.applyInventoryItem`에서 현재 생명/영웅의 HP/MP 회복 적용 후 호출한다. 인벤토리 서버의 기존 저장 확정·lifeToken·delivered 중복 방지를 그대로 사용한다. 포션 키/터치/가방 경로가 같은 처리를 사용한다. 잘못된 대상/사망/미해금MP/잘못된 회복 종류에는 소리가 나지 않는다. 회복량/소비/저장/입력/대기시간은 변경하지 않는다.

## 검증 결과

| 명령/환경 | 결과 |
| --- | --- |
| `lua /tmp/tlt-potion-confirmation-check.lua` | 실제 수정된 applyInventoryItem 본문을 격리 실행,8개 PASS: HP/MP·상한·없는 플레이어/다른 생명/사망/MP없음/잘못된 종류 |
| `lua tests/inventory.spec.lua` | 소유권·스택·사용·멱등/복구271개 PASS |
| `/private/tmp/td233-luau/luau-compile src/server/Combat/PotionUseSound.luau src/server/Combat/CombatService.luau` | PASS |
| Studio Edit, PlaceId0/플레이어0, 후보 모듈 본문을 일회성 함수로 실행 | 엔진10개 PASS: 실제 Sound/Head·음원ID·일회성/음량·감쇠·fetch Success·연속 교체/최대1개·루트 fallback·발신원 없음/타입 오류. IsLoaded=true, TimeLength=0.8506875초 |
| Studio Edit `SoundService:PlayLocalSound` | 사용자 요청으로 후보음1회 미리 듣기,fetch Success. 사용자 청취/선호 수용은 별도 |
| `git diff --check` | PASS |

초기 run-in-roblox는50312포트 사용 중으로 실패해 기존 프로세스를 종료하지 않고 MCP의 Edit 격리 검사로 전환했다. ModuleScript 생성 경로는Capabilities Network 제약으로 실패해 동일 본문을 함수로 실행했다. 초기 음량 float 완전일치 검사는 실패해0.0001 허용오차로 재검증했다. 테스트 Folder/음원은 정리했고 기존 사용자의 Studio 세션은 유지했다.

새 빌드·VERSION 변경·태그·Roblox 게시를 하지 않았다. 현재 열린 Studio의 제품 스크립트는 교체하지 않았으며 후보 음원 미리 듣기와 격리 엔진 검사만 실행했다. 게시된 두 Place의 음원 권한/실제 소비→재생 통합·네트워크 지연·PC/모바일/4인 청취는 미검증이다. 다음 QA가 실제 성공/거절/SaveUnknown 재시도/연속 사용과 근거리/원거리 음량을 확인한다. 부모 티켓 상태는 유지한다.
