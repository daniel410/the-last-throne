# 장비 퍼센트 소수점 한 자리

2026-11-08 · TLT-028/041/043/052/057/084 · ENG → QA · 0.88.4 · 미게시

사용자 지시대로 장비 공격 보너스를 `4.0%`처럼 소수점 한 자리로 통일한다. 상점, 가방 현재/선택/pp차이, 데스크톱·모바일 전투 능력치의 장착 보너스/장비 출처, 강화 미리보기에 적용한다. 고정 수치와 실제 계산 정밀도는 유지한다. 확률/스킬/강화 단계 등 다른 수치의 표시는 이 작업 범위가 아니다. 기존 생성자 fixture를 재사용해 단위/반올림·실제 상점/가방을 확인한다.

변경 파일: `InventoryText`, `CombatStatText`, `AdventureText`, `CombatStatsView`, `MobileHeroStatsView`, `EnhancementView`, `InventoryGui`, `VERSION`. 기존 사용자 변경과 자산은 제외한다. 검증과 빌드 결과는 아래에 기록한다. 미검증: 실제 화면·실기기 터치/줄바꿈·게시 클라이언트. 다음 담당 QA는 가로 상점·가방·강화·영웅 능력치를 확인한다. 부모 티켓 완료/릴리스 태그/Roblox 게시 없음.

검증: `git diff --check` PASS. 고정 소스 `33cf377edf41eca6b07f9ef423479a8367630b12`를 origin/main에 푸시하고 `python3 tools/build-game.py --source 33cf377e --record docs/evidence/equipment-percent-20261108/build.json` 성공. 산출물 `builds/0.88.4/TheLastThrone-0.88.4.rbxlx`, SHA256 `a3d7ea96743bb482c44cc413610c2edfc084d94095e9d95761ac93886b63adbd`. [빌드 기록](build.json). `python3 tests/single-build.spec.py --artifact builds/0.88.4/TheLastThrone-0.88.4.rbxlx`: 역할10·도착로딩192·구성/마운트 PASS. `run-in-roblox --place builds/0.88.4/TheLastThrone-0.88.4.rbxlx --script docs/evidence/equipment-percent-20261108/probe.luau`: 실제 상점49+단위/반올림9+실제 가방40, 총98검사 PASS([로그](native.log)). 계산값을 바꾸지 않는 fixture 검사이며 실제 기기 화면 수용과 구분한다. 연결된 Battles Studio Edit의7개 모듈에 변경 문맥을 대조해 적용했다. Play 재시작·Place 저장/게시 없음. 새 LFS 파일/전송 없음.
