# 지면 공격의 타격 단계와 시전 회수

2026-11-24 · TLT-033/057/059 · 기준 0.115.89

Dawn Spiral의 세 타격은 같은 햇빛 고리를 반복했다. Shatter Blow는 다른 지면 강타와 같은 압력 고리와 균열을 그렸다. Vine Trap은 범위 공격이 계속되는 동안 화살을 다시 시위에 걸었다. Frost Ring은 시작 프레임부터 완성된 폭의 고리를 보였고 작은 파편과 얼음 외곽이 동시에 나타났다.

| 공식 자료에서 확인한 내용 | TLT 적용 |
| --- | --- |
| Diablo IV 개발자 업데이트(2021-12)는 다단계 공격 영역과 무기 움직임을 맞추고 몬스터의 위험 예고를 먼저 읽을 수 있게 시각 강도를 배분한다고 설명한다. [Blizzard 전투·VFX 개발 기록](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | Dawn Spiral은 세 확정 타격의 검 높이와 빛의 도달점을 높인다. 실제 범위는 공용 경계가 나타낸다. |
| World of Warcraft Retail Legion 7.3 개발진은 시전 준비부터 발사까지 이어지는 몸짓에서 반응성과 무게를 함께 조정했다. Frost Mage의 냉기 주문을 전문화 특성이 드러나게 다듬었다. [Blizzard 주문 애니메이션 소개](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | Frost Ring은 접힌 팔을 낮게 펼치고 지면의 서리 전면과 뒤이어 자라는 외곽 결정을 연결한다. |
| Lost Ark 글로벌 Destroyer의 Earth Eater는 회전마다 무기를 높이고 마지막에 내려치며, Terra Break는 내려친 뒤 지면이 갈라진다(2022-05). 글로벌 Summoner의 Sticky Moss Swamp는 한 위치에 설치된 뒤 반복해서 피해와 감속을 준다(2022-12). [Destroyer Academy](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-destroyer-class) · [Summoner Academy](https://www.playlostark.com/en-us/news/articles/summoner-academy) | Shatter Blow는 도끼가 닿은 뒤 균열과 돌이 솟는 순서를 표현한다. Vine Trap은 첫 투사체 뒤 활을 내리고 후속 박자는 지면의 뿌리만 움직인다. |
| Roblox Beam은 부착점 사이에 곡선과 너비 변화로 궤적을 그린다. Roblox 성능 가이드는 프레임별 계산량과 렌더링 비용을 제한할 것을 권한다. [Roblox Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [Roblox 성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | 기존 전투 효과 수명과 슬롯을 사용한다. 아군의 보조 획·결정·뿌리 수를 줄이고 예산 소진 시 공용 범위 표시를 사용한다. |

공식 문서를 2026-11-24에 비교했다. 각 사례의 동작 원리를 TLT 리그와 기존 색상으로 옮겼다. 검토 기준은 확정 타격과 발동 효과의 일치, 동일 카메라에서 기술마다 다른 실루엣, 아군 표시의 간소화, 적 예고와 범위 경계의 가독성이다. 곡선과 균열의 시각적 확장은 연출 시간이며 피해는 실제 서버 펄스에서 확정된다.
