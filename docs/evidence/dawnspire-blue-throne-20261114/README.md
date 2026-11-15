# TD 최신 파란 크리스탈 왕좌 동기화

2026-11-14 · TLT-028/031/050/057/084 일부 · 환경 아트/환경 모델링/맵 구현/ENG → QA

## 변경 범위와 원천

사용자 지시로 TD 최신 `src/Server/VisualFactoryMap.lua`의 왕좌를 [기존 추출 도구](../../../tools/snapshot-td-crystal-throne.py)로 그대로 스냅숏했다. 신규 미술 설계나 게임성 변경이 아닌 지정 공유 자산 동기화이므로 별도 게임성 리서치는 하지 않았다. 열린 TD Studio `ThroneDefense-8.10.3.rbxlx`의 `ServerScriptService.GameServer.VisualFactoryMap`에서도 같은 파란 `crystal/buildThrone` 소스를 읽어 확인했다. TD 소스 파일은 미커밋 수정 상태이므로 커밋만을 원본으로 주장하지 않고 [출처 파일 해시·스냅숏 해시](../../../assets/shared/td-crystal-throne/provenance.json)를 고정했다. TD 파일/운영/게시에는 쓰지 않았다.

- 원본 분류: Reuse. 본체 RGB42/108/218, 좌석·주변 수정·입자 RGB113/193/250, 수정 면 RGB158/221/255, 테두리 RGB200/237/255와 원본 수정 끝 보간을 함께 재사용한다.
- 서사/배치: Dawnspire 북쪽 수호 왕좌를 기존 피벗에서 균일2배로 유지한다.300×300 로비와 보행·시설·아치·심장 받침은 변경하지 않는다. 심장 도난/복원 상태는 기존 HG07 서버 확인 영웅별 투영을 유지한다.
- 산출물: `TDCrystalThroneGeometry.luau`, 원본/해시 메타데이터, 색상·조명·입자 회귀 검사, 현재 계약/결정. 기존 사용자 자산 삭제/Blender 변경은 스테이징하지 않는다.

## 검증

예비 격리 호스트0.107.5에 후보 모듈을 주입해 사이드 안내82·왕좌/월드3,131검사, 보행705표본 PASS. 최종 고정 빌드 결과는 아래에 기록한다.

게시 클라이언트·실계정·실기기/다인 성능·사용자 미술 수용은 미검증이며 상위 티켓/G5/G7 완료를 주장하지 않는다. 다음 담당 QA/사용자: 고정 빌드의 실제 로비에서 색/가독성·기기·개인 복원 수용. Roblox 게시·릴리스 태그는 생성하지 않는다.

## 고정 빌드 결과

- **0.107.6 성공**. 입력 소스 `888f149c46d84b09e5c081e8a43ccf34bb5d835e`를 main에 푸시한 뒤 단일 Place를 생성했다. [빌드/산출물 경로·SHA256](build.json).
- `python3 tools/prepare-dawnspire-throne-native.py`로8개 모듈의 실제 빌드 Source 일치를 확인하고, `run-in-roblox --place builds/0.107.6/TheLastThrone-0.107.6.rbxlx --script /tmp/tlt-dawnspire-throne-native.luau` 실행: **사이드 안내82·왕좌/월드3,135 PASS**, 보행705표본, 월드454 Part. 본체/좌석/수정 면/테두리/빛/입자 파랑·균일2배·시설 접근·HG07 복원·영웅 변경·중복 갱신·스트리밍 재유입을 검사했다. [원본 로그](native.log)·[구조화 결과](native-result.json).
- `python3 tests/single-build.spec.py --artifact builds/0.107.6/TheLastThrone-0.107.6.rbxlx`: 역할10·도착 로딩283검사 및 실제 산출물 계약 PASS. 원본 함수 추출 동일성·파일/스냅숏 해시 일치·`git diff --check` PASS.
- [실제 파란 왕좌 화면](blue-throne.png)·[화면 해시/조건](captures.json): 고정 빌드의 격리 Studio Edit에서 기존 테스트의 카메라와 ClockTime10/Brightness2/Ambient90,90,100 사용. 캐릭터가 조작하는 실제 게시 클라이언트 화면으로 간주하지 않는다. 개인 심장 복원은 완료 영웅 스냅숏을 주입한 검증이다.

소스/증거는 main에 커밋·푸시한다. TD 원본 파일은 읽기만 했고 TLT의 기존 미커밋 사용자 자산은 보존했다. 다음 담당과 미검증 범위는 위 QA 인계를 따른다.
