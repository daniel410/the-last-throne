# 스킬 아이콘 다운로드 실패 시 표시

2026-11-20 · TLT-057/059 · ENG 수정 및 Studio 검증 · 로컬 빌드 0.115.9

Studio Edit의 배틀 문서에서 128개 등록 ID를 동시에 렌더링했을 때 Gliding Shot, Warden Arrow, Flame Dart, Ember Step, Eternal Tempest가 `HttpError: NetFail`로 로드되지 않았다. 별도 Studio 문서에서는 동일 ID 128개가 모두 로드됐다. 기존 검사는 ID가 등록돼 있으면 이미지가 표시된 것으로 처리해 다운로드에 실패하면 슬롯이 비어 보였다. [Studio 전후 결과](studio-loading.json) · [이전 로딩 실패 기록](../hero-skill-icons-20261115/README.md).

공통 렌더러가 원본을 요청하는 동안 스킬 약칭을 표시하고 이미지가 준비되면 약칭을 숨긴다. 다운로드 실패나 미등록 시에는 약칭을 계속 표시한다. 트리·상세·장착 슬롯·전투 HUD·궁극기가 이 경로를 사용한다. 실제 `IsLoaded`가 바뀌어도 속성 이벤트가 발생하지 않는 경우를 Studio에서 재현해 대기 중인 이미지를 한 번에 확인한다. [런타임](../../../src/client/SkillIcon.luau).

- Studio GUI 회귀 2,240개 통과. 클래스 4개와 계열 8개, 트리 24조건과 HUD 28조건에서 기존 ID 연결을 검증했다. 강제 다운로드 실패와 미등록 ID, 로딩 완료 후 자동 전환, 잠금·쿨다운·슬롯 비우기, 상세·장착·궁극기 약칭을 포함한다. `python3 tools/prepare-hero-skill-icon-review.py`로 실행문을 생성해 격리된 Studio에서 실행했다. [회귀 코드](../../../tests/hero-skill-icons-native.luau) · [결과](native.json).
- 기존 두 Studio 문서에 수정 렌더러를 임시 적용해 각각 원본 128개 표시, 빈 슬롯 0개, 원본과 약칭 겹침 0개를 확인했다. 당시 CDN 로딩이 정상으로 돌아온 상태였다. [전후 결과](studio-loading.json).
- 원격 소스 커밋 `ebb32627`에서 단일 로컬 Place 0.115.9를 빌드했다. 새 Studio 문서에서 빌드에 내장된 스킬 정의와 렌더러를 직접 불러와 128개 원본 표시와 빈 슬롯 0개를 확인했다. [빌드 기록](build.json) · [고정 빌드의 이미지 로드 결과](pinned.json).

게시 클라이언트와 실기기 검증은 미실행이다. 다음 담당은 QA이며 게시 테스트에서 첫 스킬 메뉴 진입과 전투 장착 변경 시 표시를 확인한다.
