# TLT-065 / GW-01 수색 능선

2026-11-15 · 맵 구현/환경 아트/환경3D/리서치 순차 수행 · G5 미완료.

## 제작표

| epic/story | 원천·사건 | 표현·위치 | 전후·목적 | 검증 |
| --- | --- | --- | --- | --- |
| 2 / GW-01 | CampaignContent GW-01, campaign-context-review-2026-11-10의 북쪽 화물/거미줄 정찰대 갈림길 | 기존 반복 절벽 대신 예약 공간 밖 석질 능선3, 내부 초피 둔덕4 | 영구 자연지형이며 개인 진행 상태 없음. 중앙 수색/전투 공간을 비우고 외곽 고도 변화 부여 | Studio 지형 표면·전체 footprint와 Gloamwood 두 동선 표본 감사, 같은 Edit 카메라 비교 |

## 변경·원본

GloamwoodSearchLandforms1 / EpicWorldArt24. 기존 FV-03 Native Terrain 제작 방식을 파생해 Slate 기초·Rock 경사·Grass 덮개를 생성한다. 7형상/21회 Terrain 쓰기, 추가 BasePart0. 실제 최대 높이17.49~73.72stud. 기존 수목/34조사 흔적 코드는 변경하지 않았다. 기존 GW-01 일반 절벽 루프만 대체하며 다른 지역·보상·저장·전투 계약은 변경하지 않았다. 경계 반경과 voxel 여유8stud, 확장 사건·지역 간 연결로 예약을 유지한다. 새 메시·텍스처·Blender/TD 원본 변경 없음.

[조사와 적용 한계](../../research/2026-11-15-gloamwood-search-ridges.md).

## 고정 빌드·검증

0.110.6 / e16b6012826862bc94a505268f59f2d6b87f7ed6. [빌드 기록](build.json). 명령: `python3 tools/build-game.py --source HEAD --record docs/evidence/gw01-search-ridges-20261115/build.json`. 실제 산출물은 기록의 SHA256으로 식별한다.

격리 `/tmp/tlt-gw01-ridges-qa.rbxlx`, PlaceId0/플레이어0, Studio Edit. BaseScript를 끄고 Baseplate 제거 후 Shared/Server ModuleScript를 loadstring으로 구문 검사하고, tests/gloamwood-search-landforms-native.luau로 실제 CampaignWorld.create(2)를 생성했다. 후보 소스 주입 없음. [지형 검사](terrain.json) 3,581건 통과: 실제 고도/노출 재질/주변 지역·확장공간·연결로 반경/추가파트0.

기존 tests/epic-map-navigation-native.luau를 생성된 동일 world로 연결하고 epic=2만 순회했다. [결과](navigation.json): 기존 points 105목표5,196표본, Easy worldPoints 117목표5,491표본. 두 조건 모두 차단·바닥·보정·안내·단차0. 실제 Humanoid 보행이나 전체 에픽·전투 회귀가 아니다.

[이전](before.jpg) / [변경](after.jpg): 카메라(-1460,240,-3760)→(-1000,65,-4070), Edit 기본 조명. after는 검사 직후 고정 빌드. before는 동일 world에서 Terrain을 지우고 f086aa5b의 Art를 별도 임시 모듈로 재생성한 비교다. 촬영 후 Art24 재생성으로 복원했다. 실제 지역 조명/플레이 카메라가 아니며 재생성 과정의 소품 재배치와 바닥 표시 차이를 지형 효과로 단정하지 않는다.

## 미검증·다음 담당

평지·직선 외곽·바닥 재질 대비는 여전히 남는다. 이번 대표 지형의 생성/동선 검사만 통과했으며 최고 품질·G5 전체·릴리스 수용을 선언하지 않는다. 실제 게시 클라이언트·실기기/입력·스트리밍·다인 성능·사용자 미술 수용 미검증. 다음 DES/QA는 실제 게임 카메라의 능선/단서 가독성과 회피 공간을 확인하고, 맵 담당은 큰 평지와 경계의 대표 구간을 검토한다. 이번 수목/흔적/능선을 반복 증량하지 않는다. Roblox 게시·릴리스 태그 없음.
