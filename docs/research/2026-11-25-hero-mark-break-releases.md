# 표식을 소모하는 네 영웅 기술의 타격 연출

2026-11-25 · TLT-033/057/059 · 비교 기준 0.115.103

직전 개선은 이동 직후 무기와 발사선의 연결, 적 예고선과 아군 효과가 겹치는 문제를 다뤘다. 이번에는 제자리에서 준비하는 표식 소모 기술 네 개를 골랐다. 기준 빌드에서는 Oath Challenge의 부채꼴에 공통 파동과 베기 원호가 겹쳤다. Breaker Throw는 장착 도끼와 표적의 도끼가 함께 보였고, Mark Breaker의 일반 명중은 범용 관통 효과, Magma Spear의 발사선은 범용 불꽃 나선을 사용했다. 표식 소모 때에는 이미 기존 서버 확정 효과가 발동했다. [직전 이동 공격 비교](../evidence/hero-mobile-releases-20261124/README.md) · [표식 소모 서버·Studio 검사](../../tests/hero-mark-impact-native.luau)

| 비교 사례 | 공식 자료에서 확인한 동작 | TLT 적용 |
| --- | --- | --- |
| Diablo IV 개발자 전투·VFX 설명, 2021-12 | 휘두르는 무기와 판정 영역을 시간축에서 맞추고, 공격 방향을 피해 대상의 피격 효과에 전달한다. | 서버가 내보낸 원점·종점·방향을 기존 무기 시각과 연결하고 일반 명중 획을 무기별로 정렬한다. [개발자 글](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail Legion 7.3, 2017-08, The War Within 11.2, 2025-07 | 시전자가 힘을 모으는 준비 모션과 방출 자세를 나누고, 후속 패치의 Spell Density는 교전 정보의 중요도에 따라 효과 표시를 줄인다. | 방패·도끼·활·지팡이의 뒤쪽 준비와 앞발 제동을 달리한다. 아군 화면에서 부가 발광과 공통 섬광을 줄이고 적 예고를 우선한다. [Legion 제작 글](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [11.2 업데이트](https://worldofwarcraft.blizzard.com/en-us/news/24226698) |
| Lost Ark 글로벌, 2022-04~05 Academy 및 2021-07 클래스 소개 | Destroyer의 Earth Smasher는 무거운 무기 제동 뒤 파편을 앞으로 보낸다. Glaivier의 Thrust of Destruction은 응축 뒤 전방 방출로 이어진다. Sharpshooter의 Charged Shot은 조준·발사 자세로 활의 힘을 표현한다. | Breaker Throw는 어깨를 감았다 풀고, Mark Breaker는 시위 손을 뺨 뒤로 당긴다. Magma Spear는 빈손으로 힘을 퍼 올리고 지팡이 끝에서 가는 용암 축을 방출한다. [Destroyer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-destroyer-class) · [Glaivier](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-glaivier) · [Sharpshooter](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) |
| Roblox Creator Hub | Studio와 기기 에뮬레이터로 조작·레이아웃을 확인할 수 있으며 저사양 기기의 프레임 시간과 발열은 실제 기기 시험이 필요하다. | 동일 카메라의 R15 준비·일반 명중·표식 소모를 비교하고 Studio에서 본인·아군 표시 수, 벽 앞에서 끊긴 궤적과 R6/R15 재생을 검증한다. [실기기 시험](https://create.roblox.com/docs/performance-optimization/test-on-hardware) |

2026-11-25에 개발자 글, 공식 클래스 설명과 패치 노트를 확인했다. 관절 각도, 잔광 길이와 효과 수는 TLT에서 선택한 제작값이다. 표식 소모와 자세 붕괴가 같은 타격에서 확정되면 두 신호를 보존한다. 적중·엄폐·피해·표식 주인은 서버 판정을 따르며, 표식을 소모하지 않은 명중에서는 해당 무기 또는 원소의 두 획이 나온다.
