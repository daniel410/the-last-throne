# 개울·폭포·용암의 수면과 재질 개선

2026-11-20 · TLT-061 · TLT-063 · 사용자 피드백 후속

[동일 카메라 전후](comparison.jpg) · [동작 캡처](motion.gif) · [검증 데이터](studio-results.json) · [고정 빌드](build.json)

직전 형상에서 개울의 얕은 물가와 중심 깊이, 폭포 줄기의 마디와 소의 경계, 용암 몸체와 발광의 분리가 약했다. 수심마다 물색과 포말을 구분하는 Diablo IV 제작기, 암벽과 흐름이 붙어 보이는 WoW 지역 사례, 어두운 화산 암반과 분출구의 대비를 사용하는 Lost Ark의 Antares를 기준으로 기존 장면을 검토했다. [Diablo IV 제작기](https://news.blizzard.com/en-gb/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv) · [WoW 지역 소개](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) · [Lost Ark North Kurzan](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)

## 변경

- Creekside의 반투명 물가 아래로 자갈과 젖은 돌을 배치하고, 더 어두운 중심 수로로 수심이 깊어지는 지점을 구분했다.
- Waterfall Quarry는 짧은 둥근 연결부와 긴 둥근 낙수로 물줄기 마디를 줄였다. 소는 하나의 불규칙한 수면이며 얕은 자갈 선반을 아래에 배치했다.
- Ember Caldera 네 유로는 공통 단면을 공유하는 연속 면으로 조형했다. 암적색 중심과 얇고 불규칙한 응고 가장자리, 유로당 네 개의 느린 열 자국을 사용했다.

## 검증

- [0.114.43](build-0.114.43.json) 후보는 원통형 낙수의 가로·세로 차이가 화면에서 지나치게 가늘게 보였고, 두꺼운 용암 받침이 이음새 근처의 붉은 중심을 가렸다. 0.114.44에서 낙수 단면의 지름과 용암 받침 깊이를 보정했다.
- Lua 이야기 소품 문맥 4,264건, 에픽 내비게이션 105,907건, 전투 경로 77,381건을 통과했다.

- 동일 카메라 5쌍 및 최종 빌드 연속 프레임 20장 GIF를 보존했다. 정면에서 낙수 연결이 이어져 보이고 사선에서는 두 물줄기가 소에 닿는 지점이 보인다. 광산 용암은 정면에서 붉은 중심과 냉각 가장자리를 비교했고, 같은 사선은 두 빌드에서 기존 암반에 가렸다.
- 움직임 표본 83개의 이동 방향·속도·비충돌 속성을 확인했다. 기준·후보의 38,205개 동선 표본에서 바닥 실패, 차단, 서버 위치 보정 및 경로 실패가 각각 0이었다.

## 재현

기준 0.114.41은 `--static-only`를 추가한다. 두 빌드 모두 같은 시점의 눈높이 정면과 사선을 검사한다.

```sh
python3 docs/evidence/scenic-flow-motion-20261120/prepare-studio.py --candidate --extra-views --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/scenic-flow-motion-20261120/compare.py "$baseline" "$candidate" \
  --baseline-version 0.114.41 --candidate-version 0.114.44 \
  --output-dir docs/evidence/scenic-liquid-surfaces-20261120
```

Studio 확인은 격리 Place와 고정 카메라에서 수행했다. 실제 조작, Roblox 게시 클라이언트, 멀티플레이 스트리밍, 실기기 및 사용자 수용은 미검증이다.
