# TLT-065 / GW-01 수색 능선

2026-11-15. 맵·환경 아트·환경 3D·리서치 역할 순차 수행. 직접 플레이 조사가 아니다.

- [Diablo IV March 2022 공식](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) 본문 확인: 지역 역사·재질·서사와 카메라상 전투 공간의 가독성을 함께 고려한다.
- [WoW Retail Dragonflight Deep Dive](https://worldofwarcraft.blizzard.com/en-us/news/23785116) 검색 요약에서 Azure Span의 큰 고도 변화와 산악 탐험 확인. 본문403으로 원문 전체 미확인. 현행 패치의 지형 규칙으로 취급하지 않는다.
- [Roblox Parts](https://create.roblox.com/docs/parts) 본문 확인: 고정 형상·충돌 속성의 구분. 이번에는 메시 증량 대신 Native Terrain을 사용한다.

적용 해석: GW-01 북쪽 화물 바퀴와 거미줄 방향 정찰대 발자국의 갈림길을 비우면서 외곽의 동일 절벽 반복을 비대칭 석질 능선과 초피 둔덕으로 교체한다. 실제 원천은 CampaignContent GW-01 및 현재 줄거리 문서의 동일 항목. 새로운 사건·상태·보상은 추가하지 않는다. 기존 FV-03 Native Terrain 제작 절차를 파생했으며 외부/TD 원본 바이트 변경 없음.

최소 실험은 GW-01 대표 구간 생성, 주변 지역/확장 공간/연결로의 전체 반경 보존, 실제 표면 재질·고도 감사 및 기존/Easy 경로 sweep이다. 전후 같은 카메라를 비교하고 실제 게임 카메라/기기 수용은 구분한다. 위험은 voxel 경계 팽창과 장거리 시야, 지역 생성 순서다. 보수적 반경8stud 여유·접속로 전체 예약과 후속 carve를 유지한다. 모바일/다인 성능은 미측정이다.
