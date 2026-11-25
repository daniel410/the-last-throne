# 성광 방출·포탄 착탄·표식 개화·빙편 투척의 동작 비교

2026-11-25 · TLT-033/057/059

기준 0.115.109에서 Dawn Burst는 전신 회전과 일반 성광 원형 효과를 공유했다. Shell Burst는 한 발의 금속탄이 내려온 뒤 일반 폭발과 추가 구형 섬광이 겹쳤다. Bloom Shot은 엄폐 끝이나 빈 곳에도 잎 다섯 장을 그렸으며, Ice Shard의 끝점에 있는 빙편은 Frost Lance와 같은 조형 경로를 사용했다. 기존 [아이콘 대응표](../../assets/effects/skill-icon-vfx-v1/manifest.json), [전방 방출](../evidence/hero-directional-releases-20261125/README.md), [표식 소모](../evidence/hero-mark-break-releases-20261125/README.md), 그리고 캐릭터 소켓과 확정 명중 경로를 대조했다.

| 공식 자료 | 확인한 내용과 적용 |
| --- | --- |
| Diablo IV · 2021-12 출시 전 개발자 업데이트 | 공격과 피격 효과의 방향을 연결하고 몬스터 예고와 전투 상태의 화면 우선순위를 설명한다. 빙편의 손→끝점 경로, 포탄의 한 번의 착탄, 표식이 실제로 소비될 때 피격 지점에서 벌어지는 잎을 설계하는 근거로 삼았다. |
| WoW Retail · Legion 7.3과 The War Within 11.2 | 준비 동작으로 주문이 모이는 과정과 짧은 방출의 무게를 표현한다. Spell Density는 전투 판단에 필요한 주문 표시를 남기는 방향이다. 방패 안에서 성광을 모으는 자세와 두 손의 역할을 분리한 빙편 투척을 적용했다. 아군 화면에는 핵심 형상이 남는다. |
| Lost Ark 글로벌 · 2021 Warrior/Gunner 소개와 2024년 1월 업데이트 | Paladin은 성광 공격과 파티 지원을 함께 사용한다. Artillerist Missile Barrage는 탄약이 내려와 지정 지점에서 터지고, Sharpshooter는 활의 조준과 방출로 무기 정체성을 만든다. Sorceress의 Ice Shower 시전 속도 조정은 같은 냉기 계열에서도 박자가 중요하다는 사례다. TLT에서는 한 발의 금속 포탄, 실제 수혜자 보호막, 가벼운 저각도 단일 빙편으로 변형했다. |
| Roblox Creator Hub · 실기기 테스트 | 기기 에뮬레이터는 실제 메모리·프레임 시간·열·입력 조건을 재현하지 못한다. Studio에서는 동일 카메라로 형상과 타이밍을 비교하고, 아군 효과의 Beam과 메시 수를 계측한다. |

2026-11-25에 공식 개발 문서와 직업 안내를 열람했다. 직업별 패치 수치와 직접 플레이 계측은 범위 밖이다. [Diablo IV 전투와 VFX](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) · [WoW Legion 7.3](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) · [WoW 11.2](https://news.blizzard.com/en-us/article/24226698/ghosts-of-k-aresh-content-update-notes) · [Lost Ark Warrior](https://www.playlostark.com/en-us/news/articles/warrior-advanced-classes) · [Lost Ark Gunner](https://www.playlostark.com/en-us/news/articles/gunner-advanced-classes) · [Lost Ark 2024-01](https://www.playlostark.com/en-us/news/articles/january-2024-release-notes) · [Roblox 실기기 검사](https://create.roblox.com/docs/performance-optimization/test-on-hardware)

동일 카메라에서 성광 중심과 사거리, 금속탄과 착탄의 연결, 화살과 개화의 분리, 빙편의 엄폐 끝점을 확인한다. 근접 엄폐로 손이 끝점보다 앞서는 경우 잔상과 빙편이 시전자 쪽으로 줄어들어야 한다. 표식 소모와 자세 붕괴가 같은 명중에서 확정되면 두 신호를 보여준다. 전투 수치·진도·기존 보호 권위는 서버 계약을 따른다.
