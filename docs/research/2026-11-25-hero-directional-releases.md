# 네 영웅의 전방 공격을 구별하는 방출 동작

2026-11-25 · TLT-033/057/059

## 관찰과 적용

직전 표식 소모 작업에 이어 0.115.106의 전방 공격 네 개를 선택했다. Guardian Slash의 방패 두 장식이 범위선과 일반 검호에 겹쳤다. Scatter Shot과 Fan Break는 서버가 계산한 다섯 방향을 이미 표시했지만 비슷한 시점에 화면에서 사라졌다. Lightning Line에는 낮은 중심선과 면이 같은 위치에 고정되어 있어 번개가 시전자에서 나가는 순서를 읽기 어려웠다. 초기 상태는 이전 [기술별 VFX 검증](../evidence/skill-icon-vfx-art-20261115/README.md)과 [표식 소모 작업](../evidence/hero-mark-break-releases-20261125/README.md), 현재 클라이언트 경로를 함께 확인했다.

| 공식 자료 | 관찰 | The Last Throne 적용 |
| --- | --- | --- |
| Diablo IV 개발자 업데이트 · 2021-12-20 · 출시 전 전투/VFX 시연 | 검격과 영역의 움직임을 피해 이벤트에 맞추고 타격 방향을 피격 효과에 연결한다. | 서버가 확정한 조준과 종료 위치를 사용한다. 기사 검호가 방패를 열며 앞으로 흐르고 번개의 머리가 시전자 쪽에서 확정 끝점까지 움직인다. |
| World of Warcraft Retail · Legion 7.3 개발자 소개(2017)와 The War Within 11.2(2025-08-05) | 직업과 주문의 준비·방출 자세를 구분한다. 11.2는 중요한 전투 정보 전달에 기여하지 않는 주문 장식을 줄이는 Spell Density를 설명한다. | Mage의 지팡이 준비와 빈손 방출을 분리한다. 같은 범위를 다시 그리는 검호와 번개의 고정 면을 정리하고 아군 번개 가지 수를 줄인다. |
| Lost Ark 글로벌 · Warrior(2021-07-07), Gunner(2021-08-24) 직업 소개 | Paladin은 전방 검격 중에도 별도의 파티 보호를 제공한다. Artillerist의 Buckshot은 짧게 벌어지는 포격이며 Sharpshooter의 Charged Shot은 활의 준비와 방출이 구분된다. | 방패는 실제 수혜자에게 표시하고 검격은 금빛 날에 집중한다. 총은 짧은 포구 섬광과 산탄, 활은 시위 손 회수와 상대적으로 길게 남는 화살촉으로 구분한다. |
| Roblox Creator Hub · 실기기 검사 지침 | Studio 기기 에뮬레이션과 실기기 측정은 프레임 시간·열·입력 지연을 동등하게 재현하지 않는다. | Studio에서는 인스턴스 수와 예고선·피해 숫자를 비교한다. 실제 4인 교전과 저사양 터치에서의 체감·프레임 시간은 후속 수용으로 관리한다. |

공식 개발자 문서와 직업 소개를 2026-11-25에 확인했다. 해당 패치의 라이브 수치나 직접 플레이는 조사 범위 밖이다. [Diablo IV 전투·VFX](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) · [WoW Legion 7.3 시전 애니메이션](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [WoW 11.2 Spell Density](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) · [Lost Ark Warrior](https://www.playlostark.com/en-us/news/articles/warrior-advanced-classes) · [Lost Ark Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Roblox 실기기 검사](https://create.roblox.com/docs/performance-optimization/test-on-hardware)

## 비교 기준

동일 R6/R15 동작 구간에서 방패의 여닫힘, 포격의 왼팔과 뒷발 반동, 활의 시위 손, 마법사의 낮은 방출을 확인한다. 같은 엄폐 조건에서 산탄과 화살은 발별 확정 위치에, 번개는 서버가 보낸 끝점에 닿아야 한다. 좁은 카메라에서는 적의 붉은 경계와 실제 피해 숫자를 확인한다. 주 효과를 클라이언트에서 생략해야 할 때 기존 검격·발사선 대체 표시를 사용한다. 긴 지면 방전은 경사나 단차에서 높이 차가 생길 수 있으므로 실제 지역 경로의 카메라 검토에 포함한다.
