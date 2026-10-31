# 공통 세계와 Experience 이동 조사 — TLT-023

확인일 2026-10-31. 질문: 독립 게임의 정체성과 이동 경계를 어떻게 전달할 것인가. 대상은 PC·터치·패드의 솔로 및 파티 플레이어다.

- [ELDEN RING NIGHTREIGN 공식 소개](https://en.bandainamcoent.eu/elden-ring/elden-ring-nightreign): 같은 세계관의 독립 게임을 별도 협동 경험으로 소개한다. 공식 설명을 확인했으며 직접 플레이나 유지율은 확인하지 않았다. 해석: 공통 세계와 서로 다른 플레이 역할을 함께 설명할 수 있다.
- [Roblox TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService): 서버에서 개인 이동을 요청할 수 있으며 단체 이동은 같은 Experience로 제한된다. 두 게임 사이의 파티 동행은 보장되지 않는다.

적용: TLT 로비에 왕국 방어와 영웅 탐험의 관계, 목적지 및 개인 이동을 표시한다. 다른 대안인 자동 접촉 이동은 의도치 않은 이탈 때문에 채택하지 않는다. 비용은 소형 시설과 저장·이동 상태 처리이며 문구 가독성 및 이동 오류 복구를 실기기에서 확인해야 한다. 최저 시험은 파티/솔로 접근, 저장 실패, 전송 실패, 두 게시 테스트 Experience 왕복이다. 후속 담당: TD 엔지니어와 QA. TD 측 포탈과 게시 클라이언트 검증은 아직 없다.
