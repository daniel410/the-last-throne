# 보스 피격 효과·몬스터 공격 동작

2026-11-12 · TLT-005/027/032/033/057/084 · ENG → QA · 로컬 구현, 미게시, 부모 티켓 In Progress

사용자 요청에 따라 보스가 영웅을 실제로 명중시켰을 때 몸에 붙는 속성별 효과를 추가했다. 물리 베기·불꽃·얼음 결정·독 방울·실 가닥·영혼/그림자/비전 표식을 0.55초 안에 제거하며 대상당1묶음·전체12묶음·묶음당 최대5파트로 제한한다. 보스 접점 섬광은 일반 적보다1.55배다. 기존 서버 확정 이벤트·공격/펄스/대상 중복 제거·거리 제한을 사용하며 회피/무효/흡수/방어는 기존 결과 표현을 따른다. 새 상태 이상·지속 피해는 없다.

공격 동작은 서버 시계의 각 타격에 클립 접촉 자세0.62를 맞춘다. 준비→접촉→후속 동작→다음 준비→회수를 연속 보간해 연타의 순간 되감기를 없앤다. 시전은 마지막 발사 후 자세를 유지한다. Gloamwood 스킨에도 기존 공격 종류별 몸 강조를 원본 Root 좌표계에 변환해 적용한다. TD 원본 메시·클립·서버 이동/피해/공격 속도는 유지한다. [조사·선택 근거](../../research/2026-11-12-boss-impact-motion.md).

최초 격리 Place는 Gloamwood 템플릿이 없어 모델 검사에서 중단됐다([원본](native-missing-template.log)). 실제 템플릿을 포함한 별도 fixture로 재실행했다. 테스트는 계정/저장/정상 플레이/실기기 수용을 대신하지 않는다.

미검증: 게시 클라이언트, 정상 입력의 실제 전투 영상, PC/터치/패드, 4인+AI 성능, 사용자 최종 자연스러움/미술 수용. 다음 담당 QA는 고정 빌드의 보스 속성별 명중·회피·블록과 연타·시전·스턴 복귀를 실제 전투에서 확인한다. Roblox 게시·릴리스 태그는 만들지 않는다.

## 검증 결과

| 검증 | 결과·범위 |
| --- | --- |
| `lua tests/enemy-patterns.spec.lua` | 3,717 PASS. 50종/23보스, 형상 경계·구/신 원정 능력치·보상 보존 |
| `lua tests/deepwood-bosses.spec.lua` / `boss-pressure-boost.spec.lua` | 96 / 392,158 PASS. 기존 보스 단계·수치 회귀. [원본](lua-results.json) |
| `python3 tools/assemble-enemy-pattern-test.py` → 격리 엔진 | 최종218,884 PASS. 146공격 전체 펄스 접촉 시점·30/60/144Hz 위상 연속성·효과8속성/중복/지연/방어/회피/정리·비충돌·실제 대상 weld. 초기 테스트 통과는 [native.log](native.log), 최종 고정 빌드는 [final-native.log](final-native.log) |
| `tests/enemy-attack-motion-native.luau` → 고정 빌드 엔진 | 446,523 PASS. 실제50종 리그/146공격을30/60/144Hz로 샘플링, Root/Motor/Bone 유한 변환·루트/HP 보존·중단/스킨 복귀. [최종 로그](final-native.log) |
| `tools/assemble-enemy-pattern-service-test.py` → 고정 빌드 엔진 | 72 PASS/23사례. 실제 서버 본문·합성 신원/시계로 벽/타원정/4클래스/블록/흡수/회피/ForceField/취소 회귀. [로그](service-native.log). 실제 네트워크 검증 아님 |
| Studio 캡처 | 아래8속성 모티프를 실제 Part/Weld로 생성해 고정 복제한 접촉 표본. 뒤쪽 카메라에서 물리/거미줄이 몸에 가려지던 것을 앞뒤 교차선으로 보완했다. 실제 영웅·전투 영상/미술 수용은 아님 |

최종 고정 빌드의 엔진 합계는 **665,479검사 통과**다. 일부 기존 MeshPart ContentId의 콘텐츠 로딩 경고가 발생했으므로 메시/텍스처 다운로드 성공은 이 결과로 수용하지 않는다. 서버 서비스 검사는 PASS 후 Studio 내장 Toolbox/MaterialPicker React 오류를 출력했지만 CLI 종료0이었다. 게임 검사 실패와 구분한다. [소스·테스트 입력 해시](inputs.json).

![보스 피격 속성별 Studio 기하 표본](contact-preview.png)

## 빌드·마감

최종 **0.104.9**, 입력 커밋 `11dff28c3f067f4359f8be62557b0fc71e8164c0`. `python3 tools/build-game.py --source 11dff28c --record docs/evidence/boss-impact-motion-20261112/build.json` 성공. [산출물 경로·SHA-256](build.json). 소스는 origin/main에 푸시했다.

먼저0.104.8을 빌드/리그 검증한 뒤 카메라 뒤쪽 가림을 보완해0.104.9로 다시 고정했다. 기존 바이트는 덮어쓰지 않았다. [0.104.8 빌드](build-0.104.8.json)·[당시 리그 검사](motion-0.104.8.log)는 전 단계 증거다. 최신665,479검사는0.104.9에서 재실행했다. 문서 마감 커밋은 빌드 입력 커밋과 구분한다.
