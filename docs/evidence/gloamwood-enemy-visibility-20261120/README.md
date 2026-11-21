# TLT-065 · Gloamwood 야간 전투 가독성

Gloamwood 자정 조명의 그늘 `Ambient`를 RGB `(122, 138, 162)`로 조정했다. 살아 있는 영웅 주변 48스터드 안에서 살아 있는 적 최대 10마리의 실루엣에 은회색 윤곽을 적용한다. 가장 가까운 적을 우선하며, 표적·도발·중력 표시가 붙으면 기본 윤곽은 다음 표시 갱신에 사라진다. Roblox `Occluded` 깊이 모드를 사용한다. [공식 사례·수치 근거](../../research/2026-11-20-gloamwood-enemy-visibility.md)

## 검증

고정 단일 빌드 0.114.42 / `98cfbefd6a1fd5e3af390d6ac8872c0771e251aa`. 빌드의 수정 모듈 3개가 해당 커밋의 원문과 바이트 단위로 일치했다. [빌드 기록·SHA-256](build.json)

| 검증 | 조건 및 결과 |
| --- | --- |
| 정적 회귀 | `lua tests/daylight-atmosphere.spec.lua` 75건, `lua tests/auto-target.spec.lua` 215건, `lua tests/campaign-combat-routes.spec.lua` 77,381건 통과. 고정 빌드 `tests/single-build.spec.py --artifact`의 역할 10건과 도착 로딩 326건 통과. |
| Studio 엔진 | `run-in-roblox --place builds/0.114.42/TheLastThrone-0.114.42.rbxlx --script tests/gloamwood-enemy-outline-native.luau` 35건 통과. 지역/조명 복원, 거리·높이·사망·동시 표시 한도, 표적·도발·중력 우선, 정리 확인. |
| Studio Play | PlaceId 0의 고정 빌드 복사본에서 기존 실행 스크립트를 끄고 실제 캠페인 월드와 Webling을 배치했다. 실제 클라이언트의 `DeepwoodAtmosphere.start()` 및 `K0EnemyVisual.start()`를 호출했다. 조명/윤곽 적용, 수동 생성한 금색 표적 효과 우선과 해제, 테스트 영웅 이동으로 사거리 이탈·재진입, Training 진입·복귀, 적 폴더 제거·재배치 9건 통과. |

## 같은 카메라 비교

PlaceId 0에서 실제 `CampaignWorld.create(2)` 및 Webling·Silkweaver 원본을 사용했다. GW-02 경비 교전 위치 주변을 카메라 `(-258, 76, -4539)`에서 `(-234, 63, -4531)`을 바라보며 FOV 70으로 비교했다. 밤 조명과 카메라를 고정하고 기존 조명, 보정 조명, 보정 조명과 윤곽 순으로 캡처했다. 완전히 가린 Webling은 동일한 불투명 차폐물 배치에서 윤곽을 켜고 끈 화면의 픽셀이 일치했다. [이전](before.png) · [조명 보정](ambient.png) · [조명과 윤곽](after.png) · [캡처 절차](capture.luau)

Studio 캡처에서 윤곽을 추가했을 때 두 거미의 다리와 몸통 형태가 더 선명하게 드러났다. 실제 공격 중 판독, 게시 클라이언트, 모바일 저화질·다인 성능 및 사용자 수용은 미검증이다. TLT-065/G5는 열린 상태이며 다음 DES·QA는 GW-02 전투에서 공격 예고와 몬스터 실루엣을 함께 확인한다.
