# Hollowbark Sovereign 본체 소실 수정

작업: TLT-065/032/033/057/084 후속 · 2026-11-16 America/Toronto(UTC 11-17) · ENG → QA · 소스·고정 빌드 엔진 검사 완료, 미게시.

사용자가 GW-06 마지막 후위 전투에서 체력바만 보이고 본체가 보이지 않는 화면을 제보했다. TD 원본을 그대로 복사한 `HollowbarkSovereignTemplate`은 `VisualRoot`와 스킨 `Body` 사이의 내부 용접이 없다. 다른 Gloamwood 8종에는 이 연결이 있다. `GloamwoodAppearance.attach`는 모든 파트의 Anchored를 해제하면서 VisualRoot만 게임플레이 루트에 연결했으므로, Sovereign의 본체만 중력으로 바닥을 통과해 떨어졌다. 실제 TLT Studio(배틀 Place 129388473517823 / Experience 10773575153)에서 메시105839711981589와 텍스처139387289433234의 PreloadAsync는 모두 Success였으며, HasSkinnedMesh=true와 내부 용접0개를 확인했다.

## 변경

`src/server/World/GloamwoodAppearance.luau`에서 활성 Body↔VisualRoot 용접을 확인하고 누락된 경우에만 복제본에 `GloamwoodBodyWeld`를 만든다. 기존 8종의 용접은 중복 생성하지 않는다. TD 원본 XML/GLB·메시/텍스처·스킨·10본·12stud 배율·서버 이동/피해/보상은 보존한다. 기존 사용자 작업과 다른 세션에서 변경 중인 원정 소스는 커밋·빌드 입력에서 제외했다.

## 재현·검증

계정·저장·원정 시작 스크립트를 끈 격리 Place에서 `tests/gloamwood-visual-attachment-native.luau`를 실행했다. 실제 엔진 중력 아래 0.75초 대기한 뒤, 루트를 이동·회전하고 0.5초 후 상대 위치·각도를 측정한다. Gloamwood 9종×3배율, 각10클립×3위상의 실제 Bone Transform을 함께 확인한다. Sovereign 중앙 배율은 승인된12/14다.

```text
run-in-roblox --place builds/0.111.31/TheLastThrone-0.111.31.rbxlx --script tests/gloamwood-visual-attachment-native.luau
run-in-roblox --place builds/0.111.32/TheLastThrone-0.111.32.rbxlx --script tests/gloamwood-visual-attachment-native.luau
```

- [수정 전](before-native.log): 기대한 회귀 실패. 첫 Sovereign(0.6배)은 용접1개이며 중력 대기 후 본체가 루트에서64.0715stud 이탈했다.
- [수정 후](after-native.log): **11,556검사 PASS**. 27개 모두 중력 후 오차0, 용접 정확히2개, 단일 연결 assembly. 이동·회전 후 최대 위치 오차 약0.000002stud. Sovereign의 승인 크기12stud 유지.
- [기존 검사](checks.log): 보스12,687검사, TD 원본 해시·스킨·10본·프로젝트 연결, 기존23종 크기 회귀 PASS.
- [측정·입력 해시](results.json): 수정 전후 산출물·소스/검사 해시, 수정 빌드에 포함된 모듈과 커밋 소스의 일치 확인.

한 차례 run-in-roblox가 Studio 연결 시간 초과로 시작하지 못해 재시도했다. 위 전후 로그는 실제 실행 결과다. PlaceId0 격리 실행에서 일부 기존 자산 해시 로드 경고가 있었으며, 이를 게시 클라이언트의 자산 표시 수용으로 취급하지 않는다.

## 빌드·인계

[빌드 기록](build.json): `0.111.32`, 입력 소스 `433799e0f5d985e9f0ea95353bea792c39a9d322`, 단일 산출물 `builds/0.111.32/TheLastThrone-0.111.32.rbxlx`. 소스 커밋의 origin/main 푸시·원격 일치를 확인한 뒤 해당 커밋에서 빌드했다. 생성 산출물은 Git에 추가하지 않는다.

미검증: GW-06 정상 플레이 입력·전투 전체 흐름·실제 클라이언트 스킨 표면/스트리밍·모바일·1~4인·사용자 수용. Roblox 게시·릴리스 태그는 수행하지 않았다. 상위 티켓과 G5/G7 완료 상태는 변경하지 않는다.

다음 담당: 게시 담당은 검증된0.111.32 산출물을 로비/배틀에 적용하고, QA/사용자는 새 서버의 GW-06 마지막 후위 전투에서 본체 표시·추격·공격·처치 진행을 확인한다.
