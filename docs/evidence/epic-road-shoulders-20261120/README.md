# 다섯 에픽의 도보 경계와 빈 출하 운반대

2026-11-20 · TLT-061, TLT-065, TLT-062, TLT-063, TLT-064 · G5 진행 중

[0.114.28 고정 빌드](build.json) · [Studio 비교](comparison.jpg) · [Studio 측정](studio-results.json) · [앞선 결말 지물 검증](../epic-finale-dispatch-20261120/README.md)

## 환경 아트와 3D 모델링

- Diablo IV는 Neyrelle의 행방을 따라 Nahantu의 수문으로 진입시키며 다음 장의 목적을 지형 입구에 연결한다. TLT의 GW-07에서는 Tali가 알려 주는 북쪽 설원행을 어두운 셰일 위 첫눈으로 예고한다. [Vessel of Hatred 공식 소개](https://news.blizzard.com/en-us/article/24140359/what-you-need-to-know-for-vessel-of-hatreds-launch)
- WoW의 Ringing Deeps는 제련소 복구를 지역 이야기로 삼고, Stonevault 전투 뒤 광차가 다음 구간을 잇는다. EC-07에서는 제련소 재가동 뒤 확인하는 빈 고정부와 출하 기록이 이미 떠난 Crownheart를 추적하는 단서가 된다. [The War Within 공식 지역·던전 소개](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)
- Lost Ark는 Elnead 해방과 동맹 집결을 거쳐 Antares 화산이 보이는 North Kurzan 전장으로 이어진다. TLT에서는 결말의 조사와 다음 지역의 재질이 하나의 도보 동선에서 이어지도록 구성했다. [Arkesia Ignited 공식 릴리스 노트](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)

| 도보 구간 | 환경 변화 |
| --- | --- |
| Deepwood → Gloamwood | Black Root Altar의 적재로에서 낮은 흙 가장자리를 지나 Gloamwood의 어두운 셰일로 들어간다. |
| Gloamwood → Frozen Vale | Windgap의 셰일에서 차갑고 낮은 첫눈을 거쳐 높고 밝은 눈 둔덕으로 바뀐다. |
| Frozen Vale → Ember Caldera | 기존 해빙로 위에서 눈 둔덕이 낮아지고 반대편에 현무암 지층이 드러난다. |
| Ember Caldera → Haunted Graveyard | 식은 현무암에서 풍화된 돌을 지나 묘지 관리로의 밝은 석재로 이어진다. |

길어깨는 기존 96스터드 도로 바닥에 걸친 Roblox 기본 웨지 조립체다. 지형 재질과 색은 프로젝트 지역 팔레트를 사용했다. EC-07의 `exp_2:step1` 운반대는 기존 썰매 위에 원통 축받침, 바깥으로 열린 두 죠와 테두리가 둘러싼 빈 키 홈을 배치했다. Suri 옆 대형 롤러는 별도의 이송 기반이다. HG-07 왕릉 보호턱과 Dawnspire 귀환 진입점의 기존 배치를 검토했다.

## 검증

- 고정 화면에서 GW 첫눈은 밤에도 도로 표면과 구분되고 EC 운반대의 빈 키 홈은 가까운 접근 각도에서 보인다. FV→EC 중간 카메라에서는 멀리 있는 현무암의 윤곽이 어두운 배경에 묻힌다.

- Lua 이야기 소품 문맥 4,264건, 에픽 내비게이션 105,907건, 전투 경로 77,381건을 통과했다.
- Studio에서 서버와 공유 Luau 기준 320개, 후보 321개를 컴파일했다. 두 빌드에서 각 8방향 도착, 점프 0회, 서버 위치 보정 0회를 확인했다. 도로 4개의 위치·크기와 재호출 시 도로 수가 일치했다.
- 길어깨 48부품 모두 물리 충돌·쿼리·터치가 꺼져 있고 바닥에 0.2스터드 이상 들어간다. 중앙선에서 가장 가까운 외곽은 32.9스터드, 최대 높이는 2.97스터드다.
- EC-07 운반대는 11→18부품이다. 피벗과 수평 외곽이 일치하고 높이 차이는 0.001스터드 미만이다. Studio에서 수집 상태의 청록색 적용과 미수집 상태의 원래 색 복귀를 18부품 모두 확인했다.
- 보행은 격리 Place의 R15 자동 이동이며, 캡처는 동일 시점의 고정 카메라 5쌍이다.

각 빌드에서 같은 검사를 실행한다. 0.114.28에서만 `--candidate`를 추가한다.

```sh
python3 docs/evidence/epic-road-shoulders-20261120/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/epic-road-shoulders-20261120/compare.py "$baseline_log" "$candidate_log"
```

다음 담당은 환경 아트·QA다. 실제 입력으로 EC의 재가동부터 출하 기록 조사와 Suri 대화까지 이어서 확인하고, FV 재회와 HG 복원 뒤 귀환을 확인한다. 게시 클라이언트, 실기기, 멀티플레이 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.
