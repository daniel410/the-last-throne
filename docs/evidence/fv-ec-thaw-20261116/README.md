# TLT-062/063 · 왕궁에서 화물 도시로 이어지는 해빙 표면

2026-11-16 UTC. 제작 스킬 맵 구현·환경 아트·환경3D·리서치 순차 수행. 최종 빌드 **0.110.33**, 입력 **61e227b0318bedd1382f1ea76351e30955fe502d**, `build-final.json`. 게시/태그 없음. G5 미완료.

FV-07 거울 복구·마을 재회 뒤 EC-01 화물 승강기 복구로 향하는357stud 길에 밝은 설원색에서 어두운 화산색으로 변하는 Rock 표면24개를 추가했다. 기존 TD 팔레트 재사용, New Roblox Part 표면만 제작. 외부 메시/텍스처/Blender 없음. 원본·권리·서버 바닥/Bounds·퀘스트/보상/저장 불변. 길 폭96stud, 기존 바닥 위 시각표면 높이0.07stud, 충돌/query/touch/shadow false. 실제 성능 측정 없음. SurfaceFinish6 이후 적용하며 반복 호출 시 이전 표면 폴더를 교체한다.

## 시안과 검증

0.110.32/6701d63b의 Snow/Rock/Basalt 3열72표면은 낮은 시점에서 격자 이음새가 커 기각했다(`rejected.png`, `build.json`, candidate 결과). 최종은 단일 Rock 재질·전체폭24표면으로 수정했다. 눈과 현무암은 최종 실제 재질이 아니라 양끝 팔레트의 색 변화다.

fresh Edit PlaceId0/no players에서 BaseScript 비활성·Baseplate 제거 후 `create-final.luau`: 변경 두 모듈 Source 일치와 전체 LuaSourceContainer loadstring 검사, CampaignWorld 생성 성공. `check.luau` 2093표본 누락/높이/Blockcast0. `routes.luau` 기존496목표24518표본, `easy-routes.luau` Easy529목표25427표본에서 차단/바닥/보정/안내/단차0. 각각 final.json에 원본 도구 응답 보존. 이 검사는 실제 입력 플레이가 아니다.

M.apply 두 번 후 폴더1/표면24, Rock·충돌/query/touch false 확인. 최초 Size.Y==.06 정확비교 검사는 엔진 부동소수점으로 실패했으며 .001 오차 검사로 통과했다. 제품 결함 수정은 아니다.

카메라: a=(-952.85,124,-11012.40), b=(-952.85,124,-11369.40), at=Lerp(a,b,.62), CFrame.lookAt(at+(18,9,20),b+(0,4,0)), Focus=b, FOV70, ClockTime14. 실제 플레이 카메라가 아닌 낮은 Edit 시점이다. `after.png` 최종 .33; `underlying.png`는 동일 .33 장면에서 ThawSurface만 숨긴 기존 바닥 대조이며 이전 버전 빌드 캡처가 아니다. 캡처 후 M.apply로 복구했다.

![기존 바닥 대조](underlying.png)
![최종 표면](after.png)

미검증: 실제 Humanoid 보행/입력/전투/회피/카메라 충돌·게시·스트리밍·PC/터치/패드·다인 성능·사용자 미술수용. 길 양끝 표면 접합/멀리서 색 띠·거대한 평지/빈 하늘은 후속 개선 대상이다. 작은 재질 개선을 전체 맵 최고품질 완료로 판단하지 않는다.

다음 DES/QA: 실제 플레이 시점에서 연결 길의 횡단·양끝 접합과 도시 진입 가독성을 수용하고 큰 공간/랜드마크 구성을 검토한다. 같은 표면/능선 추가 반복보다 이 수용을 우선한다.
