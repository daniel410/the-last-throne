# TLT-064 · HG-05 석재 줄눈 후보 미채택

2026-11-18. 맵 구현·환경 아트·환경 모델링·리서치 역할 순차 수행.

## 변경과 원천

HG-05 왕릉 접근 묘역의 건축 재료 표현 실험. 기존 EpicEnvironmentKit HauntedGraveyard 팔레트 및 WeatheredCoping 파생. 외부 자산·Blender 없음. 기존 덮개9개를40개로 분할하고0.08stud 줄눈·작은 색차를 추가했다. 외곽·높이·경사로·추모물·실제 장치는 유지한다. 원래3단 직각 실루엣 자체는 바뀌지 않는다.

## 재현과 측정

입력1692f11a. 기존 /tmp/tlt-hg05-device-review.rbxlx 사본을 자체 /tmp/tlt-hg05-stonework-review.rbxlx로 열었다. 구버전0.113.2 fixture이므로 최신0.113.9 검증이 아니다. 자체 Studio13540d81-f448-4f8b-a95a-0b1ef442660f/PID82538, PlaceId0, 플레이어0. 사용자 Studio는 변경하지 않았다.

BaseScript 비활성화 → hg05-terraces-20261118 후보 ModuleScript 설치/setup → hg05-access-20261118/access → hg05-asymmetry-20261118/reshape → hg05-memorial-focus-20261118/refocus → 이번 stonework.luau 순서. 앞선 증거의 상대 경로는 docs/evidence 기준이다.

스크립트 내9개 덮개 확인 및 폭합계+줄눈 오차<0.001 assertion 통과. Studio 반환 removed9/slabs40/courses9/maxJoint0.08. 최종 BasePart111/고체64/석재40, 전부 Anchored. 이전80/고체33 대비 각각31증가. 줄눈은 얇은 덮개 틈이며 아래 석축이 유지되나 실제 보행 검증은 수행하지 않았다.

before.png/after.png는 동일 Edit 카메라(520,370,-17270)→(270,205,-17520), 동일 장면·조명. 실제 플레이 카메라/게시 클라이언트가 아니다. 비교 화면을 직접 확인했으며 줄눈 변화가 거의 읽히지 않는다. 비용 증가 대비 효과가 부족하므로 본편 미채택. 전체 통행 sweep·R15·정상 장치 조작·전투/회피·게시·실기기·다인·성능·사용자 수용은 이번 실행에서 미검증이다. 과거 통과를 이번 결과로 전용하지 않는다.

## 판정과 다음 담당

[공식3게임 조사](../../research/2026-11-18-hg05-stonework.md). 원고·진행·보상·서버 로직 변경 없음. 생산 소스/VERSION/빌드/게시/태그 변경 없음. G5 및 TLT-064 완료 아님. 이 파일들은 재현 가능한 기각 실험 증거다.

다음 MAP/ART: 작은 줄눈 증량을 반복하지 말고 실제 HG-05 장치 조작·귀환·전투 카메라를 확인한 뒤, 플레이 거리에서 읽히는 묘역 외곽/석축 실루엣 변형을 시도한다. QA는 최신 고정 빌드의 새 장면에서 검증한다.
