# MR-01 실제 Importer 확인·비호환 채널 수정

2026-11-03 · TLT-005/032/033/055/057/084 / MR-01 · ART/ENG. **가져오기 사전 확인 완료, 업로드 승인 응답 대기**.

## 실패와 수정

[이전 로컬 후보3종](../regional-casters-mr01-20261103/README.md)을 실제 Studio File → Import로 열었다. QueenIceElf v1의 Import Preview에 다음 경고가 나타났다.

> This file looks like it contains scale or weight animations.

해당 문장은 실제 UI 관찰 기록이다. [Roblox Importer 공식 문서](https://create.roblox.com/docs/studio/importer)의 경고/옵션을 확인했고, GLB의10개 애니메이션 각각에9뼈의 scale 채널이 있는 것을 분석했다. 종별90개,3종270개이며 모두 단위 스케일 상수/부동소수점 반올림 범위였다. 이를 별도 [v2 GLB](../../../assets/animations/regional-casters-v2/README.md)에서만 제거했다. 회전·위치 채널과 모델 형상을 바꾸지 않았으며 v1은 보존했다.

`tools/prepare-regional-caster-import.py`는 제거 전에 모든 scale 표본이1에서1e-5 이내인지 검사한다. 실제 크기 변화나 morph 채널이면 조용히 버리지 않고 실패시킨다. JSON의 채널/샘플러 참조만 재구성하고 GLB 바이너리 청크는 바이트 단위로 유지한다.

## 실행·검증 결과

- `python3 tools/prepare-regional-caster-import.py`:3종 각각90개 상수 scale 채널 제거, SHA256 기록. [입출력 manifest](../../../assets/animations/regional-casters-v2/manifest.json).
- `python3 tests/regional-caster-import.spec.py --output /tmp/tlt-mr01-import-results.json`: **41,780 PASS**. v1/v2 바이너리 동일·scale/morph 채널 없음,10클립·2메시·뼈 계층·가중치·손/지팡이 접합·발 고정·지팡이 강체·독립 팔꿈치/손목을 다시 검사했다. [세부 결과](results.json). CPU 계산이며 실제 가져온 Roblox MeshPart의 스킨 렌더를 측정한 결과가 아니다.
- 실제 Studio Import Preview에서 QueenIceElf/VolcanoShaman/KingVolcanoShaman v2를 각각 열어 File General의 경고 아이콘/scale 안내가 사라지고10개 클립이 표시되는 것을 확인했다. VolcanoShaman의 Attack 항목 선택 시 모델 자세가 바뀌는 미리보기도 관찰했다. 표본 관찰이며 전체 공격·실제 입력·게시 클라이언트 수용이 아니다. 이 대화의 컴퓨터 사용 스크린샷에 직접 확인 과정이 남아 있다.
- `Rig Type: Custom`, `Creator: Me`, `Keep Zero Influence Bones: ON`, `Add to Workspace: ON`, 패키지OFF를 확인했다. QueenIceElf/KingVolcanoShaman에서 Custom과 기준 뼈 보존ON을 직접 확인했다. VolcanoShaman은 경고/클립 미리보기까지만 확인했다. 파일을 Browse로 바꾸면 기준 뼈 보존 체크가 초기화되므로 실제 가져오기 직전에 종별로 다시 확인해야 한다. 업로드/최종 Import 버튼은 누르지 않았다.

검증용 별도 `run-in-roblox` 세션(PlaceId0, `TLTQA=MR01Import`)도 생성했으나, native UI 제어가 기존 RPG Studio 창을 선택해 별도 세션에서 가져오기를 수행하지는 않았다. 해당 임시 세션은 `MR01Finish=true`로 정상 종료했다. 실제 Import Preview는 기존 RPG 문서에서만 열었으며, Workspace 추가·기존 스크립트 변경·문서 저장·Place 게시는 수행하지 않았다. File → New에서 열린 빈 Place1 문서도 이번 가져오기/검증 원천으로 쓰지 않았다.

## 승인 경계와 다음 담당

컴퓨터 사용 도구의 **Computer/Browser Use Confirmation Policy → Pre-Approval Allowed → Upload files** 규칙에 따라, 특정 파일의 업로드에 대한 명시적 승인이 필요하다. 이번 사용자 메시지는 ‘다음 작업’이므로 GLB3개를 Roblox Me 개인 자산으로 새로 전송하고 로컬 연결하는 구체적 범위를 확인하도록 질문했다. 응답이 오기 전까지 업로드를 수행하지 않는다. 이는 미술 수용 요청이나 Place 게시 승인이 아니다.

승인 후 ART/ENG는3종을 새 자산으로 가져오고 Mesh/Image/Skin/Model 유형·소유자·RPG Experience 사용 권한·모델/본 계층·소켓을 기록한다. 실제 가져온 메시의 스킨 변형을 검증한 뒤 `TdMonsterAppearance`/`K0EnemyMotion`의 별도 Bone 어댑터를 연결한다. 저장소의0.62.7 몬스터 런타임은 기존3종 외형/팔 고정을 유지한다. 새 게임 빌드·VERSION 증가·릴리스 태그는 없다. 상위 MR-01은 In Progress다.
