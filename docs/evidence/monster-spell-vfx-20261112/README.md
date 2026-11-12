# 몬스터별 마법 공격 VFX

2026-11-12 · TLT-005/027/032/033/057/061~065/084 · ENG/DES → QA · 로컬 구현·미게시, 부모 티켓 In Progress

## 변경

같은 마법 구체를 재사용하던 발사체·시전 응집을 **50종의 고유 모티프/장식 조합·35모티프**로 분리했다. 기존146공격 중40개 투사체 공격을 포함하며 공격 번호별 장식 배치와 일부 기술별 형상도 분리한다. 예를 들어 샤먼의 부적/왕의 토템, 얼음 엘프의 결정창/여왕의 프리즘/트롤의 얼음 바위, 임프의 불씨/화산 샤먼의 불길/타이탄의 불붙은 바위, 거미 실 그물/여왕 독알·실 부채, 리치 영혼 가면/군주의 봉인/Veyr 균열이다. 물리 투척도 칼·뼈·바위로 구분한다.

시전 응집→발사 섬광→종별 회전·Trail→접촉 소멸, 광역 공격의 얼음 기둥/화염 분출/실 격자/독 튀김/룬/뿌리/잔해를 연결했다. 기존 PixelFX 자산20종의 원소 보조 장식을 재사용하며 새 자산 업로드는 없다. 고리 안전지대는 비워 두고 미도착 바닥에는 분출을 만들지 않는다. 새3D 효과는 파트640/동시64묶음·거리100stud, 기존 투사체48개/PixelFX24개 예산을 유지한다. 피해/속도/판정/공격 빈도·상태 이상은 기존 서버 정의를 따른다. 서버 메시지는 공격ID와 명중한 영웅 위치를 포함해 접촉 VFX가 비행 끝에 어긋나지 않도록 했다.

[조사·선택과 미검증 지표](../../research/2026-11-12-monster-spell-vfx.md). 정본 구현은 `EnemySpellProfiles`·`EnemySpellVFX`·`EnemyPatternEffects`다.

## 시각 표본

같은12종/위치의 기존 구체를 재현한 비교와 새 프로덕션 생성기의 실제 Studio 기하를 고정한 표본이다. 실제 전투/캐릭터/최종 미술 수용 화면이 아니다. 캡처 전송량 때문에4bit RGB로 양자화했으며 실제 색 재현 평가 자료로 쓰지 않는다.

![기존 공통 구체 표본](before.png)
![몬스터별 마법 형상 표본](after.png)

재현: `python3 tools/prepare-monster-spell-vfx-native.py --capture --output /tmp/tlt-monster-spell-capture`가 출력하는 명령. 격리 PlaceId0에서만 실행하며 계정/저장 서비스를 시작하지 않는다.

## 검증·수용 경계

초기 fixture 준비에서 Client 폴더 클래스 누락으로 Rojo가 거부한 것을 `$className: Folder`로 보완했다. 제품 런타임 실패와 구분한다.

미검증: Roblox 게시 클라이언트·실제 전투의 시전/비행/명중 영상, PC/터치/패드와 작은 화면, 다인·4인+AI의 FPS/투명 효과 비용, 효과 다운로드 권한, 사용자 최종 가독성/자연스러움 수용. 다음 QA는 같은 속성의 서로 다른 몬스터를 정상 전투에서 비교하고 위험 예고/영웅이 장식에 가려지지 않는지 확인한다. 게시·릴리스 태그는 만들지 않는다.

## 최종 검증·빌드

게임 **0.104.10**, 입력 커밋 `866be80457ee49e2d9fc12086fc252ccd6dc6e88`. `python3 tools/build-game.py --source 866be804 --record docs/evidence/monster-spell-vfx-20261112/build.json` 성공. [빌드 경로·SHA-256](build.json), [실제 입력 해시](inputs.json). 소스는 origin/main에 푸시했으며 이미지2개는 LFS 포인터/전송을 확인했다. 캡처 도구의 배경/라벨 가독성 수정과 증거 마감은 별도 커밋이며 게임 런타임 바이트는 이 고정 빌드와 같다.

| 검사 | 결과·범위 |
| --- | --- |
| `tests/monster-spell-vfx-native.luau` | 실제 현재 모듈/Instance **57,004 PASS**. 50종의 조합 중복 없음·146공격의 시전/펄스/접촉·40투사체의 형상/잔상/직선 이동·비충돌/유한 좌표·고리 안전지대·자동 정리·죽음/새 행동/스트리밍·예산/발사체 우선·실제 이벤트 중복/지연/취소/종료 후 부활 방지 |
| `tools/assemble-enemy-pattern-test.py` → 기존 격리 패턴 검사 | **218,889 PASS**. 기존146공격 피해 예산·벽/사거리/원정·펄스별 중복·지연/취소·명중 위치·기존 모션 접촉 시점/연속성·위험 예고/바닥 스트리밍 회귀 |
| 위 두 묶음을0.104.10에서 실행 | [최종 엔진 로그](final-native.log). 합계275,893 PASS. 새 생성기/이벤트는 실제 빌드 모듈을 require하며 기존 패턴 번들은 현재 소스를 포함한다 |
| `tools/assemble-enemy-pattern-service-test.py` →0.104.10 | 실제 서버 본문·합성 신원/시계 **72 PASS/23사례**. 네 클래스·벽·구/신 원정·회피/블록/흡수/ForceField·취소/바닥 위험 보존. [서버 로그](service-native.log) |
| `lua tests/enemy-patterns.spec.lua` / `deepwood-bosses.spec.lua` / `boss-pressure-boost.spec.lua` | **3,717 / 96 / 392,158 PASS**. 기존 서버 정의·보스 단계·수치·보상 보존. [원본](lua-results.json) |

고정 빌드 엔진 합계 **275,965 PASS**, CLI 종료0. 기존 Gloamwood MeshPart의 ContentId 다운로드 경고가 있어서 이를 메시/텍스처 권한 수용으로 간주하지 않는다. 효과 이미지는 기존 승인ID를 사용하지만 실제 게시 클라이언트의 다운로드/가독성 수용은 여전히 별도다. 다음 담당 QA와 남은 범위는 위 수용 경계를 따른다.

재현: `python3 tools/prepare-monster-spell-vfx-native.py`가 출력하는 명령으로 효과 전용 fixture를 검사한다. 고정 빌드는 해당 `.rbxlx`를 `run-in-roblox --place`에 지정하고 `tests/monster-spell-vfx-native.luau`를 실행한다. 기존 패턴은 `tools/assemble-enemy-pattern-test.py`, 서버 회귀는 `tools/assemble-enemy-pattern-service-test.py`가 출력하는 `/tmp` 스크립트를 사용한다. 모두 실제 계정 없는 PlaceId0에서 실행한다.
