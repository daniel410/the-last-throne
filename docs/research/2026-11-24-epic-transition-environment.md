# 다섯 에픽 도보 경계의 도로 시설

2026-11-24 · TLT-061~065/overland · G5 · 환경 아트 → 환경 3D·맵 구현·QA

0.115.83 소스에서 네 연결로의 도로 바닥, 중앙 유도선과 양쪽 길어깨를 검토했다. 0.115.1 비교판의 DW 출구에서 흙 위 뿌리는 두 작은 목재 면으로 보이고, GW 야간의 밝은 압설은 남색 셰일과 구분된다. FV 쪽 원거리에서는 해빙 노두의 절단면 대비가 낮다. HG 진입에서는 밝은 절단석 앞면 뒤로 왕릉 건축이 보인다. 이번 제작은 길어깨 지형 위에 주민이 길을 관리하거나 썼던 흔적을 배치한다. 6장 피난·관측 동선에 추가한 다섯 지물과는 위치와 역할이 다르다. [기존 도보 경계 비교판](../evidence/epic-boundary-relief-20261121/comparison.jpg) · [6장 동선 지물](../evidence/epic-sixth-chapter-route-fixtures-20261124/README.md)

## 레퍼런스와 적용

- **Diablo IV** 환경 아트팀은 Scosglen 내륙에서 해안으로 나갈 때 바람에 눕는 풀로 기후 변화를 먼저 알린다. TLT의 설원 진입에서는 압설 높이와 말뚝 기울기를 맞춰 바람 방향을 하나로 읽히게 한다. [Blizzard 환경 아트 분기 보고](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- **World of Warcraft**는 Dragon Isles의 진행을 원시 해안, 열린 평원, 설산, 첨탑과 사원 순서로 소개한다. TLT에서는 다음 지역을 대표하는 설비 한 부분을 길 끝에 두고, 왕복할 때는 같은 물건의 뒷면과 이전 지역 경관이 보이게 한다. [Blizzard Dragonflight Deep Dive](https://worldofwarcraft.blizzard.com/en-us/news/23785116)
- **Lost Ark** 제작진은 Elgacia의 이야기 비중을 도서관과 사원 같은 생활·문화 시설의 고유한 디자인에 반영했다. TLT에서는 설원 석공, 칼데라 운송 노동자, 왕릉 관리인이 같은 도로를 각기 어떻게 손봤는지 부재와 정리 방식으로 구분한다. [Smilegate RPG 디렉터 인터뷰](https://www.playlostark.com/en-gb/news/articles/elgacia-lore-interview-with-gold-river)
- **Roblox The Mystery of Duvall Drive** 팀은 세계 안에서 자체 용도가 있는 물건으로 배경과 풀이 단서를 전달했다. TLT의 도로 시설은 기능을 형태로 읽히게 하고, 경로 안내는 기존 표식과 도로 유도선에 맡긴다. [Roblox Creator Hub 환경 서사](https://create.roblox.com/docs/resources/the-mystery-of-duvall-drive/immersive-narrative)

## 제작표

| 에픽과 위치 | 사건에서 이어지는 맥락 | 형상과 배치 |
| --- | --- | --- |
| Deepwood · DW-07 출구 | 보급대와 적 화물이 같은 길을 지나간 시기에도 갓길 관리는 필요했다. | `ConvoyVergeDrain`. 바퀴가 지나던 가장자리의 낮은 배수 홈, 길게 이어진 목재, 퇴적 토사. 수평 목재 결이 굽은 노출 뿌리와 구분된다. |
| Gloamwood · GW-07 출구 | Tali가 북쪽 갈림길을 확인할 때 이미 다니던 고갯길이다. | `WindgapSurveyRest`. 바람 방향을 따라 한쪽이 낮아지는 받침과 높이가 다른 측량 말뚝, 기저에 얕게 쌓인 눈. 목재 절단면으로 야간 윤곽을 확인한다. |
| Frozen Vale · FV-07 출구 | 마지막 거울 복구 후 Ivo가 EC행을 확인한다. 오래된 배수 시설은 해빙로의 구조를 설명한다. | `ThawCulvertHeadwall`. 옅은 상인방과 양옆 날개벽, 그늘진 수로 입구. 높이가 낮은 절개면이 기존 노두 아래 판독되는지 확인한다. |
| Ember Caldera · EC-07 출구 | 기록으로 확인한 출하 방향을 따라간다. 운송 설비는 화물이 다니던 길의 규격을 보여 준다. | `FreightRoadGauge`. 좁고 세로로 긴 뼈대, 무광 금속 규격판과 무거운 받침. 갓길 하나에 서는 크기로 도로 전체를 가로지르는 문처럼 보이는 구도를 피한다. |
| Haunted Graveyard · HG-01 진입 | 선발대는 기존 왕릉 관리로를 따라갔다. | `KeeperRoadWaypoint`. 관리로 쪽의 낮은 절단석과 정방형 정상부. 칼데라 설비보다 낮고 묵직한 윤곽을 사용한다. |

다섯 시설은 기존 지역 팔레트와 Roblox 기본 재질을 사용한 장식 조립체다. EC와 HG의 시설 두 곳은 같은 연결로의 출구와 진입부를 각각 맡는다. 시설은 일상적인 도로 관리 흔적으로 두고, 적 화물의 정체·최종 목표·선발대의 상태는 현행 퀘스트에서 공개한다. [도보 연결 계약](../product-contracts.md) · [서사 공개 순서](../production/campaign-context-review-2026-11-10.md)

고정 카메라에서 정방향과 역방향의 실루엣, 접지, 기존 금빛 유도선과의 겹침을 확인한다. 엔진 검증에서는 기존 도로 바닥과 왕복 R15 보행을 기준 빌드와 비교한다. 실제 조작에서 세부 형상이 처음 읽히는 거리와 터치 기기의 판독은 후속 수용 항목이다.
