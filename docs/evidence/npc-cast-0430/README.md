# NPC 캐스트 0.43.0 시험 적용

2026-10-31 · TLT-001/002/016/031/057/061/065/072/084 · DES/ART/ENG → QA

로비/승인5에픽을 리뷰하고30명·6개의 실제 생성 PNG와 원본 프롬프트를 저장했다. [컨셉 갤러리](../../../assets/concepts/2026-10-31-npc-cast-v1/index.html) · [서사/범위](../../production/npc-cast-and-story-coverage-2026-10-31.md). native 모델의 비블록 얼굴/블록 팔다리·소품·이름/역할을 로비와 Deepwood에 연결했다. 후반4에픽은 라이브러리/앵커 계약이며 실제 맵 배치는 미완료다. 이미지 품질과 native 원형의 완성도를 동일하게 보고하지 않는다.

## 검증

- `python3 tools/build-npc-catalog.py`:30명 안정ID·영문 이름/역할/대사·키를 JSON에서 생성. `python3 -m py_compile tools/build-npc-catalog.py tools/prepare-npc-preview.py` 성공.
- `lua tests/deepwood-progress.spec.lua`:570검사, `lua tests/selene-recruitment.spec.lua`:23검사, `lua tests/economy.spec.lua`:26검사 통과.
- `python3 tools/prepare-npc-preview.py` 후 전용 로컬 미게시Place를 Studio에서 검사. 초기3463검사는fixture의 TD환경 마운트 이름 누락으로 실패했고 이름/참조를 고쳐3479검사 통과.30명/1442Parts·6지역 키트·Deepwood15개배치·비충돌/비쿼리·시설/별칭/호위 피벗 확인. 후속 얼굴 메쉬/복장 수정 후 최종4,762검사·30명/1,682Parts·Deepwood15개배치 통과. [최종JSON](cast-result.json)·[입력해시](cast-source-manifest.json).
- `python3 tests/make_k0_source_probe.py --output-dir /tmp/tlt-npc-selene-qa --test-script tests/selene-support-native.luau` + `run-in-roblox --place /tmp/tlt-npc-selene-qa/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-npc-selene-qa/source-probe.luau`:30검사 통과. 실제 엔진/경로 이동/지원 서비스, Player·시계·계정은 대역. 무료영입·거리·회복/보호/정화·반복편성 쿨다운·1~4인 AI상한·영웅변경을 보존. 기존 원본203785492 타입 불일치 경고가 남는다.

## 고정 빌드와 최종 시작 검사

소스 `2ed79d2b482c115a88f444e566c8ac9fd7d84376`와 VERSION0.43.0을 커밋/원격 고정한 다음 `python3 docs/evidence/npc-cast-0430/build.py`로 두 산출물을 만들었다. Git archive에서 HEAD 입력을 고정하고 정본이 참조한 LFS 자산의 SHA256을 검증해 물질화했다. [명령/크기/해시/성공](build.json).

- [Lobby 0.43.0](../../../builds/0.43.0/TheLastThrone-Lobby-0.43.0.rbxlx): `run-in-roblox --place builds/0.43.0/TheLastThrone-Lobby-0.43.0.rbxlx --script tests/npc-bootstrap-native.luau` **97검사 통과**. [결과](lobby-bootstrap-result.json)·[로그](lobby-bootstrap.log).
- [Battle 0.43.0](../../../builds/0.43.0/TheLastThrone-Battle-0.43.0.rbxlx): 같은검사에Battle 경로 지정, **94검사 통과**. [결과](battle-bootstrap-result.json)·[로그](battle-bootstrap.log).
- 두 실제 산출물의 역할별 초기화,30종서버 템플릿, 대화Remote, Deepwood NPC15개, 로비6명+대장장이·기존서비스 입력 연결, 모든클라이언트/서버 모듈 컴파일을 확인했다. 실제 Player 입력·게시·저장 수용으로 해석하지 않는다. [검사 입력해시/조건](bootstrap-test-manifest.json).
- [최초 엔진 외형 검토](native-initial-lineup.png) 후 Sphere SpecialMesh와 복장 세부를 수정했다. [최종 근접 화면](native-final-closeup.png)은 실제 native 원형이며 생성된 컨셉 PNG와 완성도 차이를 확인할 수 있다.

원격main의 소스 커밋 일치와 LFS8/8·14MB 전송 성공, `git lfs fsck` 성공을 확인했다. 후속 증거 커밋은 위 소스 빌드의 입력을 바꾸지 않는다. Roblox 게시·릴리스 태그는 실행하지 않았다.

## 미검증과 다음 담당

최종 컨셉 일치 메시/텍스처·생활/보행모션·NPC대화의실제 터치/패드화면, 실제 계정거래/저장,1~4인/기기성능, 후반 맵 배치/상태별 구조·귀환 축제·정상 전투완주는 미완료다. 다음 ART/ENG는 최종 모델과 지역 앵커를 만들고 QA는 게시 테스트와 실제 기기에서 수용한다. 상위 티켓은 In Progress/후속 상태를 유지한다.
