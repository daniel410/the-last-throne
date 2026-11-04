# DW-01 페이즈2 보급품 소품 수정 · 0.67.4

2026-11-03 · TLT-061/DW-01/props · ENG/DES/QA · 로컬 수정·미게시.

원인: `supplies:manifest`의 `ledger` 활동 유형을 공용 `LedgerDesk`로 해석해 숲길에 책상이 생성됐다. 현재 본편의 보급대 습격·식량/의약품 회수 서사에는 부적절한 소품이었다. 원인이 명확한 콘텐츠 결함이므로 제작 스킬의 결함 수정 예외에 따라 별도 사례 조사는 생략했다.

수정: 해당 챕터/목표/단계의 안정ID로 `ConvoySupplyCrate`를 지정한다. 기존 `SupplyCrate`의 판자·철제 보강·봉인27부품 중22부품을 재사용하고 종이 목록과4개 줄을 추가한다. 목록은 상자 뚜껑 위에 놓이며 봉인이 한쪽 모서리를 누른다. 영어 목표와 Eryn 대사에 습격 중 수레에서 떨어진 보급 상자라는 이유를 명시한다. 야영지 등 다른 장부/지도 책상은 유지한다. 저장ID·목표 좌표·조사 유형/순서·보상 변경 없음. TD 원본/운영·상품·DataStore·게시 변경 없음.

## 검증

- 고정 소스 `7cfb5638f7e8b021bbc1ed122ab064c3956708e5`, VERSION `0.67.4`.
- `python3 tools/build-regional-caster-freeze.py --source HEAD --record docs/evidence/deepwood-convoy-prop-20261103/build.json`: 분리한 커밋 소스의 Lobby/Battle 모두 성공. 입력 LFS·산출물 SHA256은 [build.json](build.json).
- Studio `tlt-epic-art-candidate.rbxlx` Edit의 임시 폴더에서 고정 소스 StoryProps/DeepwoodAdventure와 기존 StoryPropGeometry 복제본을 사용해62개 검사 PASS. 보급 상자/목록/봉인·27부품·Atomic 스트리밍·비충돌/비터치/비쿼리·다른 야영지 책상 유지·안정ID/좌표 확인. fixture는 검사 후 삭제했다. 새 빌드 전체의 Studio 실행이나 실제 정상 플레이로 보고하지 않는다.
- `lua tests/dwarf-stun-and-first-story.spec.lua`:57 PASS. `lua tests/deepwood-quests.spec.lua`:31 PASS. `lua tests/deepwood-progress.spec.lua`:570 PASS. 합계658.
- `git diff --check`: PASS. 기존 `tests/story-props-native.luau`에 보급품 회귀 조건을 추가했으며 전체 캠페인 native suite는 이번 작업에서 실행하지 않았다.
- 처음 시도한 `tests/deepwood-adventure.spec.lua`는 존재하지 않아 실행 실패했으며 실제 존재하는 퀘스트/진행 검사로 대체했다. 새0.67.4 Battle 열기는 Studio 연결에서 Place 미개방으로 응답해 위 격리 fixture로 검증했다.

## 남은 수용과 인계

QA/사용자:0.67.4 Battle에서 DW-01 페이즈2 정상 조작·목록 가독성·카메라/실기기 미술 수용. 게시 클라이언트 검증은 미실행이다. 부모 TLT-061은 In Progress를 유지하며 릴리스 태그는 만들지 않았다. 다른 진행 작업의 미커밋 파일은 커밋/고정 빌드에서 제외했다.
