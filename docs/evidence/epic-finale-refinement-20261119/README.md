# 다섯 에픽 결말 지형 조형 개선 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

환경 아트가 0.113.25의 결말 장면을 검토하고, 환경 3D와 맵 구현이 기존 다섯 모델을 수정했다. 모델의 홈과 받침은 비충돌 고정 장식이다. [공식 RPG 사례와 제작표](../../research/2026-11-19-epic-finale-refinement.md)

| 스토리 | 조형 변경 | 부품 |
| --- | --- | ---: |
| DW-07 | 적재장 흙 가장자리를 낮추고 바퀴 홈을 목재 고임목까지 연결했다. | 11 |
| GW-07 | 회청색 셰일 단면을 드러내고 첫눈의 경계를 좁혔다. | 7 |
| FV-07 | 압설판을 낮추고 썰매 궤와 고임목을 Ivo 쪽 화면의 오른쪽으로 약 1스터드 옮겼다. | 9 |
| EC-07 | 현무암 받침 앞에 진입 경사를 넣고 철재 롤웨이를 정지턱까지 이었다. | 11 |
| HG-07 | 야간 석조 보호턱의 갓돌을 끝으로 갈수록 낮췄다. | 10 |

## Studio 재현

[0.113.25 기준 빌드](../epic-finale-scenery-20261119/build.json)와 [0.113.26 빌드](build.json)의 소스 커밋과 SHA-256을 확인한다. 두 빌드는 같은 [카메라 좌표와 테마](cameras.json)를 사용한다. 중간 시점 세 곳은 이전 근경과 목표 측면의 카메라를 보간했다.

```sh
evidence=docs/evidence/epic-finale-refinement-20261119
python3 "$evidence/prepare-studio.py" --baseline --output /tmp/tlt-finale-refinement-baseline.luau
python3 "$evidence/prepare-studio.py" --output /tmp/tlt-finale-refinement-candidate.luau
run-in-roblox --place builds/0.113.25/TheLastThrone-0.113.25.rbxlx --script /tmp/tlt-finale-refinement-baseline.luau >/tmp/tlt-finale-refinement-baseline.log 2>&1
run-in-roblox --place builds/0.113.26/TheLastThrone-0.113.26.rbxlx --script /tmp/tlt-finale-refinement-candidate.luau >/tmp/tlt-finale-refinement-candidate.log 2>&1
python3 "$evidence/summarize-studio.py" /tmp/tlt-finale-refinement-baseline.log /tmp/tlt-finale-refinement-candidate.log
```

## 결과와 인계

- Luau 546개가 컴파일됐다. 다섯 에픽 단독 생성과 전체 생성에서 모델 5개·48부품과 목표·접지 위치가 일치했다. 캐시 재입장에서 중복 생성은 0건이었다. 모델마다 지면을 5곳씩 검사했고 모든 부품의 고정·비충돌·비터치·비쿼리 속성을 확인했다.
- 기존 조사 지물 12개, 접근로 단면 5개, 시설 4개와 FV/HG 충돌 형상이 기준과 일치했다. Original 38,241개와 Easy 39,540개 보행 표본의 차단은 0건이다. 점프를 끈 R15 접근·귀환 23개가 통과했다. [Studio 측정](studio-results.json)
- 동일 카메라 전후 13쌍을 확인했다. Deepwood의 흙 가장자리는 낮아졌으며 앞면 직선은 남아 있다. Gloamwood의 회청색 기단과 눈 경계는 두 야간 시점에서 구분된다. Frozen Vale는 중간 접근의 고임목을 구분할 수 있으나 목표 옆 약 62스터드 시점에서는 등화가 일부를 가린다. Ember Caldera의 진입부는 중간 시점에서 읽히며 목표 측면은 전경 자갈에 일부 가린다. Haunted Graveyard의 단차는 근경과 비스듬한 접근에서 보인다. [고정 카메라 비교판](comparison.jpg)

다음 담당은 환경 아트와 QA다. 실제 조작으로 FV-07 최초 발견 시점을 확인하고, EC-07 빈 운반대 조사와 HG-07 결말 직후 귀환에서 카메라가 어느 쪽을 향하는지 기록한다. 실제 스토리 상호작용, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이, 스트리밍 및 사용자 미술 수용은 미검증이다.
