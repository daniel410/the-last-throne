# Gloamwood 실제 Meshy 모델·새 스킨 모션 · 0.80.0

2026-11-07 · **TLT-065/032/033/057/084** · ART/ENG → QA · 로컬 구현·Studio 반영, 미게시. 부모 티켓은 In Progress다.

사용자가 Meshy에서 제작한 Gloamwood 몬스터5종·보스3종으로 맵의 임시 모델과 움직임을 교체하도록 요청했다. 일반 지네의 작은 크기·더듬이, 거미4종의8다리 최신 지시를 유지한다. 기존 다른 작업의 미커밋 Blender/이미지 삭제와0.79.8 HUD/0.79.9 시작 장비 커밋을 보존했다.

## 변경과 근거

- Meshy 작업공간에서 색 텍스처가 완성된8개를 골라 GLB로 다운로드했다. 한 개체당 단일 메시이며 원본에는 본/스킨/애니메이션이 없었다. [자산 목록·원본/파생 SHA256](../../../assets/models/gloamwood-meshy-v1/manifest.json).
- Blender5.2 별도 씬에서 **116본·80클립 슬롯**을 제작했다. 거미는8다리의 상·하단, 박쥐는 날개/끝, 엔트는 팔/다리, 지네는12구간 몸통을 움직인다. 원본15,912삼각형/정점 위치/UV·색 텍스처를 보존하고 스킨 가중치를 추가했다. 원본의 미세 정밀도 차이는 [검사 기록](../../../assets/models/gloamwood-meshy-v1/clip-validation.json)에 남겼다.
- `GloamwoodAppearance`가8개 실제 스킨 템플릿을 복제한다. 서버 R6 이동/피해/HP·보상·기존 몬스터ID/본편 진행은 유지한다. 새 장식은 Massless·비충돌/비접촉/비쿼리이며 Atomic 모델로 스트리밍한다. 새 모델의 가로/세로 비율에 맞춰 거미는 발폭, 지네는 길이, 엔트는 높이로 크기를 맞췄다. 일반 지네 길이7.275stud, King11.32stud다. 박쥐는1.2stud 부유한다.
- 기존 Gloamwood 전용 블록 Motor6D 흔들기를 GLB에서 추출한 종별 Bone.Transform으로 교체했다. 이동 거리·기존 공격 시계/접촉 위상·경직/노출·피격 반응·중단/사망/해제에 연결한다. 새 스킨에는 Slime/Ogre의 기존 R6 몸통 squash/bob을 중복 적용하지 않는다.
- 계정9156786071의 Model8건 업로드 승인, 실제 Mesh8ID/색 텍스처8ID를 기록했다. 가져오기 시 회색 Color는 원본 glTF 기본 흰색으로 보정했다. 클립이 Open Cloud 가져오기에서 제외되어 별도 Animation 자산 없이 로컬 샘플 모듈을 사용한다. 현재 열려 있는 The Last Throne Studio의8템플릿과 관련11개 루트 ModuleScript/지네 하위 클립도 갱신했다. 임시 가져오기 패키지/hex 청크/검토 바닥은 정리했다.

새 리그/스킨 적용은 [Roblox rigging 문서](https://create.roblox.com/docs/art/modeling/rigging)·[Bone.Transform](https://create.roblox.com/docs/reference/engine/classes/Bone/Transform)을 확인했다. [일반 모델 사양](https://create.roblox.com/docs/art/modeling/specifications)의 메시20k tris·정점 최대4본·Root 무가중치 요구를 검사했다. 디아블로 우선 조사에서는 [Diablo IV 2021-12 개발 업데이트](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)의 전투 가독성·동작과 피격 반응 연결 원리를 참고했다. 이 자료는 현재 패치의 관찰이나 기존 피해 계약 변경 근거가 아니다. 우리 적용은 서버 시각 보존·종별 큰 동작 구분·피격 반응 합성이다.

## 검증

| 명령/환경 | 결과·증거 |
| --- | --- |
| `python3 tools/export-gloamwood-meshy-clips.py` |8개 단일 메시·삼각형/정점·UV 원형·정규화 가중치·본 수/가져온 rest CFrame·80클립/41표본 PASS. 모든 정점 최대2본, Root 무가중치 |
| `rojo build default.project.json -o /tmp/tlt-gloamwood-split-review.rbxlx` | 최종 클립 분할 구조·실제 LFS 모델을 포함한 로컬 조립 성공 |
| `run-in-roblox --place /tmp/tlt-gloamwood-split-review.rbxlx --script tests/gloamwood-meshy-native.luau` | **27,993 PASS·종료0**.8종×0.6/1/1.4배·8다리/116본·단일 스킨·비충돌·방향·유한 샘플·30/60/144Hz 공격 접촉·경직/노출·사망/해제·Root/HP 보존. [로그](native-split-final.log) / [구조화 결과](native-split-final.json) |
| 같은 실제 메시/텍스처 PreloadAsync |16개 ID 모두 Success. 현재 Studio에서도8종 실제 화면 확인. [Studio8종](studio-eight-walk.jpg) |
| `python3 tools/assemble-enemy-pattern-test.py` → `run-in-roblox --place /tmp/tlt-gloamwood-review.rbxlx --script /tmp/tlt-enemy-patterns-native.luau` | **1,127 PASS·종료0**, 기존49종/142공격·실제 장식16파트 회귀. [로그](pattern-regression.log) / [결과](pattern-regression.json) |
| `run-in-roblox --place /tmp/tlt-gloamwood-final-review.rbxlx --script tests/deepwood-monster-refinement-native.luau` | **3,122 PASS·종료0**, 기존TD10종의 공통 모션/소켓/Root·피해 경로 회귀. [로그](deepwood-regression.log) / [결과](deepwood-regression.json) |

초기 열린 Studio는 별도 빈 오디오 작업 파일이어서 asset 권한이 꺼져 있었다. 사용자 확인 뒤 실제 TLT Place70829337938054로 다시 연결했고 허용된 assets 폴더와 asset:read/write로 업로드했다. 권한 우회는 하지 않았다.

첫 GLB 내보내기에 다른 씬의 선택 개체가 포함되는 것을 로컬 검사로 발견해 `use_active_scene=True`로 고친 뒤, **각1메시인 최종8파일만** 업로드했다. Blender 안전 모드에서 pathlib/별도 blend 저장 API가 거부된 호출은 실행하지 않았고 허용된 import/export로 작업했다. 별도 `.blend`를 저장하지 않았으며 편집 가능한 GLB/제작 스크립트와 새 씬을 보존하고 원래 미저장 드워프 씬을 복원했다.

최초 엔진 검사27,969항목은 PASS였지만 Studio TexturePack429 오류로 CLI 종료1이었다([초기 로그](native-initial.log)). 재시도/회색 틴트 보정/클립 분할 후 최종 검사는 종료0이다. Source200,000바이트 제한으로 지네2개 직접 동기화가 실패해 클립별 하위 모듈로 나눠 성공했다. 최초 패턴 회귀 실행의 파일명 오타는 [별도 로그](pattern-wrongpath.log)에 보존하고 올바른 번들로 재실행했다. 기존203785492 타입 경고와 콘텐츠 표현 생성 대기 경고는 실제16개 로드 Success와 구분한다.

## 미검증과 다음 담당자

정상 Gloamwood7스토리 전투 완주, 게시된 Experience의 새 자산 권한, 실제 기기/4인+AI 성능·스트리밍·늦은 합류, 사용자 최종 미술 수용은 남아 있다. Blender/Studio 자세/격리 엔진 검사를 이를 대신하는 증거로 쓰지 않는다. 일부 AttackAlt/전환 슬롯은 같은 키를 공유하며80개의 독립적 전용 연출을 뜻하지 않는다. 지네 발의 독립 IK, 전 종의 지면 경사 접지/관절 극한 자세와 체형별 공격 연출의 세부 다듬기는 후속이다.

다음 QA는 고정 빌드에서 GW본편/선택 보스·소형 적과 보스 크기·8다리 보행·피격/사망·실기기 성능을 관찰한다. ART는 사용자 수용 결과에 따라 발 접지와 관절을 다듬는다. 실제 Roblox Place 게시와 릴리스 태그는 수행하지 않았다. 버전/입력 커밋/산출물 해시는 마감의 `build.json`에 기록한다.
