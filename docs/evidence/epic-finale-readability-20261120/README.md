# 다섯 에픽 7장 결말 지물 검증

2026-11-20 · TLT-061/DW-07 · TLT-065/GW-07 · TLT-062/FV-07 · TLT-063/EC-07 · TLT-064/HG-07 · G5 진행 중

[공식 RPG 사례와 제작표](../../research/2026-11-20-epic-finale-readability.md) · [0.114.19 고정 빌드](build.json) · [고정 카메라 전후](comparison.jpg) · [Studio 측정](studio-results.json)

## 재현

[0.114.18 기준 Place](../hero-skill-choreography-20261120/build.json)의 SHA-256은 `2cc447a3cd8e41fb1565757f0de9fcf8015c492e64f1dde57d916224c8e18b71`이다. 같은 Studio 감사 스크립트를 각 Place의 소스 커밋에서 생성한다. `--baseline`을 생략하면 두 Place에서 모두 전체 감사가 실행되고, 스크립트는 로컬 소스와 Place 내 모듈 소스의 일치를 확인한다.

```sh
# 각 빌드의 소스 작업 트리에서 실행
python3 docs/evidence/epic-finale-refinement-20261119/prepare-studio.py --output "$review_script"
run-in-roblox --place "$place" --script "$review_script" > "$log" 2>&1

# 두 로그의 동일 검사와 고정 카메라 13개를 비교
python3 docs/evidence/epic-finale-readability-20261120/compare.py "$baseline_log" "$candidate_log"
```

카메라는 같은 좌표와 지역 조명을 사용한다. 두 빌드에서 기본 생성 상태를 촬영하며 프롬프트와 이름표를 숨긴다. R15 보행은 점프를 끄고 접근과 귀환을 측정한다.

## 검사 결과

- Luau 554개가 컴파일됐다. 다섯 결말 지물 48부품이 에픽 단독 생성과 전체 생성에서 일치했다. 접지 25곳의 높이 오차는 최대 0.000004스터드였다. 적재로 폭이 줄어 DW 배치기가 같은 높이의 6.15스터드 떨어진 자리를 선택했다. 다른 네 지물의 피벗과 다섯 조사 앵커는 기준과 일치했다.
- 기준과 후보의 Original 38,205개, Easy 39,504개 동선 표본에서 차단이 없었다. 두 빌드의 R15 접근·귀환 23쌍이 통과했다. 기존 접근 단면 5개, 시설 4개, FV/HG 충돌 형상과 비교 대상 조사 지물의 배치가 일치했다.
- 고정 시점 13쌍에서 DW 적재로의 양쪽 흙 경사와 GW 야간 셰일의 노출면을 확인했다. FV 고임목은 중간 접근에서 명확해졌고 목표 옆 시점에서는 전경 등불에 일부 가린다. EC 정지턱은 목표 쪽에서도 보이며 하부는 여전히 전경 자갈에 일부 가린다. HG는 갓돌의 밝은 모서리와 낮아지는 석축을 비스듬한 접근에서 확인했다.
- Lua 서사 1,060건, 전투 경로 77,381건, 내비게이션 8,791건, 확장 리뷰 3,492건이 통과했다. `story-region-handoff.spec.lua`는 기준과 후보 모두 27행의 같은 단언에서 실패했다.

다음 담당은 QA와 환경 아트다. FV 재회 직후와 EC 재가동 직후 실제 플레이에서 조사 프롬프트, 배우와 지물의 겹침을 확인한다. HG 왕좌 복원 직후의 귀환 시점, 전투 카메라, 게시 클라이언트, 실기기, 멀티플레이 스트리밍과 사용자 미술 수용은 미검증이다.
