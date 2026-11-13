# 인기 Roblox RPG VFX 참고와 적용

TLT-033/057 · 2026-11-13 확인 · DES/ENG 조사·구현 범위. 게임성 비교의 기본인 Diablo IV/WoW를 먼저 재확인하고, 사용자 요청에 따라 Roblox 사례를 중심으로 적용했다. 직접 플레이·현행 스킬 전수 분석·영상 프레임 분석은 수행하지 않았다.

## 선정과 확인 범위

[Roblox 공식 RPG 소개](https://www.roblox.com/spotlight/roleplaying-games)는 인기 사례로 World // Zero·Dungeon Heroes·Deepwoken을 소개한다. [공식 게임 탐색](https://www.roblox.com/games/)의 검색 색인에는 Blox Fruits가 대규모 플레이 사례로 노출된다. 이는 선정 근거이며 전체 RPG의 실시간 순위를 확정한 자료가 아니다. 원본 Dungeon Quest와 Reborn은 별개이므로 검색 결과의 수치·영상을 섞지 않았다. 확인일과 검색 색인 시점은 다르므로 현재 동시 접속자 수를 전재하지 않는다.

| 출처·시점 | 실제 확인과 한계 | 우리 게임의 적용 판단 |
| --- | --- | --- |
| [Diablo IV 개발자 VFX 설명](https://news.blizzard.com/en-gb/article/23746639/diablo-iv-quarterly-updatedecember-2021), 2021-12 개발 중 자료 | 전투 가독성과 효과의 정밀한 시간 구성을 우선한다는 공식 설명 재확인. 현행 라이브 수치/프레임 근거가 아님 | 넓고 오래 남는 구체 대신 짧은 중심 섬광과 퍼지는 꼬리를 분리 |
| [WoW Retail 7.3 전투 애니메이션](https://worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic), 2017-08-16 | 검색에서 직업/전문화 시각 정체성과 기존 주문 요소 보존 원칙 확인. 본문 재열람은403으로 제한됐고 [기존 조사](2026-11-12-wow-vfx.md)를 함께 사용. Classic/현행 Retail과 혼합하지 않음 | 원소 형상·금빛 성기사·전용 Wind Lance 보존 |
| Blox Fruits, [Gamer Robot 공식 Dragon 쇼케이스](https://www.youtube.com/watch?v=z-i1pAF6FjE), 2024-12-12; [개발자 공개 이미지를 실은 기사](https://www.destructoid.com/blox-fruits-dragon-rework-update-details-and-release-date/), 2024-04-11/08-28 | 기사 속 [실제 이미지](https://www.destructoid.com/wp-content/uploads/2024/04/Blox-Fruits-Dragon-Rework.png) 직접 열람: 넓은 주황 곡선 띠, 좁고 밝은 가장자리, 방사 불꽃·검은 빈 공간을 확인. 공식 영상은 존재/게시자만 확인했으며 전체 재생이나 타임코드 분석은 하지 않음. 당시 공개 이미지가 현행 스킬 외형이라는 주장은 하지 않음 | 화염 꼬리를 가늘어지는 면으로 보강. 화염/폭발/대지의 충격파를 열린 곡선 띠로 표현. 섬 전체를 덮는 스케일은1~4인/터치 가독성 때문에 제외 |
| World // Zero, [공식 계정 공개 이미지](https://twitter.com/WorldZeroGame/status/1191442495873245184), 2019 Alpha | [공식 이미지 원본](https://pbs.twimg.com/media/EIjajsKVAAAqrUA.jpg) 직접 열람: 청색 검/기류와 금빛 세로 검/상승광이 구별되고 영웅 실루엣이 중앙에 남는다. 홍보 정지 이미지이며 현행 전투 속도/성능 근거가 아님 | 성기사는 금빛 인장과 상승광을 유지·보강. 물은 중앙이 비는 띠로 바꿔 캐릭터/바닥을 노출. 직업/성장 체계 복제는 제외 |
| Deepwoken, [공개 플레이 화면](https://www.destructoid.com/deepwoken-complete-lower-erisia-guide/), 2024-11 이미지 경로 | 기사 본문 재열람 제한. [이미지](https://www.destructoid.com/wp-content/uploads/2024/11/complete-lower-erisia-guide-in-deepwoken-turning-off-void-walkers.png) 직접 열람에서는 작은 무기 불꽃과 주변 공간이 보임. 이 화면만으로 패리 동작/시간을 검증할 수 없어 패리 시스템은 적용 근거에서 제외 | 무기/영웅을 가리지 않는 국소 명중광의 보완 비교만 사용 |

## 채택·비용·최소 실험

채택: 움직이는 검기 면, 겹치는 두 화염 꼬리, 비어 있는 물/대지/폭발 충격파, 명중 중심광0.08초와 충격파0.23초 분리. 구체적인 크기·시간은 우리 게임의 미술 선택이며 타 게임에서 측정한 수치가 아니다. 새 외부 이미지/메시/스크립트를 가져오거나 재배포하지 않았다. 서버 정의·위험 예고·실제 범위·시전/타격 이벤트·원소 계약과 충돌하지 않는다.

비용/위험: 절차적 삼각면과 매 프레임 CFrame 갱신이 늘어 GPU 오버드로/CPU 비용이 증가할 수 있다. 기존 면160/터치80·Beam240/터치144·입자192/터치96·동시12/터치8 제한을 유지한다. 예산 포화 시 선택 장식 일부가 생략되므로 기본 범위 표현은 계속 남긴다. 풀링/성능 개선은 측정 근거가 없어 주장하지 않는다.

최소 실험은 동일 모형·조명·카메라의11장면 전후, 실제 엔진128기술 회귀, 검기/화염/물/대지의 시각 샘플 이동, 프레임 이력 독립성, 명중광/잔상 분리·만료·포화 후 정리 검사다. [구현 증거](../evidence/roblox-rpg-vfx-20261113/README.md).

후속 ART/QA: 실제 TD 영웅/장비와 밝고 어두운 지역·4인+AI·터치/패드에서 형상만으로 원소/공격 방향이 읽히는지, 위험 바닥/목표가 보이는지 확인한다. 같은 기기의 GPU/프레임 시간·첫 로드·사용자 미술 수용은 별도이며 격리 검사를 전체 티켓 Done으로 처리하지 않는다.
