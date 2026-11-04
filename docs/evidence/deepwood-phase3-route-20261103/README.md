# DW-01 페이즈3 절벽 침범 수정 · 0.67.6

2026-11-03 · TLT-061/DW-01/route · DES/ENG/QA · 로컬 수정·미게시.

사용자 화면의 `Find Eryn's trail mark` 접근 구간을 동일 카메라로 Studio에서 재현했다. DW-02의 `OrganicTerrain.CliffRock.body_geom`이 DW-01 통로에 침범했다. 중심 `(-1225,28.2,-1068.67)`, 실제 크기 약 `136.58×136×138.13`이다. 장식 메시라 CanCollide=false이며 몸 높이 충돌 Raycast는 비어 있었지만 시야와 목표를 덮었다. 앞선 환경 검사도 비충돌 계약과 바닥만 검사하여 이 문제를 놓쳤다.

## 수정

- 큰 절벽을 만든 뒤 실제 회전된 메시의 경계를 전체 캠페인 구역 및 연결로와 대조한다. 발밑0.5stud부터 카메라/인물 높이18stud까지 통로를 침범하면 장식 생성을 취소한다. 이웃 구역도 검사하며 안전 여유8stud를 적용한다. 멀리 떨어진 절벽은 유지한다. 원본 TD 메시/자산 권한/운영 Experience는 변경하지 않는다.
- 활동 단서의 지점뿐 아니라 목표→각 단서→목표의 연결 구간을 식생/지형 예약에 포함하고20stud 이하 간격으로 Terrain을 비운다. 기존 목표ID·좌표·상호작용·보상·서버 바닥 콜라이더는 보존한다.
- 환경 캐시 버전을3으로 올려 기존 생성 장면도 갱신한다. 테스트 장면의 원본 소스도 저장소 수정본으로 교체하고 임시 QA 모듈은 정리했다. [실제 수정 후 화면](after.png)은 편집 카메라 캡처이며 플레이 화면 합성이 아니다.

## 검증

환경: 로컬 `tlt-epic-art-candidate.rbxlx`, PlaceId0·플레이어0, Studio Edit. 원본 역할의 모듈을 복제한 후보 소스로 실행했다. 고정 빌드 전체를 Studio에서 실행한 결과와 구분한다.

- `tests/deepwood-phase3-route-native.luau`:35,319 PASS. 실제 문제 절벽 생성 거부/먼 절벽 유지·4구간79표본·통로 중심/좌우6stud의 평탄한 바닥·절벽 메시 침범 부재·폭4/높이5stud Blockcast 통과. `tracks`의3단서에서 `trail_exit`까지 검사했다.
- 점프를 금지한 Roblox PathfindingService: 큰 발자국 `(-1259,3,-1051)`→Eryn 표식 `(-1219,3,-1001)`, Success·18waypoints. 실제 인간 조작 완주나 Humanoid 보행 측정으로 보고하지 않는다.
- 확장 `tests/epic-world-art-native.luau`:216,788 PASS.44구역,4,771바닥 표본,2,943보호 표본,750기존 경사/발판 표본. 원래 충돌을 유지하며 모든 장식 비충돌·재생성 멱등 검사 통과. [원본 결과](native.log).
- 최초 환경 suite는 이미 생성된 장면의 융기 Terrain을 기준 바닥으로 잡아 새 보호 구간을 낮춘 것에 실패했다. 기존 장식과 Smooth Terrain을 초기화한 후 같은 후보 코드를 다시 실행해 통과했다. 최초 실패도 로그에 보존했다.
- `lua tests/deepwood-progress.spec.lua`:570 PASS. `lua tests/deepwood-quests.spec.lua`:31 PASS. `git diff --check`: PASS.
- VERSION0.67.5의 첫 빌드는 증거 디렉터리가 없어 Lobby 생성 후 기록 저장에 실패했다. Battle 미실행·미완료이며 [별도 기록](failed-build-0.67.5.json). 사용한 버전을 재사용하지 않고0.67.6으로 증가했다.
- 고정 소스 `0778f35f6c0c4fdd96d37d0d63101ddaa371c29c`,0.67.6 Lobby/Battle 빌드 성공. `python3 tools/build-regional-caster-freeze.py --source HEAD --record docs/evidence/deepwood-phase3-route-20261103/build.json`. [입력/LFS/산출물 SHA256](build.json) 기록 후 두 파일 해시 재검증 PASS. 다른 작업의 미커밋 파일은 고정 빌드/커밋에서 제외했다.

## 미검증·인계

QA/사용자:0.67.6 Battle의 실제 페이즈3 조작·기기별 카메라/최종 미술 수용. 다른 구역의 절벽 생략에 따른 구도 변화는 전체 최종 미술 수용 대상이다. 보수적인 경계 검사로 통로 가까운 일부 절벽은 더 넓게 생략할 수 있다. 실기기/4인+AI·게시 클라이언트 검증은 남아 있다. TLT-061 상위 티켓 In Progress 유지, Roblox 게시·릴리스 태그 없음.
