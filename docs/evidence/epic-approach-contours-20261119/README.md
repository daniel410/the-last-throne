# 다섯 에픽 조사 접근로 지형 단면 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[지역별 서사와 공식 RPG 사례](../../research/2026-11-19-epic-approach-contours.md) · [0.113.22 기준 빌드](../epic-return-readability-20261119/build.json) · [0.113.23 후보 빌드](build.json)

환경 아트가 지역별 재질과 실루엣을 정의했다. 환경 3D가 Roblox 기본 입체로 단면을 조립했다. 맵 구현이 네 조사 시설의 외곽과 Frozen Vale 방풍 울타리 쪽 굽이에 모델을 배치했다. 비교 범위는 에픽당 스토리 접근로 한 곳이다.

## Studio 재현

PlaceId 0의 Studio에서 두 고정 빌드를 같은 카메라와 지역 조명으로 촬영한다. 저장된 빌드 기록으로 입력 커밋과 SHA-256을 확인한다. 후보는 에픽별 단독 생성, 전체 생성, 캐시와 기존 보행 회귀를 함께 실행한다.

```sh
evidence=docs/evidence/epic-approach-contours-20261119
python3 "$evidence/prepare-studio.py" --output /tmp/tlt-contours-base.luau
python3 "$evidence/prepare-studio.py" --audit --output /tmp/tlt-contours-candidate.luau
run-in-roblox --place builds/0.113.22/TheLastThrone-0.113.22.rbxlx --script /tmp/tlt-contours-base.luau >/tmp/tlt-contours-base.log 2>&1
run-in-roblox --place builds/0.113.23/TheLastThrone-0.113.23.rbxlx --script /tmp/tlt-contours-candidate.luau >/tmp/tlt-contours-candidate.log 2>&1
python3 "$evidence/compare.py" /tmp/tlt-contours-base.log /tmp/tlt-contours-candidate.log
```

## 결과와 인계

- Luau 545개를 컴파일했다. 다섯 에픽의 단독·전체 생성과 캐시를 확인했다. 새 모델 5개·30부품의 고정, 비충돌·비터치·비쿼리 속성과 모델별 지면 표본 3개를 검증했다. 기존 조사 지물 12개의 접지·접근 좌표, 확장 시설 4개의 조사 좌표와 피벗, FV/HG 기존 충돌 형상이 기준과 일치했다. [Studio 측정](studio-results.json)
- Original 38,241개와 Easy 39,540개 보행 표본에서 차단은 0건이었다. 점프를 끈 R15의 접근과 귀환 18건이 통과했다.
- 같은 카메라 6쌍에서 DW의 마른 둔턱, GW 쉼터 아래의 뿌리, EC 압력계 뒤의 절개면이 보인다. FV 암빙은 근경에서 눈 바닥과 구분되지만 먼 굽이에서는 기존 표지판과 겹치고 방풍 울타리는 여전히 화면 왼쪽에 작게 남는다. HG 석조는 어두운 바닥과 대비가 낮으며 이 구도에서 점검함 개구부는 보인다. [Studio 전후 비교](comparison.jpg)

다음 담당은 QA와 환경 아트다. DW-Q1 회수 및 보고 실제 입력, FV 굽이에서의 최초 발견, GW·HG의 야간 모바일 판독을 확인한다. 전투 카메라, 스트리밍, 멀티플레이, 게시 클라이언트·실기기 및 사용자 미술 수용은 미검증이다.
