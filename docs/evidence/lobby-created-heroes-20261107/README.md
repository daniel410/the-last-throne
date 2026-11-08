# 로비 생성 영웅만 표시 · 0.82.6

2026-11-07 · TLT-028/057/084 · ENG/QA → QA · 사용자 지시 구현·미게시.

로비 PLAY 아래 빠른 선택이 소유 영웅 목록과 관계없이 네 클래스 카드를 모두 표시해 미생성 영웅과 혼동되던 문제를 수정했다. 서버가 전달한 `state.heroes`에 있는 클래스만 표시하고 입력/포커스를 허용한다. 로딩/빈 목록은 모든 영웅 아이콘과 HEROES 소제목을 숨긴다. 목록 갱신 때 새 영웅을 즉시 반영하며 표시된 카드만 클래스 순서로 빈칸 없이 가운데 정렬한다.

TD 원본 카드/초상/선택 표시·PLAY/경험치 영역의 크기와 위치, 별도 Heroes 생성 화면, 서버 소유권/생성/선택 경로는 유지한다. 명확한 UI 결함 수정으로 별도 사례 조사는 생략했다. 변경 범위는 `LobbyHeroDock`과 기존 네이티브 검사·버전·관련 기록이다. 기존 Blender 변경·컨셉 삭제·첨부/다른 증거는 포함하지 않는다.

## 검증

`run-in-roblox --place builds/0.82.5/TheLastThrone-0.82.5.rbxlx --script /tmp/tlt-created-heroes-native.luau`로 기존 로컬 산출물에 변경 모듈 소스만 주입하고 `tests/lobby-hero-dock-native.luau`를 실행했다. [로그](native.log). 검사는 로딩·Knight/Mage만 소유·선택/XP·stale snapshot·busy·패널 차단·전투 역할·단계 숨김과 16가지 소유 조합 × 4개 화면(1920×1080/1280×720/844×390/390×844)의 표시/입력/가운데 정렬/간격을 포함한다. 1/3명 가운데 정렬은 엔진의 정수 픽셀 반올림을 고려해 좌우 여백 차이1px 이내를 허용한다. 기존203785492 자산 유형 경고는 렌더 수용과 구분한다.

검증 소스는 아래 빌드 입력 커밋에 고정하며 단일 빌드 결과/해시는 `build.json`에 기록한다. 실제 계정/게시 클라이언트·실기기 터치/패드·시각 수용은 미검증이다. 다음 QA는 기존 계정의 영웅 수에 맞는 아이콘과 Heroes에서 생성 후 빠른 선택 즉시 반영을 확인한다. 부모 티켓 In Progress 유지, Roblox 게시/릴리스 태그 없음.

결과: 네이티브 **524검사 PASS**, `git diff --cached --check` PASS. 입력 `3e59a72967847ec653027ee882b3d02ffdd22ef9`를 커밋/푸시한 뒤 `python3 tools/build-game.py --source 3e59a72 --record docs/evidence/lobby-created-heroes-20261107/build.json` 성공. `python3 tests/single-build.spec.py --artifact builds/0.82.6/TheLastThrone-0.82.6.rbxlx` 통과. [산출물 모듈 대조](artifact-check.json)에서 검증/고정 소스와 바이트 일치를 확인했다.
