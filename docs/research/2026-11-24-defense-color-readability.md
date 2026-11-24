# 디펜스 화면 대비와 TLT 색 표현

2026-11-24 · TLT-028/033/043/052 · 비교 기준 0.115.75

가든디펜스의 0:05 선택 화면은 밝은 녹색 면·강한 테두리로 선택을 보여준다. 3:35 전투 화면은 배경이 어두운 구간에서도 체력바와 노란 공격선을 읽을 수 있다. 스낵디펜스 업데이트 3 영상의 6:55에서는 밝고 채도 높은 잔디와 굵은 원소색이 함께 보인다. 이 영상에서 엔진의 조명·후처리 수치까지 확인할 수는 없다. [Garden Defense! 플레이](https://www.youtube.com/watch?v=TzVTrlTHylM&t=215s) · [SNACK Defense! 플레이](https://www.youtube.com/watch?v=avztJe7pYvk&t=415s)

- **UI**에는 높은 채도의 색을 얇은 상태 표시와 자원 채움에 배치한다. RPG의 승인된 TD 프레임·아이콘과 HP 원본 위에 코드로 그린 MP 그라데이션과 탭 선택선을 더한다. 가방에서 선택한 아이템은 민트색 테두리와 내부 색으로 표시하고 선택 장식의 금색을 유지한다. [Roblox UIGradient와 UIStroke](https://create.roblox.com/docs/ui/appearance-modifiers)
- **Deepwood**는 런타임 지면 마감이 사용하는 지역 팔레트와 주간 그늘의 밝기, 대기 대비를 함께 조정한다. 로비·기타 지역의 프로필과 전투 바닥 예고를 유지하고 Deepwood의 동일 카메라에서 전후를 검증한다. [Roblox 조명](https://create.roblox.com/docs/environment/lighting) · [후처리](https://create.roblox.com/docs/environment/post-processing-effects)
- **영웅 VFX**는 원소색 획을 먼저 읽히게 하고, 짧은 밝은 핵 주변의 부드러운 빛을 좁힌다. 디아블로 IV의 전투 정보 우선순위, WoW Retail Midnight의 전투 상태 판독 방향, 로스트아크 글로벌 Aeromancer의 원소별 형태를 보완 근거로 삼았다. [Diablo IV 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) · [WoW Midnight](https://news.blizzard.com/en-gb/article/24235745/developer-insight-combat-for-everyone-in-midnight) · [Lost Ark Aeromancer](https://www.playlostark.com/en-gb/news/articles/lost-ark-academy-aeromancer)

같은 HUD 값, 지도 좌표·카메라, 시전 시간에서 전후를 비교한다. 선택 정보와 적의 위험 표시가 파티 효과 중에도 구별되는지는 게시 4인전과 터치 실기기에서 확인한다.
