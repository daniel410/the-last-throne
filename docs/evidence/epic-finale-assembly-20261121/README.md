# 다섯 에픽 7장 결말 지형과 지물 검증

2026-11-21 UTC · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[환경 아트 사례와 제작표](../../research/2026-11-21-epic-finale-assembly.md) · [0.115.20 및 0.115.21 고정 빌드](build.json) · [동일 시점 전후 비교판](comparison.jpg) · [Studio 측정값](studio-results.json)

| 결말 구간 | 구현한 지형·시설 | 부품 |
| --- | --- | ---: |
| Deepwood | 바퀴홈에 이어지는 석재 받침과 철제 마모판을 목재 고임목 앞에 연결했다. | 11 → 15 |
| Gloamwood | 북쪽 길의 첫눈 아래 셰일 가장자리를 높이와 기울기가 다른 두 층으로 조형했다. | 7 → 9 |
| Frozen Vale | 두 화물 썰매 궤에 각각 철제 받침과 정지판을 맞췄다. | 9 → 13 |
| Ember Caldera | 롤러 여섯 개의 양끝에 어두운 축경을 붙여 현무암 받침과의 연결을 표현했다. | 15 → 27 |
| Haunted Graveyard | 아군 귀환 보호턱에 낮은 끝돌과 철제 버팀 받침 두 개를 추가했다. | 10 → 13 |

## 화면 비교

동일한 고정 카메라 13쌍을 비교했다. Deepwood에서는 바퀴홈 끝의 받침이 근경에서 구분되고, Gloamwood에서는 낮은 셰일층의 선이 추가로 드러난다. Frozen Vale의 정지판은 근경에서 궤와 이어지며 중간 접근에서는 작다. Ember Caldera의 축경은 받침 바로 위에 놓여 전체 장면에서 대비가 낮다. Haunted Graveyard의 낮은 끝돌은 사선에서 보이며 철제 버팀 받침은 야간에 변화가 작다.

## 검증

- Studio에서 Luau 565개를 컴파일했다. 단독 및 전체 생성에서 결말 지물 다섯 개를 확인하고 캐시 재사용 때 중복 생성이 없음을 확인했다. 조사 위치, 접지와 조립체 외곽이 기준과 일치했다. 지물마다 바닥 5점을 검사했고 부품은 고정·비충돌·비터치·비쿼리다. 비교 대상의 기존 랜드마크 10개와 충돌 형상이 일치했다.
- Original 38,184개와 Easy 39,483개 보행 표본에서 기준·후보 모두 차단은 0건이다. 점프를 끈 R15 자동 접근·귀환 각 23쌍을 확인했다. 선적대 롤러 여섯 개와 현무암 받침 두 개의 가로축, 겹침과 간격을 검사했다.
- Lua 에픽 지도 105,907건, 도보 내비게이션 8,791건, 이야기 소품 문맥 4,264건, 전투 경로 77,381건이 통과했다.

두 빌드와 같은 커밋에서 각각 감사 스크립트를 생성한다. 후보 스크립트에서 `--candidate`로 롤러 검사를 추가한다.

```sh
python3 docs/evidence/epic-finale-dispatch-20261120/prepare-studio.py --output "$audit"
run-in-roblox --place "$place" --script "$audit" > "$log" 2>&1
python3 docs/evidence/epic-finale-assembly-20261121/compare.py "$baseline_log" "$candidate_log"
```

다음 담당은 환경 아트와 QA다. 실제 조작으로 Gloamwood 야간의 북쪽 길과 Frozen Vale의 고임목을 처음 보는 위치, Suri 조사 직후 Ember Caldera 측면 시야 및 왕릉 복원 뒤 귀환을 확인한다. 게시 클라이언트·실기기·멀티플레이 스트리밍·전투 카메라·사용자 미술 수용은 미검증이다.
