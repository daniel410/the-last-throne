# Deepwood 물길과 Ember Caldera 용암 지형

2026-11-20 · TLT-061 · TLT-063 · G5 진행 중

[고정 빌드 0.114.35](build.json) · [Studio 전후 비교](comparison.jpg) · [Studio 측정](studio-results.json)

## 환경 제작

| 장면 | 적용 |
| --- | --- |
| DW-01 Creekside Cargo 및 Deepwood의 개울 사건 | 기존 교차석 세 곳을 기준으로 개울을 높이가 낮은 여섯 굽이와 물결로 표현했다. 마차가 건넜던 흔적을 조사하는 위치를 유지한다. |
| DW-S2 Waterfall Quarry / DW-Q3 | 석회암 채석장의 상류, 부서진 암벽, 세 갈래 낙수, 소와 하류 굽이를 연속된 형상으로 연결했다. Fen의 운반로 반대쪽 외곽 선반에 두었다. |
| EC-01 / EC-03 / EC-04 / EC-07 | Ash Spire 입구와 광산 균열, 냉각 지대, 대용광로 주변에 비대칭 현무암 분출구와 수반을 배치했다. 뜨거운 용암 중심, 암적색 가장자리, 식은 현무암으로 깊이와 진행 방향을 표현했다. |

Diablo IV의 Scosglen 해안 사례는 지면과 주변 재질을 함께 바꿔 물가를 읽히게 한다. WoW의 Isle of Dorn 폭포와 Ringing Deeps 제련 구역은 낙수와 화산열을 서로 다른 지형 실루엣으로 보여 준다. Lost Ark의 North Kurzan은 Antares 분화구를 전장 원경과 연결한다. 이 작업은 프로젝트의 공유 TD 숲·화산 자산 위에 필요한 물길과 유출 지형을 Roblox 기본 형상으로 추가했다. [Diablo IV 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) · [The War Within 지역 소개](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) · [Lost Ark Arkesia Ignited](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)

## 검증

- 기준은 0.114.28이다. [0.114.29](build-0.114.29.json)에서 안전 폭을 충족하는 폭포 후보가 없어 [0.114.30](build-0.114.30.json)에서 채석장 외곽 선반에 재배치했다.
- Ash Spire는 [0.114.32](build-0.114.32.json)에서 기존 능선에 가렸고, 가까운 능선을 사용한 [0.114.33](build-0.114.33.json)과 [0.114.34](build-0.114.34.json)는 실제 Studio의 동선 여유 검사를 통과하지 못했다. 0.114.35는 이미 안전 폭을 통과한 외곽 위치에 분출 단면과 받이 선반을 높여 배치했다.
- Lua 이야기 소품 문맥 4,264건, 에픽 내비게이션 105,907건, 전투 경로 77,381건을 통과했다.
- 격리 Studio에서 전후 고정 카메라 6쌍을 캡처했다. 폭포 34부품, 개울 장면 22부품, 용암 네 곳 61부품이 생성됐다. 모든 측정 부품의 앵커·충돌·쿼리·터치 상태를 확인했다. 폭포 선반의 바닥 표본 높이 차이는 0스터드였다.
- Ash Spire 지면 위 눈높이 관측점 33곳 중 32곳에서 분출구에 시선이 닿았고, 가장 잘 보이는 지점에서는 5개 표본 모두 닿았다. 비교 사진의 낮은 구도에서는 주변 능선 위로 용암 중심부가 보인다.
- 두 빌드의 전체 에픽 경로 38,205개 표본에서 바닥 실패, 차단, 서버 위치 보정, 경로 실패가 모두 0이었다. 용암은 경치용이며 피해 판정이나 전역 물 설정을 추가하지 않았다.

```sh
# 후보 빌드를 검사할 때만 --candidate를 추가한다.
python3 docs/evidence/scenic-water-and-lava-20261120/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/scenic-water-and-lava-20261120/compare.py "$baseline_log" "$candidate_log"
```

다음 담당은 환경 아트·QA다. 채석장 운반로 접근과 칼데라 전투 카메라에서 가림을 확인한다. 게시 클라이언트, 실제 플레이 입력, 실기기, 멀티플레이 스트리밍 및 사용자 미술 수용은 미검증이다.
