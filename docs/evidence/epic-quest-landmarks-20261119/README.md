# 다섯 에픽 대표 퀘스트 현장 검증

2026-11-19 · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

환경 아트는 0.114.0 대표 퀘스트의 행동 위치·기존 지물·지역 조명을 살폈다. 환경 3D는 에픽 환경 키트의 재질과 기본 입체 형상을 사용했고, 맵 구현은 기존 사건과 본선에 모델을 배치했다. [비교 게임 조사와 제작표](../../research/2026-11-19-epic-quest-landmarks.md) · [0.114.1 고정 빌드 기록](build.json)

| 장 | 변경 | 부품 |
| --- | --- | ---: |
| DW-02 | 배수 흙 턱 위에 목재 비가림과 약품 선반을 두었다. | 15 |
| GW-06 | 기존 후위 등불 뒤에 암질 둔덕, 드러난 뿌리와 낮은 밧줄을 배치했다. 본선 모델을 사건 구역과 독립된 스트리밍 단위로 구성했다. | 9 |
| FV-04 | 청회색 암석 단면과 압설층 위에 피난처 표식이 있는 관측 받침을 두었다. | 11 |
| EC-05 | 공동 도면대의 다리 아래에 내화 기단을 붙이고 뒤에 마른 회수 홈을 만들었다. | 12 |
| HG-04 | 기존 회전축 아래에 석재 기단과 철제 베어링, 앵커를 붙였다. | 12 |

## 재현

0.114.0과 0.114.1의 Place 파일은 각각 [기준 빌드](../epic-quest-variety-20261119/build.json)와 [후보 빌드](build.json)의 SHA-256으로 확인한다. 양쪽 모두 구역의 기존 조명을 사용한다. 비교판은 프롬프트와 떠 있는 라벨을 숨긴 기본 사건 상태의 접근 및 측면 시점이다.

```sh
evidence=docs/evidence/epic-quest-landmarks-20261119
capture=docs/evidence/epic-approach-readability-20261118/capture-approaches.luau
cat "$evidence/camera-setup.luau" "$capture" > /tmp/tlt-quest-baseline.luau
cat "$evidence/camera-setup.luau" "$evidence/check-landmarks.luau" "$capture" > /tmp/tlt-quest-candidate.luau
run-in-roblox --place builds/0.114.0/TheLastThrone-0.114.0.rbxlx --script /tmp/tlt-quest-baseline.luau > /tmp/tlt-quest-baseline.log 2>&1
run-in-roblox --place builds/0.114.1/TheLastThrone-0.114.1.rbxlx --script /tmp/tlt-quest-candidate.luau > /tmp/tlt-quest-candidate.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
run-in-roblox --place builds/0.114.1/TheLastThrone-0.114.1.rbxlx --script /tmp/tlt-campaign-expansion-native.luau > /tmp/tlt-quest-regression.log 2>&1
python3 "$evidence/make-comparison.py" /tmp/tlt-quest-baseline.log /tmp/tlt-quest-candidate.log /tmp/tlt-quest-regression.log
```

## 검증 결과

- 전체 다섯 에픽 생성과 캐시 재호출에서 장별 모델 1개, 총 59부품을 확인했다. 모델마다 중앙과 경계 네 귀퉁이의 엔진 바닥 높이가 설치 기준과 일치했다. 고정·비충돌·비터치·비쿼리와 `resolve` 프롬프트 또는 자동 도착 앵커가 유지됐다. [Studio 측정](studio-results.json)
- Lua 퀘스트 회귀 3,492건과 전투 동선 회귀 77,381건이 통과했다.
- Studio 회귀 9,193건을 통과했다. 사건 82곳의 바닥·보행 표본 3,968개에서 차단 0건을 기록했다. 기존 약품 전달, 후위 도착, 신호 선택, 회로와 성문 장면의 검증도 통과했다. Lua 난이도별 진행 회귀는 4,493건을 통과했다.
- 고정 화면 전후 10쌍에서 DW의 Selene와 비가림, FV의 관측 받침과 기존 계기, EC의 도면대와 내화 기단, HG의 Brann과 회전축 받침을 함께 확인했다. GW 등불은 두 시점에서 보이나 접근 정면에서 뿌리 둔덕의 대비는 낮다. EC의 회수 홈도 어두운 접근 시야에서 세부 형태가 약하다. [Studio 전후 비교](comparison.jpg)

다음 담당은 환경 아트와 QA다. 실제 입력에서는 GW 본선 양방향에서 처음 등불을 발견하는 거리, FV 정답 전후의 신호 전환, EC 회로 조작 측면과 HG 동맹 진입 시야를 확인한다. R15 실시간 조작, 전투 카메라, 게시 클라이언트, 기기별 입력, 멀티플레이 스트리밍, 사용자 미술 수용은 미검증이다.
