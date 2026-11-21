# 다섯 에픽 도보 경계의 접근·귀환 윤곽

2026-11-21 UTC · TLT-061, TLT-065, TLT-062, TLT-063, TLT-064 · 환경 아트 제작표

[0.115.1 Studio 동일 카메라 비교](../evidence/epic-boundary-relief-20261121/README.md)에서 DW 보급길 뿌리는 흙턱에 흩어진 작은 절단면처럼 보인다. GW 바람길의 첫 눈은 밤 화면에서 읽히지만 직사각형 모서리가 셰일과 분리되어 보인다. FV 해빙로는 중간과 귀환 화면에 노두가 보이고, 설원 쪽 첫 접근에서는 얇고 어두운 현무암 단면이 배후 둔덕과 겹친다. HG 관리로에서는 잘린 밝은 석면이 보인다. FV 외 세 경계의 귀환 방향은 해당 비교에서 관찰하지 않았다.

## 공식 사례와 적용 근거

- Diablo IV의 Scosglen은 해안에 도착하기 전에 바람 방향을 따른 긴 풀로 지형의 변화를 예고한다. 환경팀은 실제 게임 카메라에 맞춰 세부 밀도를 조절한다. TLT에서는 DW 쪽 뿌리의 길이와 주 갈래를 연결해 먼저 읽히게 하고, 그 너머 GW 셰일이 보이도록 높이를 낮게 유지한다. [Diablo IV 환경 제작 노트](https://news.blizzard.com/en-gb/article/23788294/diablo-iv-quarterly-updatemarch-2022)
- WoW의 The Azure Span은 숲, 탁 트인 툰드라, 눈과 얼음 봉우리가 고도에 따라 이어진다. TLT에서는 바람그늘 안쪽의 낮은 압설, 그 뒤의 큰 눈 둔덕 순으로 흰 면이 넓어진다. [Dragonflight Deep Dive](https://news.blizzard.com/en-us/article/23785116/world-of-warcraft-dragonflight-deep-dive)
- Lost Ark는 North Kurzan의 Antares 화산과 분연을 다음 전장의 맥락으로 제시한다. TLT에서는 제련 도시의 출현을 예고하는 해빙로의 현무암 단면에 이 원리를 적용한다. [Arkesia Ignited](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)
- Roblox의 환경 제작 가이드는 실제 이동 공간과 외부를 구분하고 재질로 주 이동 경로를 드러낸다. TLT에서는 기존 통행면을 기준으로 각 경계의 재질 변화를 길어깨에 배치한다. [Construct your world](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/construct-your-world)

## 장별 제작표

| 경계와 서사 역할 | 기존 로컬 모듈에서 조정할 형태 | 동일 카메라 수용 조건 |
| --- | --- | --- |
| DW-07 → GW-01. Eryn에게 보고한 화물 문서가 북쪽 Rootway로 이어진다. | `ConvoyVerge` 흙턱에 연속된 긴 목재 뿌리와 짧은 갈래를 매입한다. 따뜻한 목재 심재로 먼저 보이는 주 갈래를 만든다. | 전진·귀환 사선에서 주 뿌리의 가는 끝과 굵은 밑동이 연결되어 흙턱 밖으로 읽힌다. GW 쪽 낮은 셰일이 뒤에 보인다. |
| GW-07 → FV-01. Tali가 알려 준 북쪽 출구에서 조난자 수색길과 이어진다. | `WindPackedSnow`를 `WindgapShale` 발치에 포개고, 길을 따라 뾰족해지는 얕은 압설층으로 만든다. | GW 야간 접근에서 밝은 눈이 먼저 보이고, 귀환 시 눈 단면에 검은 셰일이 이어져 경계가 드러난다. |
| FV-07 → EC-01. 거울 복구와 두 마을의 재회 뒤 화물 승강기를 향한다. | `BasaltFracture`의 밝은 면을 `JointedBasalt` 옆면까지 이어 주며 높은 쪽과 낮은 쪽의 높이 차를 유지한다. 절리면은 밝은 슬레이트 계열로 처리한다. | FV 첫 접근과 중간에서 흰 압설, 노출된 단면, 승강기 외곽 순으로 구분된다. EC 귀환 시 어두운 둔덕 앞에서도 적어도 한 절리면이 읽힌다. |
| EC-07 → HG-01. Suri의 지도와 선발대가 조사한 피난처 접근로를 따라간다. | `KeeperDressedStone`의 가공면을 낮게 연결해 옛 관리로의 연속된 턱으로 보이게 한다. | 낮은 단차가 두 방향에서 오래된 관리로의 가공석으로 읽힌다. HG 입구와 피난처 쪽 조명의 위계가 유지된다. |

[현재 본편 서사](../production/campaign-context-review-2026-11-10.md)를 기준으로 길을 구성한다. 모델은 기존 `EpicEnvironmentKit` 팔레트와 네 경계의 길어깨를 바탕으로 만든다. 공유 공간에는 사전 노출할 수 있는 자연 지형과 오래된 시설만 배치한다. 검증에서는 0.115.1에서 측정한 길어깨 72부품, 중앙선 최소 이격 32.48스터드, 최대 노출 높이 5.53스터드를 비교 기준으로 삼는다. R15 왕복과 양방향 고정 카메라 확인 후 모바일 실제 입력과 첫 발견 시점을 별도로 관찰한다.

[Studio 전후 비교와 측정](../evidence/epic-boundary-approach-20261121/README.md)
