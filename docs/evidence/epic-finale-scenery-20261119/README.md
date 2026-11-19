# 다섯 에픽 결말 지형과 지물 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

환경 아트가 0.113.24의 접근로 개선과 캠페인 원문을 검토했다. 환경 3D와 맵 구현이 다섯 결말 장에 고정 지형과 지물을 배치했다. 기존 지물 배치기에서 목표·경로·다른 구역의 여유와 접지를 검사한다. [공식 RPG 사례와 장별 제작표](../../research/2026-11-19-epic-finale-scenery.md)

| 스토리 | 구현 | 부품 |
| --- | --- | ---: |
| DW-07 | Black Root Altar 배송 기록 옆 바퀴 자국, 목재 고임목과 낮은 적재 턱 | 9 |
| GW-07 | 북쪽 출구의 비대칭 셰일 단면과 첫눈 | 6 |
| FV-07 | Ice Mirror Palace 재회 지점 옆 압설 썰매 자국과 화물 턱 | 8 |
| EC-07 | Suri 쪽 현무암 선적 받침과 철재 롤웨이 | 9 |
| HG-07 | 왕릉 결말 구역의 낮은 석조 보호턱과 금속 버팀쇠 | 10 |

## Studio 재현

저장소 루트에서 [0.113.24 기준 빌드](../epic-contour-readability-20261119/build.json)와 [0.113.25 고정 빌드](build.json)의 소스 커밋과 SHA-256을 확인한다. 두 비교판은 같은 [카메라 좌표](cameras.json)와 지역별 조명을 사용한다.

```sh
evidence=docs/evidence/epic-finale-scenery-20261119
python3 "$evidence/prepare-studio.py" --baseline --output /tmp/tlt-finale-baseline.luau
python3 "$evidence/prepare-studio.py" --output /tmp/tlt-finale-candidate.luau
run-in-roblox --place builds/0.113.24/TheLastThrone-0.113.24.rbxlx --script /tmp/tlt-finale-baseline.luau >/tmp/tlt-finale-baseline.log 2>&1
run-in-roblox --place builds/0.113.25/TheLastThrone-0.113.25.rbxlx --script /tmp/tlt-finale-candidate.luau >/tmp/tlt-finale-candidate.log 2>&1
python3 "$evidence/summarize-studio.py" /tmp/tlt-finale-baseline.log /tmp/tlt-finale-candidate.log
```

## 결과와 인계

- Luau 546개 컴파일이 통과했다. 다섯 에픽 단독과 전체 생성에서 신규 모델 5개·42부품의 위치와 접지 측정이 일치했다. 캐시 재입장 시 개체 중복은 0건이었다. 모델당 지면 표본 5개를 확인했으며 부품은 고정·비충돌·비터치·비쿼리다.
- 기존 조사 지물 12개, 접근로 단면 5개, 시설 4개와 FV/HG 충돌 형상이 기준과 일치했다. Original 38,241개와 Easy 39,540개 이동 표본의 차단은 0건이었다. 점프를 끈 R15의 목표 접근·귀환 23개가 통과했다. 다섯 결말의 목표까지 남은 거리는 접근과 귀환에서 각각 5스터드 미만이었다. [Studio 측정](studio-results.json)
- 동일 카메라 10쌍에서 Deepwood 고임목과 바퀴 흔적, Gloamwood 암층 위의 눈, Ember Caldera 롤웨이, Haunted Graveyard 보호턱이 보인다. Frozen Vale의 썰매 자국은 근경에서 보이며 Ivo 쪽 62스터드 지점에서는 전경 등화에 일부 가린다. Ember Caldera 목표 쪽 화면에도 기존 전경 소품이 걸린다. 야간 Gloamwood는 눈과 셰일 상단의 차이가 보이지만 기단이 어둡다. [동일 카메라 전후 비교](comparison.jpg)

다음 담당은 환경 아트와 QA다. 실제 조작 중 FV-07의 등화 뒤 화물 턱, EC-07에서 선적 받침과 빈 운반대를 함께 읽을 수 있는지, HG-07 결말 직후 실제 귀환 방향에서 보호턱이 보이는지 확인한다. 이 Studio 시험은 고정 카메라와 R15 이동으로 수행했다. 스토리 상호작용, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이, 스트리밍 및 사용자 미술 수용은 미검증이다.
