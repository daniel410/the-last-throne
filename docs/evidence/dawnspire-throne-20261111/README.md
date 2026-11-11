# Dawnspire 왕좌·새 로비 구현 검증

2026-11-11 · TLT-001/028/031/050/052/057/084 · 0.100.0 · DES/ENG → QA

[디자인/공간/계약](../../production/dawnspire-throne-lobby-2026-11-11.md) · [공식 사례 조사](../../research/2026-11-11-dawnspire-throne-lobby.md).

상시 북쪽 수정 왕좌/빈 받침, 중앙길/금색 광장, 외곽 정원과 쌍탑/성소 아치, 기존 완료 전용 남쪽 왕좌를 같은 왕좌의 개인 심장 복원으로 교체했다. HG07 완료는 기존 서버 영웅 스냅숏에서 읽으며 새 저장·보상·유료 권리를 만들지 않는다. 기존 로비 메뉴/시설 좌표/프롬프트와 서버 진입을 유지한다.

## 검증

- 예비 격리 편집 엔진: 기존 고정0.99.2 아티팩트를 호스트로 이번4모듈 Source만 주입해 실제 `tests/dawnspire-throne-native.luau` 실행. **1,873 PASS**, 기본 월드307 BasePart,360개 보행 표본. 실제 월드·시설·대장간·상점·창고·주민·개인 장면/확장/분위기 모듈을 실행했다. [로그](native-preview.log). 이 예비 호스트를0.100.0 고정 빌드로 보고하지 않는다.
- 바닥/단차/신체 차단, 전체 Luau 문법, 월드 생성 재요청, HG07 완료/미완료 영웅 전환·선택 해제·불완전 저널·스냅숏 선도착/로비 재유입을 검사했다. 개인 장면은 충돌/터치/질의를 갖지 않는다.
- `lua tests/lobby-return-hero.spec.lua`:27 PASS.
- `lua tests/campaign-context-review.spec.lua`:1,034 PASS,405개 저장 전이/47개 이야기 계약 유지.
- `lua tests/lobby-side-quests.spec.lua`:539 PASS.
- `python3 tests/lobby-quest-tabs.spec.py`:PASS. `git diff --check`:PASS.

## 범위와 후속

엔진의 로컬 스냅숏 입력은 실제 네트워크 영웅 전송/계정 저장·게시된 Teleport의 검증이 아니다. 실제 PC/터치/패드·20인 저사양 FPS, 혼합 진행 영웅의 실제 클라이언트, 도난/복원 이해도·최종 미술 사용자 수용은 QA 후속이다. 부모 티켓은 미완료 유지. TD 프로젝트/라이브 DataStore·실상품·Roblox 게시는 변경하지 않는다. 새 로컬 빌드와 Git 푸시 상태는 마감 기록을 추가한다.
