# 부유 지형·식생과 내비게이션 가림 교정

2026-11-04 · TLT-028/031/057/061/062/063/064/065/084 · ENG → QA · 최종0.71.5 · 로컬 수정·미게시.

사용자 첨부2장(Deepwood의 머리 높이 잔디 판·도로 위 분리 덤불)을 기준으로 공통 생성 코드를 확인했다. TD ForestKit의 ContinuousTerrain/DeepCliff/BankVegetation은 재질별로 여러 섬을 합친 메시다. 이를 지역 크기에 맞춰 늘리거나 개별 덤불처럼 반복 배치하면 Terrain의 낮은 접근로 절삭과 일치하지 않고, 하나의 피벗만 접지돼 부유 표면·분리된 식생이 남는다. 원본 공유 자산은 보존하고5에픽44구역의 해당 반복 배치를 제거했다. 연속 지형은 기존 Terrain과 서버 바닥이 담당한다.

나무·소형 바닥 장식·장식 길은 절삭 이후의 실제 Terrain/서버 바닥에 접지한다. 다른 지역으로 돌아가는 목표를 현재 지역에서 장식 도로로 직접 잇던 경우도 제한했다. 전투/상호작용/스폰 좌표·보상·물리 콜라이더는 보존한다. 캐시 ArtVersion은5로 올려 이전 생성물을 재사용하지 않는다.

길 안내는 기존 금색 갈매기 화살표의 형태·직선 방향·설정·도착 유지 계약을 따른다. BoxHandleAdornment의 AlwaysOnTop/ZIndex로 가려짐 없는 표시를 겹치고 숨김/사망/훈련/목표 해제/정리를 동기화한다. 바닥 투영에는 smooth Terrain과 기존 전망대·경사로·후반 Ground도 포함한다. API 근거: [HandleAdornment](https://create.roblox.com/docs/reference/engine/classes/HandleAdornment), [Raycasting](https://create.roblox.com/docs/workspace/raycasting) (2026-11-04 확인). 명확한 배치/렌더 결함 수정으로 별도 RPG 기능 비교 조사는 생략했다.

검증 결과·고정 빌드/소스/해시·한계는 마감 후 아래 기록으로 연결한다. 부모 티켓은 In Progress를 유지한다. 실제 게시 클라이언트·모바일 실기기·다인 성능·최종 사용자 미술 수용은 별도다. 기존 사용자 Studio/다른 미커밋 파일·TD 운영·게시·상품/저장은 변경하지 않는다.


## 최종 교정과 실제 화면

실제 화면 재검토에서 추가 발견한 문제도 수정했다. 경사 절삭면을 가로지르는 얇은 장식 길은 폭/길이의9점이 실제 바닥을 따르는 경우만 남긴다. 얼음 성문의 떠 있던 성가퀴에는 연결 보/기둥을, 묘지 성당 상부에는 지면까지 이어지는 버팀기둥을 연결하고 수로 상부 지지 간극을 줄였다. 새 구조는 기존 장식 계약의 비충돌·비쿼리·비터치다.

최종0.71.5 고정 빌드의 실제 편집 화면: [Deepwood](Deepwood.png) · [Frozen Vale](FrozenVale.png) · [Ember Caldera](EmberCaldera.png) · [Gloamwood](Gloamwood.png) · [Haunted Graveyard](HauntedGraveyard.png). 각 에픽 대표 근거리 카메라1개이며44구역의 모든 시점/정상 조작을 육안 수용했다는 뜻은 아니다. 합성 컨셉이 아니며 편집 기본 조명이다. 최종 미술/모바일/성능 수용과 구분한다.

## 빌드·검증·실패 기록

최초0.71.3 입력 `dfeb00554954c352877f69f57fa89e2e9c057794`의 Lobby/Battle 빌드는 성공했다([build.json](build.json)). 초기 엔진216,655검사와 내비게이션을 통과한 후 실제5지역 화면에서 후속 교정 범위를 찾았다. 0.71.4는 동시 진행 중인 별도 스탯 작업이 먼저 예약/빌드했으므로 빌드 도구의 기존 산출물 덮어쓰기 방지가 실행을 거부했다. 기존 파일은 보존하고0.71.5를 새로 예약했다. 0.71.4를 이번 변경의 성공 빌드로 보고하지 않는다.

최종 입력 `d70fae90671345f98e59ef04bd31b7f621ca9c2c` / VERSION0.71.5. `python3 tools/build-regional-caster-freeze.py --source d70fae9 --record docs/evidence/map-grounding-navigation-20261104/build-0715.json`으로 커밋 소스/실제LFS 입력을 분리해 Lobby/Battle 모두 빌드 성공했다. [명령·산출물·SHA256](build-0715.json), [검증 후 동일 해시](verification.json). 이미 커밋돼 있던 별도 작업은 해당 입력 트리에 포함되며 다른 미커밋 파일은 포함하지 않았다. 게시/릴리스 태그 없음.

- `run-in-roblox --place builds/0.71.5/TheLastThrone-Battle-0.71.5.rbxlx --script /tmp/tlt-map-grounding-final-suite.luau`: 맵 엔진 **227,441검사 PASS**,44site·5,492바닥 표본·3,150보호 표본·750기존 전망대/램프 표본·실제Terrain/기존 충돌 보존·길 폭/길이 접지·캐시 재호출. [JSON](final-native.json), [로그](final-native.log). 같은 실행의 내비게이션은 첫 Heartbeat의0.15초 고정 대기로 실패했으므로 suite 전체 성공으로 보고하지 않는다.
- `run-in-roblox --place builds/0.71.5/TheLastThrone-Battle-0.71.5.rbxlx --script /tmp/tlt-navigation-final.luau`: 내비게이션 **PASS**. 실제 엔진의 근접/도착·이동 후 직선 방향·큰 가림물과 AlwaysOnTop 표시·숨김 동기화·smooth Terrain·스트리밍 바닥 부재·설정/훈련/사망/목표 해제. [최종 로그](final-navigation.log). 구현을 바꾸지 않고 대기 fixture를 갱신한 뒤 별도 실행했다.
- `run-in-roblox --place builds/0.71.5/TheLastThrone-Battle-0.71.5.rbxlx --script /tmp/tlt-grounding-final-preview.luau`: 실제 런타임과 같은 에픽별 순차 생성5회·44구역의 version5/병합 부유섬 부재 **PASS**, 대표5시점의 실제 화면 저장. [로그](final-scoped-runtime.log). 이 임시 미리보기 세션은 끝나 자동 종료됐다. 원래 사용자의 Studio 세션은 보존했다.

초기 길 접지 테스트는180stud 위에서 광선을 내려 기존 건축 상부를 바닥으로 잘못 판정했다([최초 로그](first-final-native.log)). 지지면을 확인하는 광선을 바닥 근처로 제한하고 기존 GroundedForest 지지체를 fixture의 조회 대상에 포함해 교정했다. 내비게이션 대기를 단순 가시성 조건만으로 바꾼 첫 시도는 이전 프레임의 표시를 즉시 통과해 이동 후 방향 검사에 실패했다([로그](first-navigation-wait.log)). 최소 갱신 시간과 최대4초 조건 대기를 함께 사용해 해결했다. 별도 runner를 미리보기와 동시에 실행한1회는 공용50312포트 충돌로 시작하지 못했다([로그](navigation-runner-port-conflict.log)); 미리보기 종료 후 단독 실행 결과가 최종 PASS다. 테스트 fixture 변경 때문에 검증된 게임 빌드 바이트를 덮어쓰지 않았다.

기존 asset203785492 타입 불일치 경고는 로그에 남아 있다. Studio MCP의 읽기 전용 require1회는 Network capability로 거부됐고, 이후 기존 인스턴스 좌표를 조회했다. 실제 게시 이동/저장/실기기·4인+AI·모든 시야의 잔여 부유물·최종 미술 수용은 미검증이다. 다음 담당 QA는 최종0.71.5를 게시 테스트 환경/실기기에서 실행해 첨부 위치와 각 에픽의 접근로·가림물 뒤 길 안내를 확인한다. 부모 티켓은 In Progress다.
