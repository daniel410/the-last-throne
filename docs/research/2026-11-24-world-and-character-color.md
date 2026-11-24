# 로비·지역·캐릭터의 색과 실루엣

2026-11-24 · TLT-033/057/060~065 · 기준 0.115.76

Garden Defense!의 낮은 배경 대비 속 밝은 공격 표시, SNACK Defense!의 큰 색면과 선명한 캐릭터 가장자리를 참고했다. TLT는 주간 지도와 야간 경로가 같은 원정에 있으므로 색이 강조되는 지점을 목적지·몬스터·캐릭터 장비에 배치했다. 화면을 보고 적용한 원리이며 두 Roblox 작품의 내부 조명이나 재질값은 확인하지 않았다. [앞선 프레임 검토와 적용 근거](2026-11-24-defense-color-readability.md)

| 근거 | 선택한 적용 |
| --- | --- |
| Diablo IV 개발자 글은 순광과 그림자, 재질의 대비로 캐릭터와 세계를 함께 읽게 하는 접근을 다룬다. | 몬스터 원본 표면을 보존하고 근처의 외곽과 보스·시전자 재질에만 색을 더한다. [Blizzard Graphics](https://news.blizzard.com/en-us/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv) |
| WoW Retail Midnight의 지역 소개에서 Eversong Woods와 Harandar는 독립된 자연색·구조를 사용한다. | Gloamwood의 보랏빛 표식·청록 그늘과 Haunted Graveyard의 회보라 돌·민트빛을 구별한다. [Blizzard Midnight](https://worldofwarcraft.blizzard.com/en-us/midnight) |
| Lost Ark 글로벌 Elgacia 소개는 빛과 건축을 지역의 성격에 연결한다. | Dawnspire의 청색 왕좌·금색 난간·크림색 거점, Frozen Vale의 차가운 얼음과 따뜻한 피난처 신호를 별개로 잡는다. [Lost Ark Elgacia](https://www.playlostark.com/en-gb/news/articles/elgacia-lore-interview-with-gold-river) |

| 장소·대상 | 서사 또는 플레이 기능 | 실제 변경 |
| --- | --- | --- |
| Dawnspire | 광장 진입, 귀환 축, 시설 확인 | 밝은 석재와 청색·금색 행렬로 테두리, 시설 팔레트와 낮 그늘 |
| Deepwood | 보급대 추적과 구조 경로 | 주간 녹색 지면을 이어가며 따뜻한 표식·등불 받침을 강조 |
| Gloamwood | 흩어진 정찰대와 야간 탐색 | 청록 지표, 보라색 표식, 자정 상태에서 대상 색 대비 |
| Frozen Vale | 구조와 신호 복원 | 청색 얼음과 호박색 피난처 표식, 눈보라 복구 전후 대기 |
| Ember Caldera | 설비·광석과 가열 위험 | 보라 섞인 현무암·구리색 설비·높은 채도의 주황 표식 |
| Haunted Graveyard | 기록 확인과 귀환로 확보 | 회보라 석재와 민트색 표식, 기존 야간 분기 |
| 전투 훈련 | 단판에서 길·엄폐·표적 확인 | 지면·길·그늘 명암 |
| 영웅·몬스터·NPC | 플레이 카메라에서 직업, 적, 대화 상대 판독 | 갑옷 앞뒤의 직업색 금속 외장, 원소별 몬스터 외곽과 기존 주문 초점의 색, NPC 이름표·지역 표식 |

기존 지형의 충돌·경로와 원본 메시·텍스처·스켈레톤은 제품 계약을 따른다. 추가 파츠는 장식이며 적 실루엣은 가까운 10개로 제한하고 월드 깊이에 가린다. 게시 4인전과 터치 기기에서 실제 GPU 비용과 사용자의 미술 수용을 확인한다. [Roblox Highlight](https://create.roblox.com/docs/reference/engine/classes/Highlight)
