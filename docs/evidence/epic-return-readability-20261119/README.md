# 다섯 에픽 조사 지물의 접근·귀환 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[장별 제작표와 RPG 사례](../../research/2026-11-19-epic-return-readability.md) · [0.113.21 기준 빌드](../epic-story-approaches-20261119/build.json) · [0.113.22 고정 빌드](build.json)

환경 아트가 기존 Studio 화면과 스토리 장면을 검토했다. 환경 3D가 Deepwood 보급 꾸러미, Gloamwood 지도판·덮개, Ember Caldera 압력계, Haunted Graveyard 배수 점검함을 제작했고, 맵 구현이 Frozen Vale 방풍 끝판을 벌려 굽이 쪽 측면을 확장했다. 월드가 생성할 때 Roblox 기본 입체로 조립한다.

## 재현

각 기록의 SHA-256을 대조한다. PlaceId 0의 Studio에서 동일 카메라로 두 빌드를 촬영하고 후보에서 전체 동선과 지물 배치를 검사한다.

```sh
ev=docs/evidence/epic-return-readability-20261119
base=builds/0.113.21/TheLastThrone-0.113.21.rbxlx
candidate=builds/0.113.22/TheLastThrone-0.113.22.rbxlx
python3 "$ev/prepare-studio.py" --baseline --output /tmp/tlt-return-base.luau
python3 "$ev/prepare-studio.py" --output /tmp/tlt-return-candidate.luau
run-in-roblox --place "$base" --script /tmp/tlt-return-base.luau >/tmp/tlt-return-base.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-return-candidate.luau >/tmp/tlt-return-candidate.log 2>&1
python3 "$ev/compare.py" /tmp/tlt-return-base.log /tmp/tlt-return-candidate.log
```

## 결과와 인계

- Luau 544개를 컴파일했다. 다섯 에픽의 단독 생성, 전체 생성과 캐시, 랜드마크 10개 접지 및 기존 조사 지물 12개 배치를 확인했다. 확장 시설 4개·45부품의 접지, 비충돌, 0~3단계 표시와 조사 좌표 및 피벗을 확인했다.
- 원본 38,241개와 Easy 39,540개 보행 표본에서 차단은 0건이었다. 점프를 끈 R15의 접근·귀환 18건이 통과했다. FV-03 방풍 울타리 및 HG-03 기존 배수구의 충돌 형상과 위치는 기준과 일치했다. [Studio 측정](studio-results.json)
- 동일 카메라 7쌍과 보행 방향 101개 표본을 비교했다. DW 보급 꾸러미가 선반 위에 보이고, GW 야간 지도판과 EC 압력계가 각 근경에서 구분된다. FV 끝판은 근경에서 넓어졌고 약 199스터드 굽이 화면에서는 여전히 왼쪽 가장자리에 작게 보인다. HG 점검함은 계획한 귀환 화면에서 약 4.9도 방향에 가림 없이 보이며 인방과 개구부의 명도 대비가 작다. [Studio 전후 비교](comparison.jpg)

QA와 환경 아트에 DW-Q1 꾸러미 조사부터 보고까지의 실제 입력, FV 굽이의 최초 발견 시점, HG 귀환 카메라의 판독을 인계한다. 전투 카메라, 멀티플레이, 스트리밍, 게시 클라이언트, 실기기와 사용자 미술 수용은 미검증이다.
