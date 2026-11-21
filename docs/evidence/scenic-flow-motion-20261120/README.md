# 개울·폭포·용암의 흐름 표현

2026-11-20 · TLT-061 · TLT-063 · 사용자 피드백 후속

[Studio 연속 프레임](motion.gif) · [동일 카메라 전후](comparison.jpg) · [고정 빌드 0.114.39](build.json) · [동작과 동선 측정](studio-results.json)

이전 빌드의 개울과 폭포는 고정 청록 면에 가까웠고, 용암의 밝은 면은 Studio에서 노란색으로 뭉쳐 보였다. 물은 하류의 밝은 물살, 낙하 속도가 서로 다른 물줄기, 소에서 퍼지는 거품과 비산으로 나눴다. 용암은 암적색 표면과 검은 응고 조각 사이에 주황색 균열을 만들고 작은 열줄기만 느리게 아래로 이동시켰다.

| 적용 장소 | 표현 |
| --- | --- |
| Deepwood 개울 사건 3곳 | 젖은 실트 가장자리와 하류로 이동하는 얇은 물살 |
| Waterfall Quarry | 낙수 하단에서 퍼지는 물줄기, 물받이에 닿는 포말, 웅덩이에서 흘러나가는 물살 |
| Ember Caldera EC-01/03/04/07 | 어두운 응고 조각과 붉은 용암 표면, 주황색 균열을 따라 흐르는 열줄기 |

Diablo IV의 기술 아트 자료에서 색으로 깊이와 교란을 구분하는 방식, WoW의 자연 낙수와 제련 장면의 대비, Lost Ark Antares의 어두운 화산 경관을 참고했다. Roblox 기본 형상·재질에서 재현했다. [Diablo IV 그래픽 제작기](https://news.blizzard.com/en-gb/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv) · [WoW 지역 자료](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) · [Lost Ark North Kurzan 자료](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)

클라이언트가 카메라 주변의 장식만 초당 최대 30회 갱신한다. 액체 장식의 경로·속도는 서버가 복제하고, 클라이언트는 위치·투명도·포말 크기를 그린다. 배치 위치와 보행 바닥, 징검돌 및 기존 서버 진행 계약은 유지했다.

## 검증

- [첫 후보 0.114.36](build-0.114.36.json)에서 흐름 동작을 확인했다. 화면에서 낙수 하단과 소가 끊겨 보이고 용암이 그늘에 묻혀, [0.114.37](build-0.114.37.json)에서 젖은 물가와 주황색 균열을 추가했다. [0.114.38](build-0.114.38.json)에서 수면을 주변 바닥 위로 올려도 얇은 구형 부품이 화면에서 점처럼 보였다. 0.114.39에서는 소·거품·용암층에 축마다 크기를 설정할 수 있는 타원체를 적용했고 열줄기는 폭과 길이를 유지하는 얇은 기본 부품으로 교체했다. [Roblox SpecialMesh](https://create.roblox.com/docs/reference/engine/classes/SpecialMesh)
- 격리 Studio에서 대표 3개 장면의 동일 시점으로 기준 프레임 각 1장, 후보 시간 표본 각 10장을 캡처했다. GIF는 캡처한 프레임을 물과 용암의 실제 표본 간격에 맞춰 재생한다.
- Lua 소품 문맥 4,264건, 에픽 내비게이션 105,907건, 전투 경로 77,381건을 통과했다.
- 92개 이동 요소의 방향, 속도, 양 끝점 및 물리 속성을 확인했다. 후보와 기준의 에픽 경로 표본은 38,205개이며 바닥 실패, 차단, 서버 위치 보정, 경로 실패가 각각 0이었다.

후보인 0.114.39 검사에만 `--candidate`를 추가한다.

```sh
python3 docs/evidence/scenic-flow-motion-20261120/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/scenic-flow-motion-20261120/compare.py "$baseline_log" "$candidate_log"
```

다음 담당은 환경 아트·QA다. 실제 플레이어 카메라에서 폭포 하단, 원거리 용암의 그늘, 모바일에서의 프레임 비용을 확인한다. 게시 클라이언트·실기기·멀티플레이 스트리밍·사용자 미술 수용은 미검증이다.
