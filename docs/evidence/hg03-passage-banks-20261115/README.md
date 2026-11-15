# TLT-064 · HG-03 관리 통로 지형

Lumi가 성문 윈치로 안내하는 관리 통로 주변의 대표 지형 개선이다. TLT-064/G5 전체는 미완료다. [리서치·서사/제작표](../../research/2026-11-15-hg03-passage-banks.md).

## 변경과 범위

HauntedPassageLandforms1 / EpicWorldArt26. HG-03에서만 반복 외곽 바위 루프를 안전 예약에 맞는 Native Terrain 언덕2개로 대체하고, 내부의 비전투 여백에 풍화 둔덕3개를 추가한다. Slate 바탕과 기존 HG 지면의 Rock 표피를 사용한다. 실제 최종 높이는 외곽53.10/62.97stud, 내부16.76~17.25stud다. 입력 height12는 지형 볼의 기준 높이이며 덮개와 voxel 보간 후 실측 높이와 다르다.

최종5형상/10회 FillBall, 추가 BasePart0. 이 수치는 생성 비용이고 전체 맵 성능/메모리 측정이 아니다. 원본 TD 메시·텍스처와 전역 Terrain 색은 변경하지 않았다. Blender 사용 없음. 서버 권위 바닥/Bounds·스토리/보상/진행/개방·저장과 타 지역 생성 코드를 보존한다. 스폰/목표/전투/관리 동선 예약을 통과한 내부 후보만 채택하며 전체 반경+8stud로 이웃 구역·확장 공간·연결을 피한다. 지형은 모든 구역 생성→기존 carve→소품 접지→경로/충돌 마감 순서를 거친다. 새 지형에 따라 일부 접지 소품과 묘역 위치가 안전 후보로 이동한다.

작업 전 소유 범위: EpicWorldArt/HauntedPassageLandforms, VERSION, 신규 엔진 검증과 이 리서치·증거 및 현재상태 링크. 별도 작업트리/인덱스로 기존 사용자 수정·삭제·미추적 자산을 보존했다.

## 고정 빌드와 재현

- 최종 **0.110.24 / b5412366fcc7211456e74b2245b8c71431ab05da**. [build-final.json](build-final.json)의 산출물 경로/SHA256으로 식별한다. `python3 tools/build-game.py --source HEAD --record docs/evidence/hg03-passage-banks-20261115/build-final.json`.
- 최초0.110.22/55e146e2는 표피 볼이 석질 내부에 묻혀 재질 검사 실패. [failed-22.json](failed-22.json)/build.json 보존.
- 0.110.23/8264688a는377지형 검사/두 동선 통과. 화면에서 갈색 Ground가 회녹 지형과 어긋나 기존 Rock으로 교체했다. [superseded-23.json](superseded-23.json)/build-23.json. 최종은 별도 fresh Studio에서 다시 검사했다.

격리 로컬 PlaceId0/플레이어0, Studio Edit에서 [verify.luau](verify.luau)를 실행한다. 소스 주입 없이 고정 빌드의 두 변경 모듈 Source 일치·Shared/Server/Client 구문 검사를 먼저 수행한다. CampaignWorld.create(5)로 완전히 마감된 장면을 만든 뒤 묘역/두 동선과 tests/haunted-passage-landforms-native.luau의 실제 지형 검사를 수행한다. `return game.HttpService:JSONEncode({status=_G.PlotStatus,landforms=_G.HGBankReport,plots=_G.PlotReport,navigation=_G.PlotNav})`로 [results.json](results.json)을 회수했다.

## 최종 검증 결과

- 실제 지형377검사 통과: 언덕2/둔덕3, 전체 여유 반경이 이웃 구역/확장 공간·연결과 비중첩, 연속 지면/잔존 높이·Rock/Slate 재질·추가 Part/Script0.
- 4묘역·12무덤·관련112파트 유지. 낮은 벽12개 충돌/쿼리 활성·터치 비활성/높이5이하. 묘역의 평탄 후보/안전 예약은 기존 구현을 따른다.
- HG7장·연결6곳: 기존105목표4,749표본, Easy119목표5,192표본에서 차단/바닥/서버보정/안내 실패/단차 모두0. 지형 변경 후 최종 실제 지면을 raycast한 정적 엔진 감사이며 Humanoid 이동/전투 검증은 아니다.
- 동일 주간 Edit 조감 [이전](before.jpg)/[최종](after.jpg): 카메라(500,300,-16470)→(280,180,-16310), FOV70. 근접 [이전](before-near.jpg)/[최종](after-near.jpg): (180,230,-16430)→(83,183,-16501). 기준은0.110.21/fe812ecc, 최종은0.110.24/b5412366의 별도 장면. Camera.Focus와 CFrame을 함께 지정하고 로딩 뒤 임시 좌표 없이 촬영했다. 기본 Edit 조명이며 HG 밤/실제 전투 카메라가 아니다.

## 미검증과 다음 담당

맵 중앙의 넓은 평지와 일부 직선 경계는 그대로 남는다. 최고 품질 또는 G5 완료로 보고하지 않는다. 실제 Humanoid 접근/회피·마우스 카메라·밤 조명 가독성·게시 클라이언트/실기기·스트리밍·1~4인+AI 성능·사용자 미술 수용은 미검증이다. 다음 DES/QA는 실제 게임 화면의 지형/목표 가독성과 카메라·회피를 확인하고, 맵 담당은 대표 둔덕을 반복 증량하기보다 큰 공간 구성의 다음 구간을 선택한다. 게시/태그 없음.
