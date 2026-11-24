# 두 번째 타격과 투사체 회수의 방향 판독

2026-11-24 · TLT-033/057/059 · 기준 0.115.92

Sunward Cross의 두 베기는 범용 성속성 물결과 겹쳤다. Crosscut Axe의 회수에는 서버 경로 전체를 가리키는 잔상과 손으로 접근하는 회전 획이 동시에 보였다. Crossfire는 몸에서 떨어진 고정 시작점에서 발사선을 그렸다. Glacial Spike는 얼음창 크기로 Frost Lance와 구별되지만 발사 소켓과 표적의 연결은 별도 범용 광선에 의존했다. [선행 직선 타격 검토](2026-11-23-hero-line-contact.md) · [선행 명중 방향 검토](2026-11-21-hero-contact-weight.md)

| 공식 자료에서 확인한 내용 | TLT 적용 |
| --- | --- |
| Diablo IV 개발 업데이트(2021-12)는 무기와 주문의 움직임에 공격 영역과 적중 방향을 맞추고 전투 가독성에 따라 효과 강도를 배분한다. [Blizzard 전투·VFX 개발 기록](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | Crosscut Axe 회수의 도끼와 잔상을 같은 손 위치로 보낸다. Crossfire는 서버가 해당 발에 정한 거리를 사용한다. |
| World of Warcraft Retail Legion 7.3의 시전 애니메이션은 마법을 모으고 방출하는 연속 몸짓을 소개했다. The War Within 11.2에서는 Frostwyrm’s Fury의 동작과 시각 효과를 함께 갱신했다. [Legion 시전 동작](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [Blizzard 11.2 패치 노트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) | Glacial Spike는 지팡이 가까이 냉기를 모으고 빈손을 들어 찌른다. 긴 얼음창에서 양옆 조각이 빠져나오는 순서를 붙였다. |
| Lost Ark 글로벌 Glaivier의 Chain Slash는 방향을 바꾸는 후속 베기를, Sharpshooter의 Charged Shot은 준비와 한 발의 결과를 명시한다. [Glaivier Academy](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-glaivier) · [Gunner 공식 소개](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) | Sunward Cross는 디딤을 바꾸며 낮은 베기 뒤 높은 빛을 올린다. Crossfire는 발사마다 하나의 주 궤적을 그리며 두 번째 조준과 디딤을 구분한다. |
| Roblox Beam은 양 끝의 부착점과 너비로 궤적을 그릴 수 있다. 성능 가이드는 화면의 오브젝트 밀도와 입자 비용을 줄이는 방법을 설명한다. [Roblox Beam](https://create.roblox.com/docs/reference/engine/classes/Beam) · [Roblox 성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | 짧은 잔광과 기존 슬롯을 사용한다. 아군의 검격 보조면과 얼음 파편을 생략하고, 화면 예산이 찰 때 공용 범위 또는 투사체 표시를 사용한다. |

2026-11-24에 공식 자료를 대조했다. 적용 기준은 서버 확정 적중점, 두 박자의 카메라 가독성, 피격 위치와 회수 방향, 겹치는 붉은 적 예고다. 신규 동작과 형상은 TLT의 리그와 전투 수치를 기준으로 제작했다.
