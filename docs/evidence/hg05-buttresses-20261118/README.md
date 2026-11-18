# TLT-064 · HG-05 석축 버팀벽 후보

2026-11-18. 맵 구현·환경 아트·환경 모델링·리서치 역할 순차 수행. 입력 소스9708f31f. 본편 반영 보류, G5 미완료.

## 제작표와 원천

HG-05는 Veyr의 서쪽/동쪽 바깥 방어선을 끊는 장이다. 기존 왕릉 접근 추모 묘역 후보에 석축을 지지하는 경사 버팀벽6개를 추가했다. 작은 줄눈 실험을 반복하지 않고 외곽의 큰 윤곽을 검토했다. 기존 WeatheredCoping의 Slate/색을 파생하며 외부 자산·Blender는 사용하지 않았다. 실제 장치·보상·저장·서버 판정 변경 없음.

## 재현

/tmp/tlt-hg05-device-review.rbxlx를 별도 /tmp/tlt-hg05-silhouette-review.rbxlx로 복사. 자체 Studio00fab383-939a-49d4-9d5c-81b95e87f78a/PID84479, PlaceId0/플레이어0. 기존0.113.2 fixture이며 최신0.113.9 빌드 검증이 아니다.

BaseScript 비활성 → 기존 CampaignWorld/Baseplate 제거 → hg05-terraces-20261118 후보 ModuleScript/setup → hg05-access-20261118/access → hg05-asymmetry-20261118/reshape → hg05-memorial-focus-20261118/refocus → buttresses.luau 순서. 위 경로는 docs/evidence 기준. 현재 script는 중복 적용을 거부한다.

후보 버팀벽을 잠시 분리해 기존 hg05-terraces-20261118/navigation.luau를 실행하고 재부착 뒤 동일 검사했다. 양쪽 HG7장105목표4749표본 차단/바닥/보정/안내/작은단차0. results.json은 반환값 요약이다. BasePart80→86/고체33→39, 전부 Anchored. 추가6개 바닥188stud 접지 assertion 통과. Easy 경로·실제R15·장치 조작 검증은 수행하지 않았다.

before/after.png 동일 Edit카메라(510,260,-17365)→(270,203,-17530), near.png (447,216,-17463)→(390,201,-17516). 동일 장면/조명이며 게시 클라이언트가 아니다. 직접 화면을 비교했다. 근접에서 지지 구조는 읽히지만 넓은 반복 직각 단상과 작은 추모물의 규모 문제는 남는다. 이 버팀벽만으로 최고 품질이나 최종 미술 수용을 주장하지 않는다.

## 판정과 인계

본편 반영 보류. 생산 소스/VERSION/빌드/게시/태그 없음. 비교 가능한 후보 소스와3장 이미지만 보존한다. [조사](../../research/2026-11-18-hg05-buttresses.md).

다음 MAP/QA는 최신 빌드 새 장면에서 HG-05 정상 장치 조작·귀환·실제 전투 카메라를 먼저 검증한다. 추가 원시 도형 증량 실험을 반복하지 말고, ART는 승인 원본 기반 묘역 외곽 모듈의 구조/규모를 검토한다. 전체Easy/실제보행/회피/카메라충돌/게시/실기기/다인성능/사용자 미술 수용 미검증. 사용자 Studio와 기존 미커밋 변경은 보존했다.
