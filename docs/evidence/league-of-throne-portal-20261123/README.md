# Dawnspire 왼쪽 League of Throne 포탈

2026-11-23 · TLT-023 / TLT-060 · 구현 → QA

[Experience 이동 계약](../../experience-integration.md#dawnspire--league-of-throne) · [포탈 표시 조사](../../research/2026-11-23-lobby-travel-portal.md)

Creator Dashboard에서 League of Throne의 Experience `10778387851`과 시작 Place `100539309098013`을 확인했다. 확인 당시 게임 접근은 **Private**이었다. [목적지 대시보드](https://create.roblox.com/dashboard/creations/experiences/10778387851/places/100539309098013/configure)

## 빌드

- 버전 `0.115.63`, 소스 `368ee315e79a69eef0835a8e30e451274fc1d33c`
- `python3 tools/build-game.py --source 368ee315 --record <build.json>` 및 Rojo 7.7.1로 생성한 단일 Place. [TheLastThrone-0.115.63.rbxlx](../../../builds/0.115.63/TheLastThrone-0.115.63.rbxlx)
- 26,875,130 bytes, SHA-256 `ad1e6609c2d76c21963487fd8f08843df57896ca304790c34d732e0b50ff233b`

## 검증

| 조건 | 결과 |
| --- | --- |
| 변경 Luau 컴파일 및 패키지 역할·초기 로딩 | 컴파일 통과. `python3 tests/single-build.spec.py --artifact builds/0.115.63/TheLastThrone-0.115.63.rbxlx` 역할 10개, 로딩 326개 통과 |
| 순수 Lua 회귀 | 원정 요청 40개, 출발 42개, 장애 12개, 저장 84개, 백엔드 40개, 로비 복귀 33개, 이동 콜백 토큰 8개 통과 |
| 격리 Studio, PlaceId/GameId 0, 접속 플레이어 0명 | [시설 검사](../../../tests/lobby-landmarks-native.luau) 259개 통과. 왼쪽 신설·이전 모델 제거, 간판, 조작 키, 접근로, 거리 거부, 좌우 포탈별 요청 확인 |
| 같은 Studio, 플레이어·저장·전송 대역 | [이동 검사](../../../tests/expedition-service-native.luau) 22개 통과. League 시작 Place에 한 명만 전송, 중복·파티·저장 실패 차단, 세 번의 이동 시도 후 계정 복구, TD 목적지 확인. [파티 출발 회귀](../../../tests/party-launch-native.luau) 223개 통과 |

Studio 실행기는 고정 빌드의 복사본에 실행기 표식만 넣고 위 세 스크립트를 순서대로 실행했다. 첫 이동 검사에서 출발이 롤백된 멤버에게 리조인 제안이 남아야 한다는 과거 기대값이 실패했다. 현행 파티 검사에 맞춰 기대값을 정정했고, 같은 빌드로 최종 실행기 종료 코드 `0`을 확인했다.

**미검증** · Roblox 게시 및 실제 Roblox 클라이언트의 Experience 간 이동. 다음 담당 QA는 두 Experience에 접근 권한이 있는 플레이테스트 계정으로 Dawnspire에서 출발해 League of Throne 로비에 도착하는지 확인한다.
