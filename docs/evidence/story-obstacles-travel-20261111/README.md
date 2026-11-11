# 스토리 장애물·이동·구호 NPC 수정

작업: TLT-057/061/084 · ENG/DES · 2026-11-11. 부분 구현과 격리 엔진 검증이며 상위 티켓 수용 완료는 아니다.

## 변경과 근거

사용자 스크린샷3건을 반영했다. [비교 조사](../../research/2026-11-11-story-obstacles-travel.md).

- ForceField 유리벽을 TD 원본 `CliffRock`/`SnowCliff`/`VolcanoCliff`/`CemeteryCliff` 바위 더미로 교체했다. 활성 에픽만 개인 생성하고, 선행 조건 충족·트레이닝·모험 종료 시 모델과 충돌을 삭제한다. 템플릿 복제가 늦어져도 현재 스냅샷을 다시 적용한다. 서버 진입 판정은 그대로다.
- 확장 사건 출구는 같은 구역 입구 대신 저장된 다음 미완료 필수 목표/다음 활동 단계로 이동한다. 본편/선택 임무 자격과 같은 에픽 제한을 유지한다. 전투 목표는 서버의 기존 교전 동선 계산으로 아직 끝내지 않은 교전부터 재개한다. NPC 보고/목표 플래그·보상은 이동으로 변경하지 않는다. 표지판에는 개인별 현재 목적지 이름을 표시한다.
- DW-02 `exp_1` 구호 장면의 `PreparedReliefBench`와 목재 단서판을 없앴다. 단서 문구는 바닥의 파란 천에 연결하고 세 천 조각도 바닥에 눕혔다. Selene/Convoy Survivor를 지면 기준7stud 간격으로 고정하고 약품 상자를 옆으로 옮겼다.
- TD 원본 바이트/운영 소스는 변경하지 않는다. 원천/해시/권리는 `assets/shared/td-deepwood-environment/manifest.json`을 따른다.

## 검증

- `lua tests/campaign-expansion.spec.lua`: **7,698 PASS** (35본편·12선택·82사건·246단계). 기존 보상·저장/선택·개인 진행 회귀.
- `lua tests/checkpoint-travel.spec.lua`: **1,927 PASS**. [체크포인트 로그](checkpoint-travel.log).
- `python3 tools/prepare-story-obstacles-travel-native.py --preview`, `run-in-roblox --place builds/0.103.8/TheLastThrone-0.103.8.rbxlx --script /tmp/tlt-story-obstacles-travel-native.luau`: **914 PASS**, 수정 소스를 주입한 격리 엔진 검증. [로그](native-preview.log).
- 전용 엔진 검사는 개인별 바위/전체5에픽 자산·해제 시 삭제·영웅 전환/트레이닝·늦은 복제·파괴 후 정리, 본편70개 출구의 다음 필수 목표·접근 자격, 구호 장면의 판자 부재/천 재질·높이/NPC7stud 간격, 서버 목적지 어댑터, 전체 런타임 Luau 문법을 검사한다. 출구에서 다음 목표까지 최소 약218stud다.

## 최종 빌드

- 버전 **0.103.9**, 입력 커밋 `f7040e7cdfe4591bc812ceb6be192eb8899cb717`. 커밋·origin/main 푸시 및 원격 일치를 확인한 뒤 정본 빌드 도구를 실행했다.
- 산출물 `builds/0.103.9/TheLastThrone-0.103.9.rbxlx` · SHA-256 `2f2f8f31da46562e13b73ed48515c2747e2f50ee51a77169fbf9ae4c0ef796f3`. [LFS 입력/빌드 기록](build.json).
- `python3 tools/prepare-story-obstacles-travel-native.py` 후 위 산출물에서 재실행: 변경10모듈 Source 일치, **914 PASS**, 본편70출구·Deepwood 개인 장애물9개(다른 에픽 미할당), 다음 목표 최소218.4488stud. [최종 엔진 로그](native.log).
- Roblox 게시·릴리스 태그는 생성하지 않았다.

## 미검증·다음 담당

게시 클라이언트·현재 사용자의 실행 중 세션에는 아직 적용되지 않았다. 실제 다중 클라이언트/모바일·실기기 성능, 자연스러운 바위 실루엣/충돌 체감, 구호 NPC의 미술 수용과 전체 임무 실제 보행은 미검증이다. 두 개인 투영의 분리 검사는 실제 두 플레이어 수용을 대신하지 않는다. 다음 담당 QA/사용자: 새 빌드에서 세 장면을 확인하고 게시·실기기 수용을 진행한다.
