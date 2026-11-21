# 운영 오류 집계 후속

TLT-090 · 2026-11-20 · 단일 Place 후보 0.115.10

사용자가 첨부한 Roblox 오류 집계에서 같은 원인의 서버 호출 위치와 MemoryStore 경고를 합산했다.

| 집계 | 원인과 수정 |
| --- | --- |
| 지역 선행 로딩 오류 11,238건 | `StreamingTargetRadius`는 게임 스크립트가 읽을 수 없는 Workspace 속성이다. 지역 접근 선행 로딩에 서버 상수 384 studs를 사용한다. 이 값은 기존 접근 거리와 같다. [Roblox Workspace API](https://create.roblox.com/docs/reference/engine/classes/Workspace#StreamingTargetRadius) |
| 지도 이미지 오류 24건 | 게시된 Experience에서는 기본 보안 설정으로 `EditableImage` 생성이 실패한다. 지도는 44개 실측 지형 데이터를 기존 UI 그라데이션 경로로 항상 렌더링한다. 색과 실루엣은 같은 데이터에서 읽으며 픽셀 단위 세부 묘사는 줄어든다. [Roblox EditableImage API](https://create.roblox.com/docs/reference/engine/classes/EditableImage#enabling-for-published-experiences) |
| 체크포인트 이벤트 무기한 대기 경고 12건 | 캠페인 초기화 시에만 생기던 `CheckpointTravelState`를 두 프로젝트의 ReplicatedStorage에 미리 넣었다. 캠페인 서비스는 그 이벤트를 재사용하고 클라이언트는 누락 시 대기를 종료한다. |
| 원정 MemoryStore 오류 6건과 경고 6건 | `InternalError`를 받은 읽기와 변환이 시작되기 전의 쓰기를 원래 저장소에서 최대 두 번 재시도한다. 반영 여부가 불명확한 쓰기는 자동 재실행을 중단하고 `NetworkUnavailable`을 반환한다. 재접속 요청은 이미 검증한 원정 정보를 재사용해 중복 조회를 없앴다. [Roblox MemoryStore 오류와 재시도](https://create.roblox.com/docs/cloud-services/memory-stores) |

## 검증

- Lua 14묶음 114,855검사를 통과했다. 지역 경계 접근과 권한 제한 Workspace 대역, 체크포인트 로딩 및 이동, 세부 지도, 원정 장애와 저장소를 포함한다. MemoryStore 대역에서 일시 오류 회복, 재시도 소진, 불명 쓰기 무재실행, 이미 조회한 정보로 재접속 준비, 만료와 장애 메시지 구분을 확인했다.
- 후보 0.115.8과 0.115.10의 격리 Studio Edit에서 각각 지도 지형 96검사, 지역 지도 332검사와 렌더링 경로 3검사를 통과했다. 체크포인트 이벤트는 서버 스크립트 실행 전 이미 있었다.
- 후보 0.115.8의 격리 Studio Play에서 로비에 12초 이상 머무른 뒤 체크포인트 이벤트가 복제되었고 해당 무기한 대기 경고는 없었다. 일반 영웅 요청으로 모험에 들어가 지도와 캐릭터 준비를 확인했다. 실제 이벤트로 체크포인트 로딩 화면의 시작과 취소를 주입해 표시와 입력 잠금 해제를 확인했다. 실제 Luau 엔진에서 지역 경계 네 곳의 접근을 대역 영웅과 준비 함수로 실행했다.
- 후보 0.115.10을 배틀 역할로 Studio Play에 실행했다. 약 14.8초 뒤 배틀 시작과 원정 이벤트 초기화, 클라이언트의 체크포인트 이벤트 하나, 해당 무기한 대기 경고 0건을 확인했다.
- 후보 0.115.10의 단일 Place 산출물에서 체크포인트 이벤트가 하나이고 두 프로젝트 설정이 동일함을 확인했다. 산출물에서 추출한 코드로 Place 역할과 입장 로딩 336검사를 통과했다. [최종 빌드 및 SHA-256](build.json) · [0.115.8 빌드 기록](build-0.115.8.json)

게시 클라이언트와 실기기, 실제 Roblox MemoryStore 장애, 게시 Place 간 왕복은 미검증이다. 후속 운영 QA에서 최종 후보를 두 테스트 Place에 적용한 뒤 오류율과 재접속 결과를 확인한다.
