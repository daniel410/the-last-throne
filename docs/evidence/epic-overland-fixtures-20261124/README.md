# 다섯 에픽 도보 경계의 도로 시설 검증

2026-11-24 Toronto · TLT-061/062/063/064/065/overland · G5 진행 중

[공식 RPG 레퍼런스와 제작표](../../research/2026-11-24-epic-transition-environment.md) · [0.115.83 기준 빌드](../hero-impact-silhouettes-20261124/build.json) · [0.115.84 후보 빌드](build.json)

## 변경 범위

네 연결로에 Deepwood 화물길 목재 배수로, Gloamwood Windgap 측량 말뚝, Frozen Vale 해빙 수로 입구, Ember Caldera 화물 규격대, Haunted Graveyard 관리로 표석을 배치했다. 기존 길어깨 재질을 기단과 퇴적부에 적용했다. 칼데라 출구와 묘지 진입 시설은 한 연결로의 서로 다른 쪽에 놓았다.

## Studio 결과

[동일 카메라 접근·귀환 10쌍](comparison.jpg) · [배치·보행 측정](studio-results.json)

- 기존 도로 4개의 바닥 변환·크기와 길어깨 72부품의 배치가 기준과 일치했다. 연결로 생성 재호출 후에도 도로는 4개였다.
- 새 조립체 5종에 Roblox 기본 부품 49개를 사용했다. 모든 부품은 고정 상태이고 충돌, 터치, 쿼리를 사용하지 않는다. 도로 중앙에서 최소 26.00스터드 떨어져 있으며 기단 최저점은 상판에 0.11~0.33스터드 들어간다.
- 각 빌드에서 R15 정방향·역방향 8건이 모두 도착했다. 점프와 서버 위치 보정은 0회였다.
- 별도 통행 서비스 테스트는 두 빌드에서 각각 112건을 통과했다. 저장 응답 유실 후 재시도, 지역 로드 실패 시 위치 유지, 선행 완료 전 차단과 완료 후 해제를 포함한다. 현재의 비동기 지역 준비와 바위 템플릿을 반영하도록 테스트 설정을 갱신해 재실행했다.
- Gloamwood의 압설과 말뚝, Frozen Vale의 밝은 인방과 수로 입구, Ember Caldera의 규격틀이 두 시점에서 보인다. Deepwood에서는 큰 나무 그늘 때문에 배수 홈이 목재보다 흐리다. 묘지의 밝은 표석은 야간에도 보이며, 어두운 줄눈 때문에 먼 곳에서는 석함처럼 읽힐 여지가 있다.

## 남은 수용

환경 아트와 QA가 실제 입력 카메라에서 Deepwood 배수 홈의 판독 거리, Gloamwood 야간 눈금, 묘지 표석의 용도 인지를 확인한다. 게시 클라이언트, 터치 실기기, 파티 스트리밍, 전투 카메라 및 사용자 미술 수용은 미검증이다.

## 재현

두 Place의 SHA-256과 내장 모듈 소스를 각 빌드의 입력 커밋에 대조했다. 전후 카메라 좌표와 지역 조명을 맞췄고 화면에서 프롬프트와 이름표를 숨겼다. 보행은 R15의 점프를 끄고 각 경계 양편 구역의 중심을 왕복하며 내비게이션과 서버 통행 검사를 실행한다.

```sh
evidence=docs/evidence/epic-overland-fixtures-20261124
work=$(mktemp -d)
python3 "$evidence/prepare-studio.py" --output "$work/audit.luau"
for version in 0.115.83 0.115.84; do
    place="$PWD/builds/$version/TheLastThrone-$version.rbxlx"
    run-in-roblox --place "$place" --script "$work/audit.luau" > "$work/$version.log" 2>&1
    run-in-roblox --place "$place" --script tests/epic-overland-service-native.luau
done
python3 "$evidence/compare.py" "$work/0.115.83.log" "$work/0.115.84.log" --version 0.115.84
```

별도 정적 회귀에서 에픽 지도 105,907건, 캠페인 내비게이션 8,791건, 이야기 소품 4,264건, 전투 동선 77,381건을 통과했다.
