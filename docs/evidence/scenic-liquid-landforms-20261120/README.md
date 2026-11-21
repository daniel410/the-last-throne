# 개울·폭포·용암 형상 재작업

2026-11-20 · TLT-061 · TLT-063 · 사용자 미술 피드백 후속

[정면과 사선 비교](comparison.jpg) · [0.114.40 Studio 연속 프레임](motion.gif) · [이동·경로 결과](studio-results.json) · [고정 빌드](build.json)

0.114.39에서는 물살과 열줄기의 움직임이 보였으나, 길게 이어진 검은 물가, 평행한 낙수 판과 타원형 물받이, 갈라진 용암 덩어리가 지형에 얹힌 장식처럼 보였다. 이번 작업은 기존 유로와 카메라에서 주변 암석, 젖은 물가, 물·용암의 윤곽이 한 단면으로 이어지는지 검토했다.

Diablo IV 제작기의 깊이별 물색과 포말, WoW Isle of Dorn의 암벽 낙수와 Ringing Deeps의 암반 속 제련, Lost Ark Antares의 어두운 화산 경관을 참고했다. [Diablo IV 제작기](https://news.blizzard.com/en-gb/article/23964183/peeling-back-the-varnish-the-graphics-of-diablo-iv) · [The War Within 지역](https://news.blizzard.com/en-gb/article/24125258/explore-the-zones-and-dungeons-of-the-war-within) · [Lost Ark North Kurzan](https://www.playlostark.com/en-us/game/releases/arkesia-ignited)

## 변경

- 개울의 물가는 굽이마다 폭과 색이 달라지는 젖은 퇴적층으로 나누고, 징검돌 옆에 하류를 향하는 물결을 추가했다.
- Waterfall Quarry는 세 물줄기를 깊이·굽이·폭이 다른 단면으로 조형했다. 기울어진 암석 단면과 너덜지대가 사각 절벽의 윤곽을 끊고, 물줄기는 바위 사이의 세 수면과 기존 하류에 닿는다.
- Ember Caldera의 분출구 네 곳은 내리막에서 말단 선반까지 굽은 네 구간을 추가해 진행각을 단계적으로 바꾼다. 현무암 홈은 흐름을 받치고, 응고 가장자리 사이에 짧은 발광과 느린 열 자국이 남는다.

## 검증

- [0.114.40](build-0.114.40.json)의 폭포 사선 화면에서 새 암석이 두 물줄기의 하단을 가렸다. 0.114.41에서 해당 암석 두 개를 절벽 쪽으로 물린 뒤 같은 사선에서 낙수 하단과 소의 연결이 보였다. 기존 광산 암반은 기준과 후보에서 같은 사선 시점을 가린다.

- Studio에서 물살·포말·열 자국 91개의 위치, 이동 방향·속도와 비충돌 상태를 검사했다. 정면 화면에서 세 물줄기와 각 낙수점을 구별할 수 있고, 광산 용암은 낮은 선반으로 부드럽게 꺾인다.
- 기준·후보의 에픽 경로 38,205개 표본에서 차단, 바닥 실패, 서버 위치 보정, 경로 실패가 모두 0이었다.
- Lua 이야기 소품 문맥 4,264건, 에픽 내비게이션 105,907건, 전투 경로 77,381건을 통과했다.

## 재현

0.114.39와 후보를 각각 고정된 Place로 열고 같은 스크립트를 사용한다. 0.114.39와 0.114.41에서는 정면과 사선 다섯 곳의 첫 프레임을 촬영했다. 0.114.40에서는 `--static-only`를 빼고 정면 세 곳을 시간 표본 10장씩 캡처했다. 0.114.41의 연속 캡처는 Studio 응답 시간 초과가 발생해 GIF에는 0.114.40을 사용했다. 최종 배치의 차이는 폭포 옆 암석 두 개의 위치와 크기다.

```sh
python3 docs/evidence/scenic-flow-motion-20261120/prepare-studio.py --candidate --extra-views --static-only --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/scenic-flow-motion-20261120/compare.py "$baseline" "$candidate" \
  --baseline-version 0.114.39 --candidate-version 0.114.41 \
  --motion-candidate "$motion" --motion-version 0.114.40 \
  --output-dir docs/evidence/scenic-liquid-landforms-20261120
```

다음 담당은 환경 아트·QA다. 실제 카메라를 돌리며 지형과의 연결을 확인한다. Roblox 게시, 실기기, 멀티플레이 스트리밍 및 미술 수용은 미검증이다.
