# TLT-063 · EC-03 광산 구조 통로의 채굴 흔적

확인일 2026-11-15. 제작 스킬의 맵 구현·환경 아트·환경 3D·리서치 역할을 순차 수행한다. 대상은 PC/터치/패드·1~4인+AI의 EC-03이며, 이번 시험은 격리 Studio Edit다. G5 완료나 플레이 수용을 대신하지 않는다.

## 근거와 판단

- Diablo IV 개발 중 환경 아트, 2022-03-29 [공식 Quarterly Update](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) 본문 확인. 지역 정체성·사용 흔적과 자연스러운 팔레트를 통해 플레이를 위한 시각 공간을 확보한다는 제작 설명을 참고한다. 현행 시즌/수치 조사나 직접 플레이가 아니다.
- WoW Retail / Dragonflight 출시 전 Waking Shores, 2022-07-28 [공식 지역 소개](https://news.blizzard.com/en-us/article/23822253/dragonflight-zone-preview-the-waking-shores) 본문 확인. 하천이 퇴적암을 깎는 지형, 고도가 오를수록 거칠어지는 화산 지역과 건축의 관계를 관찰했다. WorldofWarcraft 도메인은403, 같은 Blizzard News 공식 본문으로 보완했다. Classic과 혼합하지 않는다.
- Roblox [Instance streaming](https://create.roblox.com/docs/workspace/streaming) 공식 본문 확인. Atomic 군집과 제한된 정적 메시 수를 사용하되 실제 스트리밍·메모리·성능의 증거로 해석하지 않는다.

이 게임은 TD 원본과 넓은 회피 공간을 유지해야 한다. 다른 게임의 화산·폐광 자산을 복제하거나 용암 위험/새 퀘스트를 추가하지 않는다. 제안은 전투 바닥을 더 밝고 복잡하게 만드는 대신 비전투 여백에 차가운 채굴 현무암 덩어리를 놓는 것이다. 인기나 수익과의 인과관계는 평가하지 않았다.

## 서사→제작표

| epic/story · 원천 | 사건/지역 | 지형·소품 표현/위치 | 전후 상태·플레이 목적 | 검증 |
| --- | --- | --- | --- | --- |
| Ember Caldera / EC-03 · CampaignStoryText EC-03, CampaignContent supports/worm/miners, CampaignExpansionContent EC-03 | 광산 지지대 복구→Magma Worm 저지→Orik/광부 구조→냉각 지도 회수 | 평탄 외곽 여백의 채굴 잔석3군집, 군집당 대/중/소3메시·옆으로 누운 현무암 기둥 | 이전 LayeredVegetation 실제0파트. 이후 차가운 잔석으로 채굴 흔적과 여백의 깊이를 표현. 진행 전후 공통 정적 배경이며 복구/보상 상태를 흉내내지 않는다 | 고정 빌드 전체 마감 후 메시/접지/충돌, 기존/Easy 접근·확장/연결 감사, 동일 주간 카메라 전후 |

`RegionalConceptProfiles`의 예전 명칭 Collapsed Resonance Mine보다 현재 구조 원고를 우선한다. 기존 지지대/승강기/구조 사건의 표시와 서버 진행은 유지한다. 처음에는 반복 바위의 교체를 예상했으나 baseline Studio에서 기존 배치 후보가 모두 보행 안전 검사로 제거되어0개임을 확인했다. 따라서 실제 비용은 감소가 아닌9메시 증가다.

## 자산·대안·최소 실험

Derived: ServerStorage.TDMapModels.VolcanoCliff/body_geom, MeshId rbxassetid://116034563819179. 원본은 assets/shared/td-deepwood-environment/maps.rbxmx이며 manifest SHA256 `4374cb7c66869fc1e9e9a8a3cc2f1fe5ee70564b5b875ed79232adf9542cfc39`/TD 원본 동일. 승인된 TD 공유 권한을 승계하며 게시 Experience 로딩 권한은 별도 미검증이다. Env.asset의 스크립트 없는 원본 복제·균일 크기22/13/8·회전만 사용한다. 기존 EpicEnvironmentKit의 차가운 바위 파생과 같은 취지로 원본 TextureID를 속성에 기록하고 런타임 파생에만 비발광 Basalt/지역 색을 적용한다. 원본 바이트는 보존하며 Blender는 사용하지 않았다.

기존 큰 절벽을 내부에 강제로 배치하는 대안은 통행 충돌 위험으로 기각했다. 전체 지형 재굴착은 구조 목표·확장 사건까지 영향이 커 이번 범위에서 보류한다. 추천은최대4군집/12파트의 작은 대표 구현이며 최종3군집/9파트가 안전 후보를 통과했다. 랜덤 소비는 기존 외곽 루프를 유지해 후속 다른 장식의 난수 위치를 보존한다.

배치 반경32·다른 군집과85stud, 평탄5점 높이차1stud, 구역 내부·확장 사건/연결 여유, 스폰/전투/목표 예약을 유지한다. 최종 통행 마감이 군집을 옮길 수 있으므로 실제 완성 장면에서 접지를 다시 검사한다. 기준: 최소3군집/3크기, 원본 메시 동일·단일 메시 각1, 총12이하, 물리충돌/쿼리·터치비활성, 두 경로의 차단/바닥/보정/안내/단차0. 실패는 증거에 보존한다.

다음 DES/QA: 실제 지역 조명·전투 카메라에서 잔석을 회피/목표와 구분할 수 있는지, 스트리밍·기기 성능·미술 수용을 확인한다. 전체 넓은 평지·단절된 원경의 재구성은 별도 큰 작업으로 남긴다.
