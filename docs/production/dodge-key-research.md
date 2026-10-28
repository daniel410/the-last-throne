# 회피 키 비교와 제안

2026-10-28 · 작업 TLT-008 조작 검토 · 기획/엔지니어링 → QA

조사 당시 K0 PC 조작은 Space를 회피에 사용하고 Roblox 기본 점프를 가로챘다. 사용자의 지적대로 Roblox 이용자의 점프 기대와 충돌한다. 게임패드 회피는 B, 터치는 Dodge 버튼이다.

| 사례 | 확인된 조작 | 근거와 해석 |
| --- | --- | --- |
| Guild Wars 2 | PC 기본 회피 V, 점프 Space. 이동 키 두 번으로 회피하는 선택지도 있으며 끌 수 있다. | [공식 위키 조작](https://wiki.guildwars2.com/wiki/Controls) |
| New World: Aeternum | 2021년 공식 패치에서 PC 기본 회피 Shift, 점프 Space로 변경하고 달리기는 자동으로 전환했다. | [공식 패치 노트](https://www.newworld.com/en-gb/game/releases/june-part-1). 역사적 변경 기록이며 현재 기본값을 독립적으로 확인한 것은 아니다. |
| Elden Ring | 공식 가이드의 게임패드 기준 회피/뒤로 물러나기 B, 점프 A. | [배급사 공식 가이드](https://en.bandainamcoent.eu/elden-ring/news/elden-ring-starter-guide-tips-know-playing-the-game). PC 키 사례로 추정하지 않는다. |
| Warframe | PC 기본 Shift 달리기, Space 점프. | [공식 PC 조작 안내](https://support.warframe.com/hc/en-us/articles/200410054-PC-Controls-Keyboard-Gamepad). Shift를 다른 이동 동작이 사용할 수 있는 사례다. |

Roblox는 Shift Lock을 켠 경우 Shift로 카메라 모드를 전환한다. [Roblox 공식 안내](https://en.help.roblox.com/hc/en-us/articles/203314230-In-experience-Settings-and-Help)

**추천안:** PC는 Space 점프, V 회피. V는 WASD 가까이에 있고 현재 K0의 Q Cast·X 표적 해제와 겹치지 않으며, Shift Lock과도 겹치지 않는다. 개인별 손 크기와 키보드 배치에 따라 접근성이 달라 사용자 관찰이 필요하다. 이동 키 두 번 입력은 오회피 가능성이 있으므로 기본으로 추가하지 않는다. 이후 설정 가능한 키 배치를 검토한다. 모바일 기존 Dodge 버튼, 패드 B 회피와 A 점프는 유지하는 방향으로 별도 확인한다.

후속 사용자 지시로 PC 회피 V·점프 Space가 채택되어 K0에 반영됐다. 입력·HUD 힌트와 Studio PC 가상 입력의 검증 결과는 [작업 기록](../evidence/k0/dodge-v.md)에 남긴다. 실제 기기, 모바일·패드·메뉴 포커스와 다양한 지형의 수용 검사는 별도다.
