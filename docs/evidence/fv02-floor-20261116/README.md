# TLT-062 · FV-02 실내 목재 마루

빌드0.111.9 / 입력 a0b89bca8e5259ad5f56bf8a87e6d8a5ff6ef0fb. 미게시·태그 없음·G5 미완료. [제작표/공식 조사](../../research/2026-11-16-fv02-floor.md).

장옥 내부에 시각 마루8장을 추가해 눈밭과 피난 공간을 구분했다. 원본 표/난로/지형/권위 이동 바닥/퀘스트/보상/TD 보존. 전부 anchored·비충돌/비쿼리/비접촉, 새 광원/입자/루프 없음. 별도 작업 트리에서 사용자 변경을 보존했다.

## 검증

build.json 고정 빌드의 BaseScript만 Disabled로 바꾼 UTF-8 XML fixture를 별도 Studio Edit에서 열었다. Python XML 비교로 RegionalArchitecture.Source 원문 일치. CampaignWorld.create(3), 전체528구문·실제8장/scale1.3·충돌 플래그 통과. 8장 중심 RespectCanCollide 하향 레이 모두 Terrain 받침, 상단과 물리 표면 차이0.1039714stud: 발이 시각 상단보다 약.104stud 낮은 오차가 있다.

results.json: tests/epic-map-navigation-native.luau의 world를 _G.FloorWorld로, epic 반복을3만으로 제한했다. 기존 points11장/9연결/142목표6177표본, combatRoutes.points를worldPoints로 바꾼 Easy143목표6218표본 모두 차단/바닥/보정/안내/단차0. 동일 세계에서 순차 실행. 실제 Humanoid 조작·전투 검증은 아니다.

## 비교

Clock14/FOV70, camera(-266.895,93,-8247.812)→(-258.82,86,-8241.914). underlying은 최종 장면에서 새8장만 숨긴 대조로 이전 빌드가 아니다. 다른 자산/조명/진행 상태 동일. JPG2개 LFS. 초기 카메라 구도2개/Vector3.Unpack 호출 오류는 최종 증거에서 제외. 최초 분리 프로세스 종료 후 쉘 세션으로 재실행. 증거 작성 XML 태그명 오류를 수정해 Source 비교 성공.

![눈바닥 대조](underlying.jpg)
![목재 마루](after.jpg)

## 미검증·다음 담당

DES/QA: 실제 영웅 접근·회피/전투·orbit/출입구 카메라·실기기/패드/스트리밍·다인 성능·사용자 미술 수용. 가는 마루 이음새 눈선과 기존 거대한 석재벽/단순 노란 발광·카메라 가림은 남는다. 최고 품질 또는 전체 티켓 완료로 판정하지 않는다. 다음은 같은 피난처 장식 증량보다 실제 카메라 수용 또는 다른 에픽의 큰 지형/랜드마크 개선을 우선한다.
