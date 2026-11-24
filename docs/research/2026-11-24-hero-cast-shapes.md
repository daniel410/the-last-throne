# 연속 타격과 지면 시전의 동작 비교

2026-11-24 확인 · TLT-033/057/059 · ART·ENG → QA

0.115.84의 Warcry Assault는 타격마다 비슷한 높이의 세 파동, Twin Axe Path는 같은 회전과 직선 자국을 사용했다. Storm Arrow는 공용 지면 렌더러와 HeroVFX가 각각 낙뢰를 그렸다. Froststorm은 위로 감기는 세 줄과 별도 띠가 겹쳐서 얼음 하강이 약하게 읽혔다. 네 사례에서 카메라가 멀어져도 공격 방향과 발동 단계가 구분되는지 비교했다.

| 공식 사례 | 확인한 내용 | TLT 적용 판단 |
| --- | --- | --- |
| Diablo IV PC·콘솔, 2021년 12월 개발 업데이트 | 무기 궤적과 타격 영역을 동작에 연결하고, 명중 효과는 진입 방향을 따른다. 기술 강도는 크기 외에도 색·속도·지속 시간으로 조정한다. [Blizzard 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | Warcry Assault의 파동을 서버 방향으로 전진시키고 마지막 타격의 높이와 폭을 올린다. Twin Axe Path는 확정 끝점을 공유하면서 몸과 투척 자국의 기울기를 바꾼다. |
| World of Warcraft Retail PC, Legion 7.3, 2017-08-16 및 The War Within 11.2, 2025-08-05 출시 | 시전 동작이 공기나 지면에서 힘을 모으는 과정을 보여준다. 11.2는 Spell Density와 아군 Earth Shock 효과를 조정해 전투 정보가 드러나게 했다. [7.3 제작 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2 패치 기록](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) | Froststorm은 높이 든 빈손을 내리면서 목표에서 나선이 수축한다. 아군 화면에서는 낙뢰와 서리의 주 형상을 남기고 획과 면을 줄인다. |
| Lost Ark 글로벌 PC, 2021년 전투 직업 소개 및 2022년 12월 Summoner 출시 | Sharpshooter의 Arrow Shower는 상향 발사와 지점 착탄을 구분한다. Deadeye의 Bursting Flare는 먼저 맞는 두 발과 마지막 효과가 다르다. Summoner 각성의 물 회오리는 이후 얼어붙는다. [Gunner 공식 기술 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Summoner 공식 출시 소개](https://www.playlostark.com/en-us/news/articles/summoner-academy) | Storm Arrow는 활을 올려 쏘고 확정 지점에 낙뢰를 한 번 그린다. Warcry Assault는 마지막 박자를 높이고 Froststorm은 나선이 내려앉는 윤곽을 사용한다. |
| Roblox Creator Hub, 2026-11-24 열람 | Beam은 두 Attachment를 연결하며 폭·곡률을 조정할 수 있다. Creator Hub는 중첩 표면과 입자에 따른 렌더링 비용을 설명한다. [Effects](https://create.roblox.com/docs/effects) · [렌더링 최적화](https://create.roblox.com/docs/performance-optimization/improve) | 기존 Beam과 표면 예산을 사용한다. 서버 펄스·범위 경계, 아군 간소화, 예산 소진 시 대체 표시를 검증 조건에 포함한다. |

공식 개발 문서와 기술 설명에서 동작의 구조를 읽고 TLT에 맞게 해석했다. 다른 게임을 직접 조작하거나 각 기술의 프레임 시간을 측정하지 않았다. 파동·번개·서리를 더 많은 입자나 넓은 화면 조명으로 구분하는 방안은 경계 판독과 렌더링 비용 때문에 보류했다.

최소 시험은 같은 리그·무기·카메라에서 준비와 발동 또는 첫·마지막 타격을 비교한다. QA는 확정 방향·끝점, 아군 화면의 주 형상, 공격 범위·적 예고 및 예산 소진 시 대체 표시를 확인한다. 게시 클라이언트에서 4인 연속전과 터치 기기 프레임 시간, 사용자 타격 체감은 후속 수용에 포함한다.
