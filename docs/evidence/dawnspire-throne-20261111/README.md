# Dawnspire 왕좌·새 로비 구현 검증

2026-11-11 · TLT-001/028/031/050/052/057/084 · 0.100.1 · DES/ENG → QA

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

## 실제 화면 검토와 버전 이력

0.100.0 입력 `1c2436838b230f370333c9cb82e121c08833d8ac`을 origin/main에 푸시한 후 단일 빌드를 생성했다. [빌드](build-0.100.0.json)·[고정 아티팩트 엔진1,873 PASS](native-0.100.0.log). 실제 산출물의 단일 빌드/역할10·로딩192 검사도 PASS했다.

로컬 TLT0.100.0을 별도 Studio로 열어 같은 네이티브 검증기를 실행하고 실제 뷰포트를 확인했다. 첫 심장 모양이 갈라져 보여0.100.1에서 여덟 결정 면의 위치를 맞춰 단일 양뿔 결정으로 수정했다. [전경](overview.jpg)·[미완료 왕좌](missing.jpg)·[완료 왕좌](restored.jpg)는 이 최종 표시 코드를 적용한 격리 편집 화면이다. 실제 플레이/저장 검증 캡처로 해석하지 않는다. 조명은 로컬 검토 ClockTime10/Brightness2/Ambient90,90,100이며 게임의 로비 분위기 프로필과 구분한다. TD 프로젝트는 수정하지 않았다.

0.100.1의 입력 커밋·빌드 해시·최종 엔진 검증은 마감 후 아래에 추가한다. 일반 로컬 빌드이므로 릴리스 태그/Roblox 게시를 수행하지 않는다.

## 최종 마감

**0.100.1 성공**, 입력 소스 `c1545aeb82ca58a7b324b2bb4e4528240fb941f2` 원격 main 반영 후 `python3 tools/build-game.py --source c1545aeb --record docs/evidence/dawnspire-throne-20261111/build.json` 실행. 산출물 `builds/0.100.1/TheLastThrone-0.100.1.rbxlx`, SHA256 `e3de51b0369b582ce60aea2a27c6a582dd6a05530720f264bc79ab8bdd6c3002` 재확인. [빌드](build.json).

`run-in-roblox --place builds/0.100.1/TheLastThrone-0.100.1.rbxlx --script tests/dawnspire-throne-native.luau`: 최종 고정 아티팩트에서 **1,873 PASS /360 보행 표본**, 기본 월드307 Part. [원본](native.log)·[결과](native-result.json). `python3 tests/single-build.spec.py --artifact builds/0.100.1/TheLastThrone-0.100.1.rbxlx`: 역할10·도착 로딩192·실제 프로젝트/산출물 계약 PASS. 이전 예비 결과와 최종 고정 빌드 결과가 같다.

화면3개의 LFS 포인터를 확인하고 원격 전송3/3 성공(약1.3MB)을 확인했다. [화면 해시/조건](captures.json). 코드/설계/검증은 Git main에 커밋·푸시하며 일반 빌드이므로 태그와 Roblox 게시 없음. 기존 미커밋 애니메이션/컨셉 삭제/첨부 파일은 작업에 포함하지 않았다. 다음 담당은 QA의 실제 클라이언트/기기·혼합 진행/사용자 미술 수용이다.
