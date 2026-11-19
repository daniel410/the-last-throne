# 다섯 에픽 보급·피난·정비 시설 검증

2026-11-19 UTC · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[스토리별 제작표와 공식 RPG 사례](../../research/2026-11-19-epic-story-approaches.md) · [0.113.20 기준 빌드](../epic-landmark-material-contrast-20261119/build.json) · [0.113.21 고정 빌드](build.json)

Deepwood의 보급 선반, Gloamwood의 지도 쉼터, Ember Caldera의 시험 회로 배관, Haunted Graveyard의 점검함을 실제 조사 장면에 배치했다. Frozen Vale에서는 방풍 울타리 끝판을 추가하고 동쪽 도관 단자함을 높였다. 모델은 월드가 생성할 때 조립되는 Roblox 기본 입체다.

## Studio에서 재현

PlaceId 0에서 두 고정 빌드의 SHA-256을 확인한다. 기준에서 조사 위치와 카메라를 기록하고 후보에서 전체 동선 회귀 검사와 동일 화면을 생성한다.

```sh
ev=docs/evidence/epic-story-approaches-20261119
base=builds/0.113.20/TheLastThrone-0.113.20.rbxlx
candidate=builds/0.113.21/TheLastThrone-0.113.21.rbxlx
python3 "$ev/prepare-studio.py" --baseline --output /tmp/tlt-story-shapes-base.luau
python3 "$ev/prepare-studio.py" --output /tmp/tlt-story-shapes-candidate.luau
run-in-roblox --place "$base" --script /tmp/tlt-story-shapes-base.luau >/tmp/tlt-story-shapes-base.log 2>&1
run-in-roblox --place "$candidate" --script /tmp/tlt-story-shapes-candidate.luau >/tmp/tlt-story-shapes-candidate.log 2>&1
python3 "$ev/compare.py" /tmp/tlt-story-shapes-base.log /tmp/tlt-story-shapes-candidate.log
```

## 결과와 인계

- Luau 544개를 컴파일했다. 다섯 에픽 단독 생성, 전체 생성과 캐시, 기존 랜드마크 10개 접지, 조사 지물 12개 위치, 신규 시설 4개·34부품 접지와 비충돌 속성을 검사했다. 네 확장 장면의 조사 좌표와 0~3단계 표시 조건을 확인했다.
- 원본 38,241개와 Easy 39,540개 가이드 표본에서 차단 0건을 재현했다. 점프를 끈 R15로 18개 접근·귀환 사례를 수행했다. FV-03 울타리와 HG-03 원래 배수구의 충돌 크기와 변환은 기준과 일치했다. [Studio 측정](studio-results.json)
- 카메라 6쌍과 기존 가이드 시야 101점을 비교했다. FV-04의 상승한 도관 단자함은 눈 위에서 구분된다. FV-03 정면 비교의 변화는 끝단에 집중된다. HG-03 새 점검함은 Fortress Side Landing의 두 번째 조사 위치에서 첫 지점을 향할 때 카메라 중심에서 약 4.9도에 있고 시야선에 차단물이 없었다. 같은 화면에서 점검함은 작고 어둡다. GW-03 쉼터는 야간에 덮개와 기둥의 실루엣이 드러나며 목재 세부는 어둡다. [Studio 전후 비교](comparison.jpg)

환경 아트와 맵 구현의 후속 검토는 FV 굽이의 최초 발견과 HG 귀환 중 판독에 집중한다. QA의 실제 입력 기반 DW-Q1 회수·보고, 전투 카메라, 멀티플레이, 스트리밍, 게시 클라이언트, 실기기와 사용자 미술 수용은 미검증이다.
