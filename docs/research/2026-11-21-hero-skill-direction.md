# 영웅 기술의 조준 전환과 연쇄 경로

TLT-033/057/059 · 2026-11-21 확인 · 기준 빌드 0.115.18

이전 후보는 확정 명중점의 방향과 네 영웅이 겹치는 화면의 섬광을 점검했다. 이번에는 공격이 이어지는 방향을 캐릭터와 화면에서 함께 따라갈 수 있는지 검토했다. 기준 소스의 Crossfire는 첫 시전의 끝점을 다시 회전하고, 활은 두 번째 펄스까지 첫 조준을 사용했다. Crosscut Axe도 시전 때 정해진 끝점을 회전했다. Chain Lightning은 같은 표적 목록을 Beam과 별도 Neon Part가 각각 연결했다. [이전 후보 검증](../evidence/hero-impact-clarity-20261121/README.md)

## 공식 사례

| 사례 | 원문에서 확인한 내용 | TLT에서 적용한 판단 |
| --- | --- | --- |
| Diablo IV 개발자 업데이트 · 2021년 12월 | 애니메이션과 타격 영역의 시간축을 맞추고, 몬스터의 반응 방향을 공격 방향에 연결한다. 몬스터 예고 등 전투 판단에 중요한 효과에 시각 우선순위를 둔다. [공식 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | Crossfire와 Crosscut Axe는 서버가 확정한 각 펄스의 원점과 진행 방향으로 잔상을 그린다. 두 번째 선도 해당 방향에 있는 벽에서 끊는다. |
| World of Warcraft Retail Legion 7.3 · 2017-08-16 | 준비 동작의 진행을 일관되게 정리하고, 빠른 한 손 시전과 힘을 싣는 직선 방출을 구분했다. [공식 애니메이션 소개](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Chain Lightning은 Lightning Line과 다른 유도 손 동작을 쓴다. 지팡이에서 첫 표적으로 나가고 점프마다 번개의 폭을 줄인다. |
| Lost Ark 글로벌 Glaivier 출시 가이드 · 2022-04-19 | Dragonscale Defense는 전방 방어 뒤 전진 찌르기로 이어진다. Storming Red Dragon은 밀고 당기는 방향을 교대한다. [공식 클래스 가이드](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-glaivier) | Counter Slash는 먼저 방패 팔과 앞무릎을 접고 낮은 곳에서 위로 벤다. Crosscut Axe는 비스듬히 되돌아오는 도끼를 받으며 무릎을 접는다. 방어 성공 발동이나 새 이동 규칙은 추가하지 않았다. |
| Roblox Creator Hub | Beam 양 끝의 폭을 조절할 수 있으며 기기 품질 설정에 따라 결과가 달라진다. 렌더링 객체와 투명 효과가 겹치는 비용은 실제 기기에서 확인할 수 있다. [Beam](https://create.roblox.com/docs/effects/beams) · [렌더링 성능](https://create.roblox.com/docs/performance-optimization/improve) | 아군 Chain Lightning도 모든 확정 표적을 연결한다. 장식용 면과 분기를 줄이고, 예산이 찼을 때는 한 링크를 한 선분으로 표시한다. |

공식 설명을 비교했다. 게임별 현재 피해 수치와 라이브 시연의 프레임 수는 이번 판단에 사용하지 않았다.

## 검증 조건

- Crossfire를 첫 조준선과 두 번째 조준선의 장애물이 다른 배치에서 실행한다. 두 번째 활이 재장전 중 회전하고, 잔상과 확정 피격 방향이 같은 각도를 가지는지 확인한다.
- Crosscut Axe와 Counter Slash는 같은 R15 거리에서 반전 직후에 정지해 검호 높이와 도끼가 돌아오는 방향, 팔·무릎의 자세를 비교한다.
- Chain Lightning은 확정 표적 셋과 빈 표적 목록에서 실행한다. 본인·아군·효과 예산 대체 경로의 선분 수, 표적 끝점, 추가 섬광을 확인한다.
- 실제 파티와 저사양 터치 기기에서는 적 예고를 읽는 시간과 클라이언트 프레임 시간을 별도로 측정한다. 전투 QA가 게시 테스트에서 확인할 항목이다.
