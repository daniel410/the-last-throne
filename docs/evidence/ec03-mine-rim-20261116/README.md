# TLT-063 · EC-03 구조 광산 능선 후보

## 변경·빌드

담당 파일은 CalderaMineLandforms/EpicWorldArt, VERSION, 이번 리서치·검증·현재상태 링크다. 별도 작업트리로 사용자 미커밋 자산을 보존했다. [서사 제작표·공식 비교](../../research/2026-11-16-ec03-mine-rim.md).

최종 0.111.11 / 3bd400ac4aaec1cacdb004a6cca8682a59488f04. [빌드 입력·SHA256](build-final.json). 최초0.111.10은 고정 위치 후보가1곳만 남아 `representative exterior relief` 검사 실패. 안전 조건은 유지하고160~320stud 외곽 탐색으로 수정했다. [최초 빌드](build.json).

일반 외곽 암석 루프를 EC-03에 한해 동쪽 현무암 능선2곳으로 대체. 전체 footprint96stud(각 볼 및 voxel 여유 포함)을 구역/확장/연결에서 제외한다. 신규 Terrain 쓰기6회, BasePart/광원/입자/Script0. 원본 TD, 스토리·저장·권위 바닥 불변. native 생성 비용이며 실제 성능 측정은 아니다.

## 재현·결과

고정 rbxlx의 Script/LocalScript Disabled만 변경한 `/tmp/tlt-ec03-rim-final-qa.rbxlx`를 별도 Studio로 열었다. PlaceId0/플레이어0에서 [verify.luau](verify.luau) 실행, 두 모듈 Source 일치 확인 후 CampaignWorld.create(4)로 carve/접지/충돌 마감한 지형 검사. Source 주입 없음. [결과](results.json).

- 능선2곳 실측 중심 높이71.66/87.88stud, Basalt 재질·예약 제외·추가 부품 없음 통과.
- Shared/Server/Client 하위 모듈521개 loadstring 구문 통과.
- EC11장/연결9곳: 기존144목표8396표본, Easy150목표8526표본. 차단/바닥 누락/서버 높이 보정/안내 실패/단차0. 실제 Humanoid 이동은 아니다.
- 대화 내 Studio screen_capture `EC03_Rim_After`: 카메라(500,265,-12360)→(800,185,-12495), 기본 Edit 주간 조명. 새 능선의 큰 형태는 보이지만 넓은 평지·각진 경계·원거리 시설의 부자연스러운 배경은 남아 있다. 저장된 비교 이미지와 동일조건 이전 화면은 이번 실행에서 확보하지 못했다. 미술 수용 증거로 간주하지 않는다.

## 남은 수용·다음 담당

이 구현은 부분 후보이며 TLT-063/G5 완료가 아니다. DES/QA가 실제 영웅 카메라·회피/구조 전투, 지역 조명, 게시 클라이언트·기기·스트리밍·다인 성능과 사용자 미술 수용을 검증해야 한다. 원본 능선과의 동일조건 전후 이미지도 후속이다. 다음 맵 작업은 작은 능선 증량보다 맵 바닥/외곽과 광산 시설의 큰 공간 연결을 검토한다. Roblox 게시/릴리스 태그 없음.
