# 다섯 에픽 퀘스트 지형의 접근 단면 검증

2026-11-19 · TLT-061 / TLT-065(GW) / TLT-062 / TLT-063 / TLT-064 · G5 진행 중

[환경 아트 조사와 제작 가설](../../research/2026-11-19-epic-quest-readability.md)을 바탕으로 기존 다섯 시설의 접지부와 가까이서 보이는 형상을 조정했다. [0.114.1 기준 빌드](../epic-quest-landmarks-20261119/build.json) · [0.114.2 후보 빌드](build.json)

| 장 | 실제 맵 변경 |
| --- | --- |
| DW-02 | 약품 선반 처마에 낙수 끝단을 붙이고 젖은 흙 아래 자갈 턱을 갈라 배수면을 드러냈다. |
| GW-06 | 후위 등불 아래 어두운 뿌리에 양쪽 심재를 드러내고 회청색 셰일로 길과 맞닿는 단면을 구분했다. |
| FV-04 | 관측 받침 아래 비대칭 압설층과 암석 경계를 만들고 상부 표식에 저채도 금속을 사용했다. |
| EC-05 | 공동 도면대 앞쪽에 마른 회수 홈을 내고 입구를 짧고 밝은 내화 타일로 표시했다. |
| HG-04 | 길 쪽 기단에 낮은 모따기 단면을 붙이고 안쪽 윈치에 원통형 베어링을 두었다. |

## 재현

로컬 Studio에서 두 Place 파일을 별도로 열어 같은 카메라와 지역 조명을 적용한다. 배우와 물리 지물을 포함한 기본 사건 상태를 캡처하며 프롬프트와 떠 있는 라벨은 숨긴다. 기존 접근·측면 10개에 GW 역방향, EC 회수 홈 측면, HG 동맹 방향을 추가한다. 신호 정답과 상태 변화는 별도 Studio 회귀에서 확인한다.

```sh
evidence=docs/evidence/epic-quest-readability-20261119
capture=docs/evidence/epic-approach-readability-20261118/capture-approaches.luau
previous=docs/evidence/epic-quest-landmarks-20261119
cat "$evidence/camera-setup.luau" "$capture" > /tmp/tlt-quest-readability-before.luau
cat "$evidence/camera-setup.luau" > /tmp/tlt-quest-readability-after.luau
sed "s/GetAttribute('QuestLandmarkVersion') == 1/GetAttribute('QuestLandmarkVersion') == 2/" "$previous/check-landmarks.luau" >> /tmp/tlt-quest-readability-after.luau
cat "$capture" >> /tmp/tlt-quest-readability-after.luau
run-in-roblox --place builds/0.114.1/TheLastThrone-0.114.1.rbxlx --script /tmp/tlt-quest-readability-before.luau > /tmp/tlt-quest-readability-before.log 2>&1
run-in-roblox --place builds/0.114.2/TheLastThrone-0.114.2.rbxlx --script /tmp/tlt-quest-readability-after.luau > /tmp/tlt-quest-readability-after.log 2>&1
python3 tools/prepare-campaign-expansion-native.py
cp /tmp/tlt-campaign-expansion-native.luau /tmp/tlt-quest-readability-regression.luau
run-in-roblox --place builds/0.114.2/TheLastThrone-0.114.2.rbxlx --script /tmp/tlt-quest-readability-regression.luau > /tmp/tlt-quest-readability-regression.log 2>&1
python3 "$evidence/make-comparison.py" /tmp/tlt-quest-readability-before.log /tmp/tlt-quest-readability-after.log /tmp/tlt-quest-readability-regression.log
```

## 검증 결과

- 다섯 모델을 생성하고 같은 월드를 다시 요청해 캐시 인스턴스가 재사용되는지 확인했다. 모델 이름, 설치 좌표, 퀘스트 앵커 좌표가 0.114.1과 일치했다. 71부품 모두 고정·비충돌·비터치·비쿼리이며 중심과 모서리 바닥 25곳의 높이 차이는 0이었다. [Studio 측정](studio-results.json)
- 비교판 13쌍에서 GW의 등불이 양방향으로 보이고 역방향에서 뿌리 심재가 드러난다. EC 회수 홈은 정면 접근과 기존 측면에서 더 잘 보이며, 반대 측면에서는 도면대가 새 홈을 가린다. DW의 배수단과 HG의 모따기는 측면에서 확인했고 Brann과 윈치는 동맹 방향에서 함께 보인다. FV 측면에서 압설 단차와 보라색 신호 표시가 구분된다. [Studio 전후 비교](comparison.jpg)
- 후보의 소스 일치 및 Luau 컴파일 검사를 포함한 Studio 회귀 9,193건이 통과했다. 사건 82곳의 보행·바닥 표본 3,968개에서 차단 0건이었다. FV 경보의 오답·거리 제한·정답과 수호수 방향 변화, EC의 물리 조작과 단계 저장, HG 동맹과 성문 진행도 통과했다. Lua 퀘스트 3,492건, 난이도별 진행 4,493건, 전투 동선 77,381건이 통과했다.

다음 담당은 QA와 환경 아트다. 실제 R15 입력으로 EC 앞쪽에서 도면 상호작용과 회수 홈이 구분되는지, GW 양방향부터 등불을 언제 발견하는지 확인한다. 전투 카메라, Roblox 게시 클라이언트·실기기, 멀티플레이 스트리밍 및 사용자 미술 수용은 미검증이다.
