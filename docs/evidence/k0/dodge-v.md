# PC 회피 V·점프 Space

2026-10-28 · TLT-005 / ENG → QA

사용자 지시에 따라 PC 회피 입력과 HUD 힌트를 Space에서 V로 변경했다. Space는 Roblox 기본 점프에 전달한다. 패드 B 바인딩과 터치 Dodge 버튼은 유지한다. [비교 조사](../../production/dodge-key-research.md)와 구분하여 실제 사용자 결정이다.

격리된 PlaceId 0 Studio 소스 fixture에서 R15 Knight를 생성해 튜토리얼에 진입했다. 가상 PC 입력으로 Space를 누르자 루트 높이 약 3.10→10.36 studs로 상승하고 착지했으며, 회피 순번 0과 스태미나 100은 유지됐다. 이어 V를 누르자 회피 순번 1, 상태 Dodge, 스태미나 70을 확인했고 HUD 힌트는 V였다. ContextActionService의 회피 바인딩은 V와 ButtonB로 확인했다. 점프 소스는 그대로 둔 기본 Roblox 캐릭터 조작이다.

Studio 가상 입력은 실기기·게시 클라이언트 수용과 다르다. 모바일 버튼·패드 실제 입력, 채팅/메뉴 포커스 및 다양한 지형의 점프는 아직 미검증이다. 다음 담당 QA가 해당 조건을 확인한다.
