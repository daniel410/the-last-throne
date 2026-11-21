# 여덟 궁극기의 마지막 타격과 협동 가독성

TLT-033/057/059 · 2026-11-21 확인 · 기준 0.115.29

현행 여덟 전직 궁극기는 각각의 대표 VFX가 있다. Studio 기준 빌드에서 Unyielding Front, Oath of Dawn, Caldera's Judgment, Eternal Tempest는 마지막 타격에 별도 회수 동작이 없었다. 아군용 대표 VFX에는 같은 주제를 반복하는 아이콘 장식이 추가됐다. 첫 타격 효과가 다음 타격 뒤에도 남는 경우가 있어 네 영웅이 한 표적에 화력을 집중할 때 마지막 박자와 적 예고를 읽기 어려울 수 있다. [직전 강타 개선](../evidence/hero-force-feedback-20261121/README.md)

| 공식 사례 | 확인한 표현 | TLT 적용 |
| --- | --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 실제 타격 영역을 애니메이션과 맞추고, 무기나 주문 방향을 피격에 전달한다. 전투 화면에서는 적 예고와 피해 영역 등 판단에 필요한 정보를 우선한다. | 서버가 알린 타격 순서와 위치에 효과를 연결한다. 방패벽의 전진과 폭풍의 수축을 서로 다른 방향으로 보여 준다. [Blizzard 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · The War Within 11.2 | Spell Density는 전투 판단에 덜 중요한 주문 효과를 줄인다. | 아군 궁극기는 방패, 능선, 포탄 불티, 화살 부채, 수관, 용암 분출, 서리 소용돌이의 주요 실루엣을 남기고 겹치는 아이콘 획과 장식을 줄인다. [Blizzard 업데이트](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) |
| Lost Ark 글로벌 · Souleater 소개, 2023년 11월 | Deathbringer는 교대하는 네 번의 베기 뒤 앞을 내려친다. The End는 흡인과 연속 피해 뒤 다른 동작으로 마무리한다. | Knight와 Mage의 마지막 타격에 각각 방패를 밀어 버티기, 검을 들어 올리기, 지팡이로 누르며 분출시키기, 유도 팔을 당겨 모으기를 적용한다. [Lost Ark Academy](https://www.playlostark.com/en-us/news/articles/souleater-academy) |
| Skullgirls · GDC 2014 Animation Bootcamp | 제한된 프레임 안에서 중요한 자세와 회수 동작으로 힘과 반응성을 전달한다. | 기존 리그 곡선에 마지막 타격에만 나타나는 자세를 더한다. 시작, 타격 직후, 회수에서 관절이 연속인지 살핀다. [GDC 발표](https://gdcvault.com/play/1020575/) |
| Roblox Creator Hub · 하드웨어 QA | Studio는 화면과 입력을 검토할 수 있다. 프레임 시간 및 열에 따른 성능 저하는 실기기에서 확인한다. | 같은 Studio 카메라에서 네 영웅 겹침의 효과 수, 적 예고와 피해 숫자를 비교한다. 저사양 터치 기기의 장시간 플레이는 별도 수용 항목이다. [하드웨어 검증](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

큰 광량이나 추가 카메라 연출도 마지막 타격을 강조할 수 있지만, 네 영웅이 동시에 발동하면 적의 경계를 가리는 비용이 크다. 이번에는 같은 타격 시점에서 자세와 효과의 방향을 바꾸고, 첫 효과의 수명을 다음 타격 간격 안으로 줄였다. 장비 소켓, 서버 판정과 쿨다운은 기존 전투 계약을 따른다. 비교 확인은 공식 기술 설명과 개발자 자료에 기반했다. 참고 게임의 실제 프레임 시간과 실시간 플레이 체감은 미측정이다. [TLT Studio 검증](../evidence/hero-ultimate-finish-20261121/README.md)
