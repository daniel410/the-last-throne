# TLT-023 공통 세계 및 TD 이동 — 부분 구현

2026-10-31 · ENG / QA 인계 · In Progress

Dawnspire에 두 게임의 역할을 설명하는 영어 안내와 Throne Defense 이동 시설을 추가했다. 대상은 TD 소스의 로비 Place ID 103116209434833이다. 서버는 거리·생존·로비 상태를 검사하고, 파티가 있으면 탈퇴를 요구한다. 이동 전에 RPG 계정 저장과 세션 해제를 확인하며 실패 시 기존 전송 재시도/세션 복구 경로를 사용한다. Studio에서는 이동을 차단한다. 재화·구매·보상 데이터는 변경하지 않았다.

검증: `lua tests/expedition-store.spec.lua` 43개 통과; `git diff --check` 통과. 이 검사는 신규 시설의 실제 렌더링이나 Experience 간 이동을 증명하지 않는다. 게임 빌드·Studio·게시된 양쪽 테스트 Experience의 왕복·PC/터치/패드·저장/텔레포트 장애 주입은 미실행이다.

TD 저장소에는 기존 미커밋 변경이 광범위하게 존재하며 TD→TLT 포탈은 아직 연결하지 않았다. TD의 기존 `MatchCoordinator` 저장·전송 경계에 안전하게 통합하고 사용자 변경을 보존한 뒤 양쪽 테스트 Experience를 준비해 왕복 검증해야 한다. 담당: TD ENG → QA. 완료로 처리하지 않는다.
