# MR-01 주술사3종 업로드·로컬 연결

2026-11-03 · TLT-005/032/033/055/057/084 / MR-01 · ART·ENG 자체 검증, QA·사용자 미술 수용 후속.

사용자가 **“업로드·로컬 연결 진행”**을 승인했다. QueenIceElf·VolcanoShaman·KingVolcanoShaman v2 GLB를 Studio의 Creator **Me**, Custom rig, Keep Zero Influence Bones ON, Add to Workspace ON, Package OFF로 각각 새로 가져왔다. 기존 자산 덮어쓰기·Place 게시·라이브 저장/상품 변경은 없다. [실제 엔진 렌더 갤러리](index.html) · [검사 결과](results.json) · [고정 빌드/해시](build.json).

## 자산과 연결

| 종 | 새 개인 모델ID | Body / Staff MeshID | 컬러 ImageID |
| --- | --- | --- | --- |
| QueenIceElf | 123995081544370 | 87082222255321 / 98788108850990 | 116018092489297 |
| VolcanoShaman | 136821843369834 | 117483065629295 / 77540020824267 | 131610066809992 |
| KingVolcanoShaman | 117336003053779 | 119163831733699 / 112698580463422 | 105871246621076 |

업로드 큐의3건 완료, 개인 Model 인벤토리 검색, 메시6개/이미지3개의 `GetProductInfo`로 User **9156786071 / Robloxianb1b5e7p5p** 소유를 확인했다. 최종 로컬 엔진의9개 콘텐츠 가져오기는 모두 `Success`다. 게시된 Experience에서의 권한 검증은 별도 남아 있다. 원본/파생 SHA와 권한 확인 범위는 [자산 manifest](../../../assets/shared/regional-casters/manifest.json)에 고정한다.

가져온 모델은 Body·Staff의2개 MeshPart와 VisualRoot 하위9개 Bone을 공유한다. 손목 하위 Staff가 지팡이 전체를 소유하며, 메시2개를 별도로 새 Bone 계층으로 재생성하지 않는다. [SerializationService](https://create.roblox.com/docs/reference/engine/classes/SerializationService)로 실제 엔진의 바이너리 모델을 보존했다. `imported.rbxm`에는 가져온 편집 원본·10개 KeyframeSequence가 있고, `runtime.rbxm`은 편집 메타데이터를 제거한 런타임 복사본이다. `ModelStreamingMode.Atomic`을 유지한다.

서버의 `RegionalCasterAppearance`가 세 종만 새 모델로 연결한다. R6의 Humanoid·이동 루트·충돌·피해·공격 시각·보상은 기존 서버 경로다. 기존 높이6.2375 / 5.2325 / 8.10875와 스토리 배율을 사용하고 별도 밸런스 변경은 없다. 클라이언트는 변환된 Bone 곡선을 읽으며4공격의 접촉 phase **0.62**를 서버 시각에 맞춘다. 스턴·노출·공격 취소는 실제 현재 자세에서 전환하고, 지팡이 효과는 같은 프레임의 `Staff.TransformedWorldCFrame`을 따른다. 스트림 도착 때9뼈가 다 올 때까지 바인딩을 기다리고 제거 시 효과/변환을 정리한다.

10개 소스 클립은 모두 보존했다. 실행 상태는 Idle/Walk·Attack/AttackAlt/Heavy/HeavyAlt·Stunned/Exposed를 선택하고, 취소/복귀는 고정된 Interrupted/Return 시작 자세를 재생하는 대신 현재 자세에서 섞는다. 보행은 기존 후보와 같이 상체 변화이며 새 다리 IK를 구현한 것은 아니다.

## 실제 렌더에서 찾은 좌표 문제

초기 시제품은 기존 강체 템플릿처럼 추가180도 회전을 적용해 뒤를 보였다. 가져온 rest Bone/메시가 이미 **(-X,+Y,-Z)** 좌표로 바뀐 반면, 가져온 Pose를 그대로 적용하면 glTF local 자세가 재구성되어 팔이 잘못 이동했다. 수치 검사도 원본/엔진 좌표계 구분을 누락했던 초기 비교는 최종 증거로 사용하지 않는다.

최종은 추가 yaw를 제거하고 각 local Pose를 `rest⁻¹ × F × (rest × Pose) × F⁻¹`로 rest Bone 기준에 맞췄다. F는Y축180도 좌표 변환이다. 지팡이 소켓과 독립 GLB 기대값도 같은 좌표계로 비교한다. [폐기한 초기 시제품](rejected-initial-basis.png)은 **기존0.62.7 게임의 전후 비교 이미지가 아니다.** 최종 렌더는0.62.8 고정 산출물에서 촬영했다.

Roblox가24Hz/41키로 다시 표본화하므로 원본 GLB 중간 시각과 작은 보간 차이가 있다. 독립 기대값 대비 최대 위치 오차는 높이의 **0.132964%**, 회전은 **0.408304°**다. 검사 예산은0.2%/0.86°이며, 서버 접촉 시각과 실제 가져온 클립의 일치는 별도 엄격한 오차 조건으로 검사한다. [처음의 과도한 원본 동일성 조건 실패](failure-resampling-budget.log)를 남겼다. [고정 효과 부품에 질량 조건을 잘못 적용한 초기 검사 실패](failure-initial-physics-check.log)도 보존한다.

## 최종 검증

빌드 소스는 **dca9c422c3a54500d20e57291269d837f4d89e67**, 버전은 **0.62.8**이다. `git archive`로 커밋 입력을 고정하고 참조한 모든 LFS 파일의 OID/SHA를 확인한 뒤 Lobby/Battle을 생성했다. 다른 진행 중 로비/원정 미커밋 변경은 제외했다. 임시 `/tmp` 진단 fixture는 최종 게임 산출물/통과 증거에서 제외한다. 실제 릴리스 태그는 만들지 않았다.

```bash
python3 tools/assemble-regional-caster-runtime-suite.py --output /tmp/tlt-mr01-runtime-final.luau
run-in-roblox --place builds/0.62.8/TheLastThrone-Battle-0.62.8.rbxlx --script /tmp/tlt-mr01-runtime-final.luau
python3 tools/assemble-regional-motion-suite.py --scope full --output /tmp/tlt-mr01-regression.luau
run-in-roblox --place builds/0.62.8/TheLastThrone-Battle-0.62.8.rbxlx --script /tmp/tlt-mr01-regression.luau
```

| 검사 | 결과 | 조건 |
| --- | --- | --- |
| 새 스킨 리그 | **4,242 PASS** | 3종×0.6/1/1.4 배율, 독립 GLB30자세·9뼈, 30/60/144Hz4공격, 임의 시점 중단·노출·복귀, 소켓·루트/HP 불변,9자산 로딩, 늦은 Bone 도착·스트림 제거 |
| Frozen Vale 전체 | **4,056 PASS** | 모션·실제 서버 스토리 API, 저장 실패 응답 모의 |
| Ember Caldera 전체 | **4,114 PASS** | 모션·실제 서버 스토리 API, 승강기 확정 전 이동 보류 |
| 지역 개별 / Deepwood | **7,033 / 2,813 PASS** |30종의 해당 접지·공격·기존 개별 회귀 |
| 기존 스트리밍 / Battle bootstrap | **10 / 10 PASS** | 기존 Goblin 늦은 리그 도착·로컬 부트스트랩 |
| 합계 | **22,278 PASS** | 두 실행 모두 종료코드0 |

세 주술사가 팔을 고정해야 한다는 이전의 zero-angle/common-body-anchor 검사는 이제 맞지 않아 제거하고 실제 Bone 접촉 검사로 교체했다. 따라서 이전27,345개와 개수만으로 범위를 비교하지 않는다. 스토리·저장 경계 검사는 유지했다. [런타임 로그](runtime-native.log) · [전체 회귀 로그](regression-native.log). 기존 `203785492` 자산 유형 경고와 Studio MaterialManager 프로파일 경고는 최종 검사 통과와 구분해 로그에 남아 있다.

실제 플레이어0명의 Studio Run·PlaceId=0 조건이다. `screen_capture`로4공격 접촉의3종 정면/단독 측면24장과 일반공격 준비/회수6장, 전체1장을 기록했다. 이웃 모델이 가린 초기 측면12장은 `superseded-camera/`에 따로 보존하고 최종 갤러리는 단독 재촬영을 사용한다. 캡처는 메시/텍스처·스키닝 렌더 관찰 증거이며 입력 완주·영상 전 구간의 미술 수용을 대신하지 않는다. 임시 테스트 Studio를 종료하고 기존 TD/RPG 편집 세션은 보존했다.

## 미검증·다음 담당

**업로드·로컬 연결 범위는 완료**다. MR-01 전체와 상위 티켓은 미완료로 유지한다. 게시 테스트 클라이언트의 자산 권한·일반 전투 입력/피격/추격·경사/회전·모바일/PC/패드·4인+AI1 성능·최종 미술/손목/옷 관통 수용은 QA·사용자 후속이다. 현재 실제 메시 표면 전체를 엔진에서 계측한 결과로 보고하지 않는다. GPU 변형은 위 캡처와 독립 GLB 계산/실제 Bone 검사를 구분한다.

다음 담당은 QA의 MR-06 실제 클라이언트 재검증과 ART의 MR-01 미술 검토다. 다른 몬스터 후보 업로드, 기존 자산 교체, 실제 Place 게시를 이 승인으로 확대하지 않는다.
