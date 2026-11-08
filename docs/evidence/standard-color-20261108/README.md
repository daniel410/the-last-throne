# Blender Standard 색상 비교 기준 적용

2026-11-08 · TLT-031/032/033/057/061~065/084 · ART/DES/ENG → QA · 로컬 자산·도구 수정, 게임 미빌드·미게시

사용자는 AgX 표시로 컨셉의 채도/색이 달라지는 문제를 지적하고, 에이전트 기준을 Standard로 확정하며 맵과 캐릭터의 색상 비교를 다시 적용하도록 요청했다. 프로젝트 제작 스킬을 적용했다. [Blender 공식 색 관리 설명](https://docs.blender.org/manual/en/4.5/render/color_management.html)의 표시 변환과 재질/텍스처 입력 색공간 구분을 참고했다. 이 작업은 원인이 명확한 표시 설정 수정이며 게임성 규칙을 바꾸지 않는다.

## 적용 범위

- AGENTS.md·agent.md·제작 스킬·디자인/3D/QA 역할·미술/QA 제작 계획에 **sRGB / Standard / None / Exposure0 / Gamma1 / Curves Off**를 필수 비교 기준으로 기록했다. 다른 역할도 공통 진입 지침을 따른다.
- Blender 제작/리뷰 도구26개, 장면 할당27곳에 설정을 명시했다. 미래 작업에서도 `python3 scripts/check_blender_color_contract.py`로 누락을 검사한다.
- 기존 TLT16개 `.blend`와 공유 TD 숲 키트1개 = **17파일·308장면**을 읽어 Standard 파생본을 만들고 다시 열어 설정을 검사했다. 맵·영웅 동작 리그·NPC·몬스터·무기 장면을 포함한다. [장면별 설정/전후 해시](blend-files.json).
- 현재 열린8개 Blender 장면도 Standard로 전환했다. 활성 드워프 장면은 유지하고 전체 저장 사본 `live-character-scenes.blend`를 만들었다. Gloamwood8종·Venomcoil King v2와 기존 작업 장면을 포함한다. [현재 장면 기록](live-scenes.json).
- 현재 게임용 `Selene-repaired.glb`를 별도 Standard `.blend`로 가져왔다.
- 원본을 보존하고 **새 비교본은 [assets/reviews/standard-color-v1](../../../assets/reviews/standard-color-v1/README.md)**에 모았다. TD 원본·기존 미커밋 dwarf-refinement.blend·기존 `.blend1`·사용자 삭제/미추적 자료를 변경하거나 커밋에 포함하지 않는다. 단, 드워프의 현재 수정 내용은 원본을 보존한 파생 사본에도 포함된다.

## 검증

| 명령/조건 | 결과·범위 |
| --- | --- |
| `python3 scripts/check_blender_color_contract.py` | 26도구의27장면 할당에 필수 설정 존재, Python AST 파싱 PASS |
| `Blender --background --factory-startup --python tools/update-blender-standard-color.py -- assets/reviews/standard-color-v1/manifest.json` | 17파일·308장면 설정 적용/저장/재열기 검사 PASS. 변경 직전/직후 메모리의 콘텐츠 지문 동일 |
| `Blender --background --factory-startup --python tools/check-blender-standard-content.py` | 17파일·25662개 메시/재질 비교, 차이0 PASS. 원본/저장된 파생본의 실제 장면 참조 메시 정점·면/재질 인덱스·UV·재질 입력값을 별도로 비교. [결과](content-audit.json) |
| `Blender --background --factory-startup --python tools/render-standard-color-review.py` | 맵 공유 키트·기사/드워프 리그·엘프 리그·마법사 리그·NPC29명·Gloamwood8종·Selene, 7대상×AgX/Standard =14렌더. Cycles CPU8샘플·800×600·같은 재질/카메라/중립 조명/프레임. [설정](render-settings.json) · [비교 갤러리](index.html) |

Blender 전체 데이터블록 지문은 저장 시 사용하지 않는 데이터가 정리되거나 순서가 달라질 수 있어 재열기 후 동일성 보증으로 쓰지 않았다. 원본 파일을 보존하고, 실제 장면에 참조된 메시/UV/재질 입력값을 추가 대조했다. 이 비교가 리그/전투 모션/실기기 전체 수용을 뜻하지 않는다.

시각 검토에서 맵 키트의 녹색 지형/바위/포털, NPC 피부·의복·머리, Gloamwood 보라/빨강/녹색 계열, Selene의 흰색·금색 의복이 Standard에서 표시됨을 확인했다. 임의 채도 보정이나 재질색 재도색은 하지 않았다. 컨셉과의 최종 미술 일치 판정은 사용자/디자인 수용으로 남긴다.

## 한계와 인계

- 맵 렌더는 현재 공유 **숲 모듈 키트**이며 TLT44지역 전체 장면이 아니다. TLT 맵은 주로 Roblox 코드에서 조합된다. Blender View Transform은 Roblox `Color3`·TextureID·Lighting으로 내보내지는 값이 아니므로 이 설정 변경만으로 실제 게임44지역의 색이 수정됐다고 보고하지 않는다.
- 영웅 `.blend`에는 동작 검사용 회색/단색 리그가 있다. 해당 그림은 리그의 비교 설정 증거이며 플레이어 최종 외형/피부색 수용 증거가 아니다.
- 열린 Roblox Studio가 Play 중이어서 Edit 읽기 요청은 사용할 수 없었다. 기존 실행을 중단하거나 Studio/서버 월드를 수정하지 않았다. 게시 클라이언트·44지역 실제 조명·전체 영웅 최종 외형·모바일/다인 성능은 미검증이다.
- 개인 Blender 전역 startup/preferences는 저장하지 않았다. 프로젝트의 새 장면 제작 도구와 지침에 Standard를 명시해 적용한다.
- 다음 담당자는 ART/DES/QA다. 새 작업은 Standard 파생본과 승인 컨셉을 함께 열고, 실제 Roblox 조명에서 맵/캐릭터를 별도로 수용한다. 부모 티켓은 완료 처리하지 않는다.
- 게임 소스/버전은 변경하지 않았고 게임 빌드/릴리스 태그/Roblox 게시는 수행하지 않았다. 자산 파일 저장은 게임 빌드와 구분한다. Git 커밋·원격/LFS 전송은 작업 마감 보고에 기록한다.
