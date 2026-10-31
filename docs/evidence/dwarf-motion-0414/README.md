# 드워프 영웅의 도끼 기본기·공통 기술 개선

2026-10-31 · TLT-005/032/033/055/057/084 부분 구현 · ART/ENG → QA/DES

사용자 요청에 따라 `dwarf` 영웅의 기본 도끼 베기와 `OVERHEAD SMASH`, `AXE THROW`, `GROUND SLAM`을 개선했다. 이전0.41.1에서 Blender 곡선은 기본기만 사용했고 세 기술은 단계별 포즈/보간을 사용했다. 이번에는 서버가 승인한 기술ID와 시작 시각으로 각 Blender Action을 선택한다. 다른 상위 기술은 기존 전용 동작을 유지한다.

## 제작과 적용

실제 Blender MCP `execute_blender_code`로 드워프4 Action의 관절·무기 소켓을 편집했다. 기본기는7개 시점으로 준비·늦은 가속·접촉·관성 감속·회수를 나눈다. 몸통을 먼저 감고 빈손으로 균형을 잡으며 도끼 머리는 접촉점에서도 이동을 계속한 뒤 감속한다. 세 기술도 각기 다른 준비 자세·투척 팔 펴기·낮은 강타 후속 자세를 갖는다. 기술 회복 중 기본 공격이 시작되면 자세와 속도를 이어받는다. 투척은 근접 베기 Trail을 켜지 않는다.

[새 Blender 원본](../../../assets/animations/melee-blender-v1/dwarf-refinement.blend)은 기사3 Action을 보존하고 드워프4 Action을 개정/추가한7 Action·252 F-curve·1,548 keyframe이다. [이전 원본](../../../assets/animations/melee-blender-v1/melee-attacks.blend)은 보존했다. [편집 요청](01-author.mcp.json)·[응답](01-author-result.json)·[추출 요청](02-export.mcp.json)·[저장 결과](04-save-result.json)로 실제 MCP 작업을 추적한다. 별도 Python 실행 파일 없이 사용자가 허용한 MCP 내부 Blender API를 사용했다.

TD 도끼 메시/UV/업로드ID와 서버 피해·판정·공격 시간·쿨다운은 변경하지 않았다. 기본기 접촉0.22초, 내려찍기0.71초, 투척0.30초, 지면 강타0.41초를 유지한다. Blender 몸체는 기존 관절 편집용 프록시이며 드워프 고유 체형/완성 외형을 새로 제작한 결과로 보고하지 않는다.

## 근거

[앞선 실제 영상 비교](../../research/2026-10-31-sword-axe-motion-video-review.md)의 도끼 타격 후 몸통 회전·빈손 균형 관찰을 이어 적용했다. 이번에는 [PlayStation 공식 전투 가이드](https://www.playstation.com/en-us/games/god-of-war-ragnarok/god-of-war-combat-refresher-course/)의 가벼운/무거운 공격·투척 구분과 [개발자 전투 해설](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/)의 무게감·무기 궤적/신체 자세 제어 설명을2026-10-31에 추가 확인했다. 제작 방향의 참고이며 타 게임의 프레임/관절 데이터 복제나 직접 플레이 검증이 아니다. 기존 Roblox R6/R15 관절 계약은 실제 엔진에서 검증한다.

## 검증

`node docs/evidence/melee-blender-0411/build-probe.mjs /private/tmp/tlt-dwarf-0412-qa`로 모션 전용 Place/runner를 만들고 `run-in-roblox --place …/tlt-k0-qa-empty.rbxlx --script …/source-probe.luau`를 실행했다. 임시 경로0412는 버전 예약 전 이름이며 실제 게임 빌드와 다르다.

| 검사 | 결과 |
| --- | --- |
| 실제 TD 도끼/검·방패, R6/R15 기본기 기하·시각·연격·30/144Hz 회귀 | 3,204개 통과 |
| Blender 독립 평가231시점×12채널 | 2,772개 통과, 최대 오차0.00003054도 미만 |
| 실제 드워프 기술ID 선택, 관절 적용, 루트 불변, 손 소켓, 단계 경계 연속성, 기술→기본기 전환, 기사/미지원 기술 배제 | 1,642개 통과 |

[원시 결과](native.log)·[구조화 결과](native-results.json)·[입력 해시](probe-source-manifest.json). 첫 실행은 기존 검사가 “모든 기술은 기본기 Blender 레이어를 우회한다”는 옛 계약을 기대해 실패했다([실패 로그](native-first.log)). 새 드워프 기술 선택 계약과 기사 전용 우회 기대를 구분한 뒤 전체 검사를 재실행했다. 기존 기하 수용 임계치를 완화하지 않았다.

![Blender 드워프 기본기](blender-basic-frames.png)

![Blender 드워프 내려찍기](blender-overhead-frames.png)

검사는 합성 서버 시각의 네이티브 엔진/관절·원본 도끼이며 정상 플레이어 입력/네트워크/실기기 미술 수용과 구분한다. 다양한 아바타 비율·이동/방어/회피 전환·4인 관전자·모바일/패드·투척 비행체와 손의 최종 시각 수용은 남아 있다. 앞선 게시 요청은 Studio 창 선택/응답 문제로 미완료 상태이며 게시 성공으로 보고하지 않는다. 상위 티켓은 In Progress다. 다음 담당은 QA/DES다.

동시에 진행된 다른 작업이0.41.3까지 빌드해 이 변경의 게임 버전은 **0.41.4**다. 고정 소스 커밋 `c6dc8785227e3c19fc0705b0b4c231194f7d6642`의 입력과 해시가 일치하는 LFS 자산6개로 Rojo7.7.1 Lobby/Battle 빌드를 완료했다. [재현 도구](build.mjs)·[산출물 해시](build.json)·[빌드 내 모션3개 모듈 대조](source-verification.json). 첫 XML 확인 명령이 Rojo의 `string` 대신 `ProtectedString` 소스 태그를 가정해 실패했으나 검사기를 보정해 같은 산출물의 원문 일치를 확인했다. 재빌드/덮어쓰기는 없다. 최종 Battle 서버 시작 **10개 통과**([로그](battle-bootstrap.log)). 기존 자산203785492 유형 경고는 남아 있다. 다른 작업의 미커밋 파일은 빌드에 포함하지 않았다. 실제 Roblox 게시는 미완료이며 릴리스 태그도 만들지 않았다.
