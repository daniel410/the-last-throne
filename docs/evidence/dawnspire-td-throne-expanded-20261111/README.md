# TD 왕좌 원본·확장 로비 검증

2026-11-11 · TLT-001/028/031/050/052/057/084 · 0.100.2 · DES/ENG → QA

[설계/좌표/원본 계약](../../production/dawnspire-td-throne-expanded-2026-11-11.md) · [TD 출처/해시](../../../assets/shared/td-lobby-throne/provenance.json).

TD **로비 금색 왕좌**의 원본 기하 구간·뾰족 아치/왕관 도우미를 스냅숏해 기존 유리 의자를 교체했다. 좌석/등받이/방석·팔걸이/다리 비율을 보존하고, HG07 심장 받침은 의자 앞쪽에 분리했다. TD 전투의 분홍 수정 왕좌나 미게시 Blender 왕성 메시로 표시하지 않는다.

로비300×300·면적2.25배, 성벽/안전 경계/서버 허용 범위, 시설/주민/정원/중앙길을 함께 확장했다. Tessa 안내 지도는 공유300크기·실제 NPC 좌표를 사용하고 기존±50 제한을 제거한다. 메뉴/시설의 입력/서버 지급·진행/권리 계약은 유지한다.

## 예비 엔진

`python3 tools/prepare-dawnspire-throne-native.py --preview`로0.100.1 격리 호스트에 이번8모듈만 주입하고 `run-in-roblox --place builds/0.100.1/TheLastThrone-0.100.1.rbxlx --script /tmp/tlt-dawnspire-throne-native.luau` 실행.

- 실제 사이드 안내/지도/표식 UI **82 PASS**,800×510/726×299/270×510 문구·조작 영역 회귀. 확대 위치X130과 이동한 Tessa의 투영/핀 영역 검증 포함.
- 실제 왕좌/로비 **3,033 PASS**, **713 보행 표본**, 기본 월드391 BasePart.300지면/서버 크기·동서남북 새 영역과 경계·스폰→왕좌/시설 바닥/단차/신체 차단·TD 좌석/등받이·청색Fabric/금속·완료/미완료/선택 해제/불완전 저널·스트리밍 복원 확인. [로그](native-preview.log).
- Source 주입 예비 검증은 새 고정 빌드로 해석하지 않는다. 최종 입력 커밋과 고정 산출물 검증은 빌드 후 기록한다.

[실제 전경](overview.jpg) · [TD 원본 왕좌 배치](throne.jpg)는 최종 기하 소스를 적용한 로컬 편집 TLT 검토 화면이며 실계정 클라이언트 캡처가 아니다. ClockTime10/Brightness2/Ambient90,90,100 검토 조명을 사용했다. 실제 PC/터치/패드·20인/저사양 FPS·스토리 귀환·사용자 미술 수용/공개 게시·Teleport는 후속이다. TD 운영 소스/Place·DataStore/상품은 변경하지 않았다. 부모 티켓은 수용 전 미완료다.

## 고정 빌드·최종 마감

입력 `fc7ee80bfbe073c65a81b2666ef1c8d97d05acca`을 원격 main에 푸시한 뒤 `python3 tools/build-game.py --source fc7ee80b --record docs/evidence/dawnspire-td-throne-expanded-20261111/build.json`으로 **0.100.2 단일 빌드 성공**. 산출물 `builds/0.100.2/TheLastThrone-0.100.2.rbxlx`, SHA256 `63cbb416dfbf97abc08f4225498a35dcbd3eae53e6da23e05036ba9ce6eca207` 재확인. [빌드](build.json).

`python3 tools/prepare-dawnspire-throne-native.py` 후 `run-in-roblox --place builds/0.100.2/TheLastThrone-0.100.2.rbxlx --script /tmp/tlt-dawnspire-throne-native.luau`에서 **8모듈 Source 일치**, 사이드 UI82·왕좌/로비3,033, 총**3,115 PASS**. 보행713표본/바닥·경계·단차/신체 차단 검사가 최종 고정 아티팩트에서도 통과했다. [원본](native.log)·[결과](native-result.json).

`python3 tests/single-build.spec.py --artifact builds/0.100.2/TheLastThrone-0.100.2.rbxlx`: 역할10·로딩192/실제 산출물 계약 PASS. 기존 귀환27·사이드539·줄거리1,034/405저장 전이 PASS, 퀘스트 탭 정적 검사 PASS. `git diff --check` PASS. TD 원본3파일과 런타임 스냅숏 해시를 다시 대조했다.

화면2개 LFS 포인터와 전송2/2(약818KB) 성공을 확인했다. [화면 해시](captures.json). 코드/기록은 main에 선별 커밋·푸시한다. 일반 로컬 빌드이므로 릴리스 태그/Roblox 게시 없음. 실제 기기·개인 진행 혼합 클라이언트·미술 수용은 QA 후속이다. 사용자의 기존 애니메이션 수정/이미지 삭제/첨부 파일은 보존했다.
