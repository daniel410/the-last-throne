# 영웅 스킬 준비·타격·회수 연출 조사

TLT-033/057/059 · 2026-11-20 · 담당 ART·ENG·QA

| 공식 자료에서 확인한 사례 | TLT 적용 판단 |
| --- | --- |
| Diablo IV 개발팀은 애니메이션과 현재 표적의 정보를 바탕으로 근접·주문 명중 효과를 공격 방향과 접촉점에 배치했다. [Blizzard, 2021년 12월 개발 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 기존 확정 명중 위치와 새 준비 효과를 분리한다. 돌아오는 도끼의 마지막 짧은 궤적은 회수 손으로 끝내고 전투 중심점은 기존 서버 값으로 사용한다. |
| World of Warcraft 7.3 제작진은 지면과 공중에서 마력을 모으는 준비 동작, 즉시 시전의 짧은 손짓, 묵직한 주문의 팔 뻗기를 구분했다. Arcane Missiles는 기존 다발 구조를 유지하며 발사 효과를 다듬었다. [Blizzard, 7.3 전투 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Cinder Ring의 끌어올리는 자세와 Frost Ring의 좌우로 얼음을 펼치는 자세를 나눈다. 지속 광역 시전은 유도 손을 유지하고 Molten Line 같은 직선 연사는 발사 사이에 팔을 거둔다. 준비 형상은 불·얼음·물·번개·대지의 움직임으로 구분한다. |
| Lost Ark Destroyer의 Earth Eater와 Full Swing은 회전 횟수가 타격과 연결된다. Perfect Swing은 준비와 내려치는 힘을 여러 차지 단계로 표현한다. Sharpshooter 자료는 조준을 유지하는 공격과 빠른 연사를 별도로 소개한다. [Destroyer Academy](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) · [Gunner Advanced Classes and Abilities](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Twin Cyclone은 각 펄스에 회전 자세가 맞도록 조정한다. Stonebound Leap은 착지하면서 무릎이 충격을 받으며 Heavy Draw는 줄을 일찍 당겨 조준 시간을 읽을 수 있게 한다. 차지 입력, 피해 판정, 이동 거리에는 기존 계약을 적용한다. |
| Roblox Beam은 두 Attachment 사이에서 선의 폭·색·투명도를 제어할 수 있다. 겹친 반투명 효과는 렌더링 비용을 높일 수 있다. [Creator Hub Beams](https://create.roblox.com/docs/effects/beams) · [성능 최적화](https://create.roblox.com/docs/performance-optimization/improve) | 발동 준비에는 기존 장식 풀에서 캐릭터 소켓에 붙는 가는 선을 2~6개 사용한다. 검끝·방패·총구·활·지팡이가 보이는 여백을 두고 실제 경계와 별도로 운용한다. |

Studio에서 같은 자세 시각·카메라로 4영웅을 비교하고, 준비 소켓 추적·회차 교체·도끼 회수·연속 펄스 전이를 검사한다. 게시 전투에서 적의 경계와 아군 4인의 준비광이 겹쳐도 읽히는지 확인하고 실기기 프레임 시간을 측정한다.
