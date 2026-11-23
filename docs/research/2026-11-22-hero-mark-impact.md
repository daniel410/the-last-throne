# 표식을 쓰는 기술의 강화타 연출

2026-11-22 · TLT-033/057/059 · 공식 개발자 자료와 TLT 소스 검토

직전 후보의 네 연속 공격은 각 펄스에 고유 자세와 궤적을 적용했다. 표식 계열을 검토하면서 적마다 표식 소유자와 만료를 확인하는 서버 판정은 이미 있지만, 명중 연출은 일반타와 강화타에 같은 효과를 쓰는 것을 확인했다. 특히 Mark Breaker의 조준 괄호가 표식 소모와 무관하게 흩어져 성공을 판독하기 어려웠다. [연속 공격 검증](../evidence/hero-pulse-rhythm-20261122/README.md)

| 사례 | 공식 자료에서 확인한 내용 | TLT 적용 |
| --- | --- | --- |
| Diablo IV · 2021년 12월 VFX 개발자 글 | 타격 위치·방향에 효과를 맞추고, 교전 중 즉시 판단해야 할 위험에 시각적 우선순위를 준다. [개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 명중한 적의 위치에서 강화 효과를 시작하고, 공격 방향을 기준으로 두 획만 펼친다. |
| World of Warcraft Retail · Legion 7.3 | 시전 시간에 맞춰 준비·방출 자세를 다듬고, 직업과 원소마다 손짓과 움직임의 성질을 구분했다. [전투 애니메이션 제작기](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | 기사의 하중 이동, 드워프의 양발 버팀, 엘프의 시위 회수, 마법사의 유도 팔에 모션을 배분한다. |
| World of Warcraft Retail · The War Within 11.2 | 던전과 공격대의 아군 화면에서 Earth Shock의 명중 효과를 줄였다. [Ghosts of K’aresh 패치 노트](https://worldofwarcraft.blizzard.com/en-gb/news/24226698) | 아군도 표식이 갈라지는 형태를 볼 수 있게 하고 효과를 0.16초로 제한한다. |
| Lost Ark 글로벌 · 2022년 11월 Reaper | Dagger·Shadow로 상태를 쌓고 Persona에서 Swoop의 피해를 증폭시키는 조건부 공격 구조를 공개했다. [Reaper Academy](https://www.playlostark.com/en-us/news/articles/reaper-academy) | TLT에서는 캐릭터 게이지 대신 적별 소유 표식 판정을 쓴다. 연속타·범위 공격 중 실제로 소모한 명중만 강조한다. |
| Roblox Creator Hub · 렌더링과 프레임 처리 | 입자·반투명 겹침과 프레임마다 실행하는 작업이 비용을 늘릴 수 있다. [성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | 기존 명중 슬롯과 Beam 갱신 경로에서 강화 형태를 재생한다. |

기술 발동부에서 일괄 강조하면 범위 안의 표식 없는 적까지 강화된 것처럼 보인다. 긴 지속 아이콘을 쓰면 협동 화면에서 소유자와 중첩을 추가로 전달해야 한다. 이번에는 확정 명중에서 짧게 갈라지는 두 획을 선택했다. 이펙트에 담기 어려운 소유권과 지속시간은 후속 사용자 관찰에서 필요성을 판단한다.

같은 피해 이벤트에서 정상·강화·타인 소유·만료 표식을 대조하고, 강화타의 6종 형태와 실제 수치 표시를 확인한다. 합류 시야와 저사양 터치 성능은 게시 테스트에서 확인한다. [구현과 Studio 결과](../evidence/hero-mark-impact-20261122/README.md)
