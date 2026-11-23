# 보호·저지 계열 공격의 자세와 명중

2026-11-23 · TLT-033/057/059 · 로컬 Studio 검증과 1~4인 전투 판독 대상

0.115.55의 보호막 수혜 효과는 서버가 방패를 실제 적용한 캐릭터에게 표시한다. 이번에는 다른 네 공격의 기존 렌더링을 검토했다. Guarded Strike와 Low Sweep은 기존 방패·도끼 자세를 공유하고 Rooting Fan과 Frost Ring은 기존 확산 발사·냉기 자세를 공유한다. 발사·공격 범위는 기술별로 표시되지만 실제 적 명중은 공통 피격 모양에 가까웠다. [직전 보호막 검증](../evidence/hero-shield-grant-20261123/README.md)

| 공식 자료 | 관찰 | TLT 적용 |
| --- | --- | --- |
| [Diablo IV 2021년 12월 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 휘두르는 동작과 공격 영역을 맞추고, 적 피격 표시를 공격 방향에 맞춘다고 설명한다. 위험 예고와 기술 강도에 시각 우선순위를 둔다. | 확인된 방향을 기준으로 적의 피격면에 두 획을 만든다. Low Sweep의 낮고 넓은 높이와 Guarded Strike의 단단한 수직 윤곽을 구분한다. |
| [WoW Retail Legion 7.3 시전 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | 시전 동작에 무게를 실으면서 조작 반응성을 확보하기 위해 짧은 동작을 설계했다고 설명한다. | Frost Ring의 무게를 짧은 손 내리기와 무릎 굽힘에 싣는다. Rooting Fan은 활을 든 손을 유지하며 시위를 놓은 팔로 회수 방향을 보인다. |
| [Lost Ark 글로벌 Glaivier](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-glaivier), [Chaos Rising](https://www.playlostark.com/en-us/game/releases/chaos-rising) | Half Moon Slash는 지면을 따라 긋는 부분과 대각선으로 들어 올리는 부분을 구분한다. Chaos Rising에서는 배경 효과가 바뀌는 각성기에서 공격 예고 범위 채도를 조정했다. | 드워프의 도끼 휩쓸기를 낮은 박자로 만들고, 엘프의 명중은 지면 쪽에서 말려 올라가는 획으로 표시한다. 아군 화면에서도 적 예고 주변의 면적과 보조광 사용을 제한한다. |
| [Roblox Beams](https://create.roblox.com/docs/effects/beams), [렌더링 최적화](https://create.roblox.com/docs/performance-optimization/improve) | Attachment 사이에서 곡선 Beam을 그릴 수 있고 파티클과 겹치는 투명 효과는 렌더링 비용을 늘린다. | 기존 Beam·수명·거리 예산을 재사용한다. 각 명중에는 주요 Beam 두 개를 쓰고 별도의 파티클을 추가하지 않는다. |

참고 자료는 공식 개발자 글과 기술 설명으로 확인했다. 기술의 명중 범위와 행동 시간은 기존 서버 데이터를 사용한다. 짧은 명중 획은 시전 결과를 보여 주며 감속이나 기절 성공 여부는 기존 상태 표시에서 확인한다.

최소 검증은 R6/R15의 준비와 회수, 90도 차이가 나는 두 피격 방향, 본인·아군 화면의 Beam 수와 피해 숫자 확인이다. 전투 QA는 같은 카메라와 조명에서 네 기술이 구별되는지 살피고, 게시 테스트에서 네 영웅이 겹칠 때 적 예고 식별과 터치 장치의 프레임 시간을 확인한다.
