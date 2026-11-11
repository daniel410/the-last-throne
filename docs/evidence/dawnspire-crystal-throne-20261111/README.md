# TD 크리스탈 왕좌 원본 교정

2026-11-11 · TLT-001/028/031/050/052/057/084 · 0.100.3 · DES/ENG → QA

사용자가 TD 왕좌는 크리스탈이라고 명확히 정정했다.0.100.2의 금색 로비 의자 선택은 잘못된 해석이었다. 금색 의자/현재 런타임 모듈을 제거하고 **TD 전투 맵의 분홍 크리스탈 왕좌**로 교체했다.300×300 지면·시설/주민 배치·서버/안전 경계·지도는 그대로다.

[실제 교정 화면](throne.jpg) · [원본/해시](../../../assets/shared/td-crystal-throne/provenance.json) · [추출 도구](../../../tools/snapshot-td-crystal-throne.py).

## 구현

`VisualFactoryMap.lua`의 `ornament/facing/crystal/buildThrone`을 그대로 스냅숏한다. 분홍 RGB224/66/160, 연분홍 RGB249/124/204,5개 첨탑형 수정 등받이·4개 주변 수정 조각·좌석/팔걸이·석재 계단·천/금색 장식·원본 빛/입자를 재사용한다. Roblox 기본 Part 생성기만 순수 어댑터로 둔다. 모델 원점을 고정하고 **전체를 균일2배 확대·평행이동**한다. 색이나 의자 형태를 별도 재설계하지 않는다.

RPG 지면은 기존 성소 단상이 담당한다. TD 원본 장식은 원래처럼 충돌/질의/터치가 없으며 앞쪽 관찰 동선까지 보행을 검사한다. 바깥 성소 아치는 크리스탈 높이에 맞춰 낮춘다. 앞쪽 별도 심장 받침·HG07 완료 영웅만 표시되는 개인 심장/빛, 미완료/선택 해제/재유입 처리는 유지한다. 진행/보상/저장·지원권은 변경하지 않는다.

## 예비 검증

`python3 tools/prepare-dawnspire-throne-native.py --preview` 후0.100.2 격리 호스트에서 검사: **사이드 안내82·왕좌/월드3,074 PASS**, **705 보행 표본**, 기본 월드454 Part. 분홍/연분홍 원본색·균일 배율·좌석 비율·뾰족 수정/주변 조각·금색 의자 부재와 기존300크기/경계·시설 접근/영웅별 복원 회귀를 검사했다. [로그](native-preview.log).

이미지는 최종 기하 소스를 주입한 격리 TLT 편집 화면, 검토 조명 ClockTime10/Brightness2/Ambient90,90,100이다. 실계정/실제 클라이언트/기기·20인 FPS·사용자 미술 수용과 게시 검증은 후속이다. TD 프로젝트는 읽기 전용이며 새 메시/텍스처 업로드·Place 게시·릴리스 태그는 수행하지 않는다. 고정 빌드/최종 결과는 아래에 추가한다.

## 최종 고정 빌드

**0.100.3 성공**, 입력 `06104729c9251fa43087e01c14772ae33abe1628`을 main에 푸시한 후 단일 Place 생성. [빌드](build.json). 산출물 `builds/0.100.3/TheLastThrone-0.100.3.rbxlx`, SHA256 `9fec2100bacc59946beb7538b07fded7bd850567b09fb09f2a1e6be48c2edc83` 별도 재확인.

`python3 tools/prepare-dawnspire-throne-native.py` 후 `run-in-roblox --place builds/0.100.3/TheLastThrone-0.100.3.rbxlx --script /tmp/tlt-dawnspire-throne-native.luau`:8모듈 Source 일치, **사이드 UI82·왕좌/월드3,073, 총3,155 PASS**,705 보행 표본. 예비 호스트에는 남아 있던 금색 소스 모듈이 최종 산출물에서는 제거돼 문법 검사 수가1개 줄었다. [원본](native.log)·[결과](native-result.json).

`python3 tests/single-build.spec.py --artifact builds/0.100.3/TheLastThrone-0.100.3.rbxlx`: 역할10/도착 로딩192·실제 산출물 계약 PASS. `git diff --check` PASS. 이미지 LFS 포인터와 전송1/1(약465KB) 성공 확인. [화면 해시](captures.json). 코드/증거 main 커밋·푸시, 일반 빌드로 릴리스 태그/Roblox 게시 없음. 최종 미술/실기기·계정 수용은 QA 후속이다.
