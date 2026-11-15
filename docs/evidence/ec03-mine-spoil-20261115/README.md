# TLT-063 · EC-03 채굴 현무암 잔석

광산 지지대 복구·Magma Worm 저지·Orik/광부 구조를 담은 대표 소품 개선이다. [리서치·서사 제작표·TD 원천](../../research/2026-11-15-ec03-mine-spoil.md). TLT-063/G5 전체는 미완료다.

## 변경과 범위

CalderaMineSpoil1 / EpicWorldArt27. EC-03 비전투 여백에 대/중/소의 차가운 현무암3개씩, **3군집·9메시**를 구성한다. 기존 외곽 배치 루프의 난수 소비는 보존한다. baseline의 실제 LayeredVegetation은 보행 영역 검사에 모든 후보가 제외되어0파트였으므로 최종 비용은9파트 증가다. 전체 성능/메모리 향상을 주장하지 않는다.

TD VolcanoCliff의 단일 body_geom 메시를 균일 크기22/13/8과 회전으로 파생하고, TextureID를 TDOriginalTexture에 보존한 뒤 파생에만 Basalt/비발광 지역 색을 적용한다. 원본 메시/텍스처 파일·TD 운영·실제 Terrain·서버 Bounds/바닥·스토리/보상/저장은 변경하지 않는다. Blender 사용 없음. 구역/확장/연결·스폰/목표/전투 예약 및 기존/Easy 실제 안내 경로를 함께 피한다. 군집과 각 바위에 월드 수직 피벗을 부여해 최종 접지를 검사한다.

작업 전 편집 범위: 신규 CalderaMineSpoil·EpicWorldArt 통합·VERSION, 전용 엔진 검사·리서치·증거·현재상태 링크. 별도 작업트리/인덱스로 사용자 미커밋 자산을 보존했다.

## 고정 빌드와 재현

최종 **0.110.28 / bc2ba150600a22c248924c01608a0ff88f153b01**. [build-final.json](build-final.json)에 산출물 SHA256·명령·소스 커밋이 있다. `python3 tools/build-game.py --source bc2ba150600a22c248924c01608a0ff88f153b01 --record <새 기록 경로>`로 별도 위치에서 재현한다. 기존 버전 산출물을 다른 소스로 덮어쓰지 않는다.

격리된 로컬 PlaceId0/플레이어0 Studio Edit에서 [create.luau](create.luau)를 실행한다. 두 변경 모듈의 고정 Source 일치 및 Shared/Server/Client 전체 구문을 검사하고 CampaignWorld.create(4)로 모든 마감을 포함한 장면을 만든다. `_G.MineStatus.ok` 뒤 [verify.luau](verify.luau)를 실행한다. 소스 주입은 사용하지 않았다. 최종 회수식은 `return game.HttpService:JSONEncode({status=_G.MineVerifyStatus,report=_G.MineReport,navigation=_G.MineNav})`이며 [results.json](results.json)에 저장했다. [inputs.json](inputs.json)은 검사 원고/모듈 해시다.

실패 기록도 보존했다. 0.110.25/6585afb8은2군집으로 최소3기준 미달 → 기준 완화 없이 탐색 확대. 0.110.26/91df24d4는4군집이지만 회전된 군집 경계 때문에 재배치 후5.13~6.16stud 부유 → 월드 수직 경계 수정. 0.110.27/3e39fc0f는 큰 부유를 제거했으나 군집 통째 재배치 후 국소 높이차로0.72~0.75stud 틈 → 두 실제 안내 경로/교전 예약을 배치 전에 추가. 최종3군집 모두 재배치 없이 안전 위치에 정착했다. 각 failed JSON과 build.json/build-26.json/build-27.json 참조.

## 검증 결과

- 최종 실제 장면 **99검사 통과**:3군집·3크기·9원본 메시 식별, 차가운 재질/원본 텍스처 기록, 정적/고체충돌/쿼리/터치비활성, 최종 지면 접촉, 구역 내부·확장 사건/지역 연결 비침범. 파트 수 상한12.
- Ember Caldera **11장·9연결**: 기존144목표8,396표본 / Easy150목표8,526표본에서 차단·바닥·서버보정·안내 실패·단차 모두0. 실제 최종 지면과 고체 충돌을 검사한 엔진 감사이며 Humanoid 보행이나 전투 조작 시험은 아니다.
- 동일 주간 Edit 전후: [조감 이전](before.jpg) / [조감 최종](after.jpg), [근접 이전](before-near.jpg) / [근접 최종](after-near.jpg). 좌표/FOV/소스/모드는 [captures.json](captures.json). 각 고정 빌드의 fresh 장면에 Camera.Focus/CFrame을 함께 지정하고 로딩 뒤 좌표 없는 screen_capture로 촬영했다. 이전0.110.24와 최종0.110.28 사이 다른 커밋의 뉴스/Deepwood 보스 표시 변경은 이 EC 장면의 효과로 계산하지 않는다. 사진의 전체 평지·원경 공백은 남아 있다.

## 미검증·다음 담당

이번 산출물은 소규모 대표 소품 개선이다. 넓은 중앙 평지·구역 사이 하늘 공백·대규모 지형 구성은 해결하지 않았다. 실제 지역 조명/전투 카메라·회피·Orik 호위, 게시 클라이언트/원본 자산 로딩 권한·스트리밍·실기기·1~4인+AI 성능과 사용자 미술 수용은 미검증이다. 다음 DES/QA는 실제 전투/구조 화면의 가독성과 충돌을 확인하고, 맵 담당은 작은 군집 반복 증량보다 큰 공간과 연결부의 단절을 별도 범위로 설계한다. Roblox 게시/릴리스 태그 없음.
