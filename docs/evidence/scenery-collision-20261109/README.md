# 확장 맵 충돌 리뷰·수정 · 0.89.1

2026-11-09 · TLT-031/050/057/061~065/084 · ENG/DES/QA → 실제 플레이 QA · 미게시

사용자 요청에 따라5에픽의 본편35장·사이드12장·확장82사건/246단계와44지역의 실제 생성 지형을 리뷰했다. 프로젝트 제작 스킬을 적용했으며 원인이 명확한 충돌 결함 수정으로 처리했다. 배경색·승인 자산·스토리/안정ID·목표 위치·보상/저장·전투 수치는 변경하지 않는다. 이번 버전은 기존0.89.0의 다섯 에픽 Diamond 개선을 포함한 후속 수정이며 TD 운영/게시/live DataStore를 변경하지 않았다.

## 발견과 수정

| 발견 | 수정 |
| --- | --- |
| `EpicEnvironmentKit`와 TD 환경 복제기가 모든 외형을 비충돌로 생성 | 최종 서버 월드 조립 때 영구적인 벽/기둥/줄기/암석을 명시적으로 분류해 `CanCollide`와 `CanQuery`를 켠다. 메시의 실제 기존 충돌 형상을 사용하고 전체 수관/모델 경계 상자를 새 벽으로 덮지 않는다. |
| 동서 확장 입구도 남북 방향 아치·좁은 입구 | 방향을 회전시키고 폭64/높이26으로 넓혀 주 도로와 확장 연결로의 회전을 함께 확보한다. |
| 뿌리 회랑·얼음 갤러리 측벽이 연결로/다른 지역 도로를 가림 | 정적 벽을 외곽으로 옮기고 진입부 및 도로 교차 지점에 실제 빈 통로를 낸다. 보이지 않는 통과 벽으로 해결하지 않는다. |
| 원래 지역 외곽용 절벽과 새 사건 공간이 겹침 | 절벽 배치 예약에 사건 바닥·연결 경사로 범위와 높이를 포함한다. |
| 벽/나무를 물리화하면 이전의 장식 배치가 동선을 침범 | 실제 형상 겹침/몸체 sweep로 발견한 조립체를 외형과 함께 바닥이 있는 안전한 위치로 옮긴다. 스토리 앵커/NPC/스폰은 옮기지 않는다. 지역 간 보고의 직선 가상 경로는 도로망과 구분한다. |
| EC-01 용광로 후면이 광부 사이드 연결로를 막음 | 측벽/상단을 유지하며 폭40/높이12의 출입구를 만든다. |
| DW-Q4 연결 경로에 Terrain이 실제 바닥보다 약2stud 높게 남아 길찾기 실패 | 실제 entry→rampStart→rampEnd→사건 공간을 따라 Terrain 여유 높이를 확보하고 바닥 위 사건 공간도 정리한다. 기존 파츠 바닥은 유지한다. |
| 비충돌일 때만 가정한 거리 숨김이 이제 숨은 벽을 만들 위험 | 충돌 중인 지형은 거리 예산 기능이 투명하게 숨기지 않는다. 작은 장식/수관/빛과 그림자의 기존 절약은 유지한다. |
| 확장 예약 뒤 EC-S2 등에서 주 랜드마크 배치 후보가 부족 | 동일 안전/지면/이웃 지역 검사를 통과하는 모서리 후보를 추가해44지역 모두 주 랜드마크1개를 확보한다. |

개인 저장 상태에 따라 움직이거나 사라지는 교량/성문/배우/회로 연출, 풀·잎·빛·길 그림은 계속 비충돌이다. 개인 진행이 다른 파티원의 공유 통행을 막지 않는다. 이미 존재하는 실제 바닥과 물리 경계는 일괄 비활성화하지 않는다.

## 검증과 재현

- [기존0.89.0 충돌 검사](baseline-collision.json): 새 충돌 계약 검사 실패를 확인했다. 실패2,792개는 검증 assertion 수이며 고유 결함 수/전체 맵의 충돌 부재를 뜻하지 않는다. 기존 바닥/원래 충돌체와 새 장식 외형을 구분한다.
- 후보8 전 맵 검사에서 도로/앵커 몸체 충돌·바닥 이상은0이었지만 DW-Q4 경로2개가 `NoPath`였다. [수정 전](dw-route-debug.log)과 [수정 후](dw-route-fixed.log)에 실제 연결로의 구간/전체 경로가 `Success`로 바뀌고 entry 지면40.015625→38.08로 정렬된 결과를 보존한다. Terrain 접촉이 있는 직선 경로와 우회 가능한 길찾기 성공은 구분한다.
- 확장 검사의 바닥 Raycast에 `workspace.Terrain`을 포함하고 몸체 검사는 메시 경계 상자 대신 `GetPartsInPart` 실제 형상을 사용한다. 이전 검사에 빠졌던 Terrain 턱과 속이 빈 메시의 경계 후보를 구분한다.
- `python3 tools/prepare-scenery-collision-native.py` → `/tmp/tlt-scenery-collision-native.luau`: 변경10모듈 Source 일치·전체 Luau 문법과 영구 충돌/개인 연출 제외·방향별 실제 몸체 sweep·82입구·캐시 중복을 확인한다.
- `python3 tools/prepare-campaign-expansion-native.py`: 기존 저장 재개/호위/회로/장면/지도 회귀와82사건/246단계의3,974 바닥·몸체 지점을 확인한다.
- `python3 tools/prepare-map-traversal-native.py`:44지역·로비/훈련장·메인/사이드/같은 에픽 연결로/귀환을 검사한다. 원본의 긴 출력과 별개로551개 경로의 상태와 실패 좌표를 압축 보고한다.
- 후보9에서 충돌 assertion **23,982 PASS**, 영구 충돌 파츠 **6,384개**, 지역별 대표 벽/줄기/바위/아치의 실제 sweep 통과. 이는 모든 파츠에 사람이 직접 걸어 본 수가 아니다. TD 배치 **1,202 PASS / 44주 랜드마크 / 131조립체**.
- `lua tests/campaign-expansion.spec.lua`, `lua tests/campaign-expansion-review.spec.lua`, `lua tests/story-fun.spec.lua`:7,688 +3,362 +1,722 PASS. 고정 빌드 검증 결과는 마감 기록에 추가한다.

공식 API 근거(2026-11-09 확인): [Roblox 충돌](https://create.roblox.com/docs/workspace/collisions)은 `CanCollide`의 물리 작용과 `CanTouch` 이벤트를 구분한다. [메시 충돌 형상](https://create.roblox.com/docs/parts/meshes)은 시각 형상과 collision fidelity의 차이를 설명한다. 이번에는 원본 메시 fidelity/자산을 바꾸지 않고 기존 형상을 엔진 쿼리로 검증한다.

## 수용 범위와 다음 담당

격리 로컬 Studio의 생성 인스턴스·물리 쿼리·길찾기/코드 검사다. 실제 게시 클라이언트 보행/회피·네트워크/스트리밍·1~4인+AI·터치/패드·저사양 FPS/메모리·최종 미술 수용은 미검증이다. 고체를 거리만으로 숨기지 않아 렌더/충돌 부하가 증가하므로 실기기 성능 수용이 필요하다. 기존 테스트 공개 범위/실계정은 변경하지 않는다.

다음 담당 QA/사용자: 새 빌드에서 DW-Q4 출입/귀환, FV 갤러리 교차로, EC-01 후면, HG 벽·묘석, 각 숲의 줄기/절벽을 보행·회피로 확인하고 실제 게시 테스트 왕복/기기 성능을 수용한다. 부모 티켓을 Done으로 변경하지 않는다.


## 고정 빌드 마감·최종 수용 결과

소스 `4c640a257ea87bc8af46c3c584a090449dab935c`를 origin/main에 푸시한 뒤 `python3 tools/build-game.py --source HEAD --record docs/evidence/scenery-collision-20261109/build.json`으로 **0.89.1 단일 빌드 성공**. 산출물 `builds/0.89.1/TheLastThrone-0.89.1.rbxlx`,15,998,573 bytes, SHA256 `a329dc397c4f4b427db751eac67acbf342ac3ddd41d3e3b3e819245be5c70321` 재확인. 신규 LFS 자산/빌드 참조 LFS 입력 없음. 게시·릴리스 태그 없음.

`python3 tools/prepare-scenery-collision-native.py --all` → `run-in-roblox --place builds/0.89.1/TheLastThrone-0.89.1.rbxlx --script /tmp/tlt-scenery-collision-native.luau`의 [첫 통합 실행](native-initial.log)에서 변경10개 런타임 모듈 Source 일치·전체 Luau 문법, 충돌23,982·TD 배치1,202·확장9,192·기존 충돌 복구854검사를 통과했다. 생성48,402 BasePart, 영구 충돌6,384개,44주 랜드마크/131배치,82사건/246단계의3,974지점 이상0이다. 도로3,740조각/34,374몸체·바닥 표본·앵커688개 및 로비100표본의 장애/바닥 이상0, 시설 접근18개 성공. **551동선은546 Success·5 SamePoint·NoPath0**이다.

이 첫 실행의 최종 `SCENERY_ALL_SUITES`는 false였다. 원인은 이전 여섯 목표만 읽던 감시탑 검사이며, 필수 exp_2를 건너뛴 과거 직선의 counterweight 지면 검사가 실패했다. [기존0.89.0에서도 같은 실패](legacy-route-baseline.log)를 확인했다. 검사를 현재 CampaignContent의 spirit 이후 필수 확장 구간/연결 경로와 실제 길찾기 경로로 갱신했다. 충돌하는 나무를 지워 직선을 뚫도록 요구하지 않고, 점프 없는 우회 경로와 몸체/지면을 검사한다. 시작점+3 높이로 계산한 길찾기 waypoint는 authored foot 좌표가 아니므로 실제 바닥에 재투영해 검사한다. 옛 네 기둥/도로 sweep·캐시 복구·스폰 보존 검사는 유지했다.

같은 고정 파일에서 `run-in-roblox --place builds/0.89.1/TheLastThrone-0.89.1.rbxlx --script tests/deepwood-watchtower-road-native.luau`를 재실행해 **2,658검사/14구간 모두 통과**했다. [별도 재검증 로그](native-watchtower.log). 게임 코드/빌드를 바꾸지 않고 검증 스크립트만 수정했으며551동선 전체의 재실행 성공이라고 바꾸어 기록하지 않는다. [현재 항목별 최종 집계](native-summary.json)는 첫 실행의 false와 수정 검사 통과를 함께 보존한다. `python3 tests/single-build.spec.py --artifact builds/0.89.1/TheLastThrone-0.89.1.rbxlx`도 역할10/도착 로딩192·프로젝트/별칭/실제 아티팩트 계약 PASS다.

검증 스크립트 갱신과 빌드/수용 증거는 후속 커밋으로 푸시한다. 실제 계정·사람 조작·게시 클라이언트·성능/미술 수용은 여전히 미검증이다. 기존 사용자 Blender/삭제 컨셉/미추적 자산은 보존했다.
