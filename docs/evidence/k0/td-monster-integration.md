# TD 몬스터 재사용 연결

2026-10-28 · `TLT-002/003/032/033` 일부 · 총괄/3D/엔지니어/QA

## 수정 이유와 구현

기존 원본을 공유하라는 요구에도 첫 원형에서 임시 도형을 우선한 판단이 잘못됐다. TD의 원본 GLB와 분리된 runtime MeshPart가 이미 있었으며, 별도 RPG 동작 검증은 재사용을 미룰 이유가 아니었다. 사용자가 고블린·슬라임·오우거와 Meshy 백업을 다시 지적해 실제 연결을 진행했다.

- [원본 기록](td-monster-sources.md)의 runtime XML과 원본 GLB 3개를 바이트 그대로 LFS에 보존한다. 원본 해시는 [manifest](../../../assets/shared/td-monsters/manifest.json)에서 추적한다.
- `default.project.json`은 고정된 runtime을 `ServerStorage.TdMonsterModels`에 연결한다. 형제 TD 저장소가 없어도 이 저장소와 LFS 원본으로 재현할 수 있다.
- `TdMonsterAppearance`가 Goblin/Ogre의 5부위 메시를 복제한다. 원본 Mesh/Texture ID와 비율을 유지하고 발 원점·높이 3.6/6.05·+Z→-Z 방향을 K0 리그에 맞춘다. 기존 임시 눈·귀·단검·곤봉은 제거한다.
- 서버 이동·피해 판정용 R6 부품은 투명하게 유지한다. 표시 메시는 비충돌·비쿼리·비터치·Massless이고, 원본 팔다리 윗면에 맞춘 관절과 Weld로 움직인다. 메시 자체가 피해량이나 판정을 결정하지 않는다.
- `K0EnemyVisual`은 무기가 포함된 TD ArmR 쪽으로 공격 포즈를 적용하고, 보행 회전과 다리 바운딩박스의 바닥 보정을 수행한다. 최종 애니메이션 클립 수용은 별도다.
- Slime은 원본·템플릿·단일 Body 어댑터·로드 검증까지 포함한다. K0 전투 대상은 Goblin/Ogre 두 종이며 Slime의 분열·AI·보상은 구현하지 않았다.

## 검증 기록

고정 빌드 결과는 [빌드 기록](build.md)에 추가한다. 원본 보존/정적 검사와 Studio 로드/표시, 게시된 테스트 클라이언트의 권한·성능을 구분한다.

| 검사 | 실제 결과 |
| --- | --- |
| `python3 tests/td-monster-assets.spec.py` | 101개 통과, 실패0. TD와 실제 복사본 SHA·GLB 자체 포함 리소스·XML43모델·선정11부위·LFS 속성·Rojo 연결 확인 |
| `lua tests/k0-rules.spec.lua` | 기존 전투 규칙56개 통과 |
| `lua tests/k0-spawn.spec.lua`, `lua tests/k0-appearance.spec.lua` | 기존 스폰 생명주기·R6/R15 기사 소품 모의 검사 통과 |
| `luac -p src/server/World/TdMonsterAppearance.luau` | 구문 검사 통과 |
| `python3 tests/make_k0_source_probe.py --output-dir /private/tmp/tlt-td-monster-probe-pre` 후 `run-in-roblox` | 격리된 원본 메시 fixture에서 177개 통과·실패0·수집 런타임 오류0. 11부위 Mesh/Texture 콜백22개 전부 Success. Goblin/Ogre 물리 안정·HP300/6000·Goblin 재생성 외형 확인. Player0이며 실제 클라이언트 수용은 아님 |

위 source probe의 어댑터 SHA는 `893fdec06a0f4c5797252c2ea7e0d936df92cd2a9ef69c6abc1e9985616c9a1b`, smoke SHA는 `badfdbab0423dc8c5d8a94b37bdaa5043899adb975c3e3a63631ef72d1b5fc80`다. 기존에 별도 빈 fixture에서도 관측한 `rbxassetid://203785492` 유형 불일치 경고는 이번에도 발생했으며 출처 미확인이다.

후속 고정 빌드 `0.2.1`도 동일 엔진177개를 통과했다. 실제 Studio Play의 독립 PlaceId0에서 Goblin/Ogre의 TD 메시·색맵을 화면으로 확인했고, Goblin의 추적·공격·무기 팔 예비 동작을 관측했다. Slime는 로드/어댑터 검사까지이며 전투나 실제 플레이 배치를 완료한 것이 아니다. 명령·커밋·파일 해시·관측 한계는 [빌드 기록](build.md)의 0.2.1 항목, 엔진 원본 출력은 [smoke 로그](td-monster-build-smoke.log)에 남겼다.

## 남은 범위와 다음 담당

기사 검/방패와 환경은 아직 임시 도형이다. TD UI·기사 원본 연결, 실기기·다인·게시된 테스트 환경의 접근 권한과 성능은 후속 담당 ART/ENG/QA가 검증한다. [첫 구현 리뷰](first-implementation-review.md)의 전투 판정·입력 결함도 별도 미해결이며 이번 외형 교체로 해결됐다고 보고하지 않는다. 자산 원본이 있다는 사실을 완성된 RPG 리그·AI·전투 수용으로 확대하지 않는다.

TD 운영 소스·실제 Place·DataStore·상품은 변경하지 않았다. 이 작업은 로컬 K0 개발 빌드이며 릴리스 태그나 Roblox 게시를 만들지 않는다.
