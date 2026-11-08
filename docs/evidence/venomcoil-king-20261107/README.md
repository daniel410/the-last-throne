# Venomcoil King 최신 Meshy 모델 교체 · 0.83.5

2026-11-07 · **TLT-065/032/033/057/084** · ART/ENG → QA. 프로젝트/열린 Studio 적용, Roblox Place 미게시. 부모 티켓은 In Progress다.

Meshy 작업공간에서 최신 색상 모델을 직접 선택·다운로드했다. 원본 파일 `Meshy_AI_Crimson_Carapace_Colo_1108035342_texture.glb`는 2,458tri·3,218정점의 단일 메시이며 본/애니메이션이 없다. 기존 King 원본·파생 자산은 그대로 보관하고 [v2 자산 묶음](../../../assets/models/venomcoil-king-v2/README.md)을 추가했다. 다른 미커밋 이미지 삭제/Blender 작업은 보존했다.

새 몸통 중심선을 따라 Root/Body/12구간의14본을 배치하고 기존 Idle/Walk/Attack/Heavy/경직/노출/복귀/중단 모션 계약과 공격 접촉 위상0.62를 유지했다. 10슬롯은 일부 대체 동작을 공유한다. 원본 POSITION/UV 오차1e-6 미만·원본 텍스처 바이트 동일·최대2본 정규화 가중치·Root 무가중치를 검사했다. 기존7종 자산 엔트리는 동일하다. 게임플레이/보상 변경 없이 기존 길이11.32stud와 새 원형 비율을 적용했다.

계정9156786071의 Model1건 업로드 승인: `88842965200176`. 파생 Mesh `138080691573925`, 색 Texture `93469012689254`. 별도 Animation 업로드 없음. 가져오기의 회색 틴트를 흰색으로 보정하고 비충돌/비접촉/비쿼리·Massless·Atomic·PackageLink 없는 런타임 복사본으로 연결했다. 현재 Studio8템플릿 중 King과 해당 클립만 교체했으며 검토 바닥/패키지/청크는 정리했다. Blender 기존 드워프 씬도 복원했다.

기존 [Gloamwood 제작 조사](../gloamwood-meshy-20261107/README.md)의 리그/모션 원칙을 재사용했다. 이번은 승인된 자산 교체이며 게임성 변경은 없다. [Roblox 모델 사양](https://create.roblox.com/docs/art/modeling/specifications)을 다시 조회해 메시당20,000삼각형 한도 내임을 확인했다.

| 검증/환경 | 결과 |
| --- | --- |
| `python3 tools/export-gloamwood-meshy-clips.py --base assets/models/venomcoil-king-v2` | 단일 표면/UV·14본·정규화 가중치·native rest·10슬롯×41표본 PASS. [검사 기록](../../../assets/models/venomcoil-king-v2/clip-validation.json) |
| 원본/리그 GLB 이미지 바이트 SHA256, 기존/신규 manifest7종 비교 | 텍스처 동일·다른7종 동일 PASS |
| `rojo build default.project.json -o /tmp/tlt-venomcoil-v2-review.rbxlx` | 조립 성공 |
| `run-in-roblox --place /tmp/tlt-venomcoil-v2-review.rbxlx --script tests/gloamwood-meshy-native.luau` | **27,993 PASS·종료0**,8종×3크기·모션/공격 접촉/경직/사망/해제·Root/HP 보존. [로그](native.log) / [결과](native.json) |
| 실제16개 메시/색 텍스처 PreloadAsync | 모두 Success. 기존203785492 타입 경고/일시적 표현 생성 대기는 최종 로드 결과와 구분 |
| Studio 실제 외형/Walk0.25·Heavy0.62 | 왕관·긴 몸통·색·방향/접지 확인. [전후 비교](studio-compare.jpg), [새 모델](studio-updated.jpg) |

![새 Venomcoil King의 강공격 접촉 자세](studio-updated.jpg)

정상 Gloamwood 전투 완주, 실제 기기/4인+AI 성능, 게시 Experience 자산 권한, 독립 발 IK/경사 접지 및 사용자 최종 미술 수용은 후속이다. QA는 고정 빌드에서 보스 전투와 위 항목을 확인한다. 실제 Place 게시·릴리스 태그는 수행하지 않는다. 빌드 입력/해시/마감 결과는 후속 `build.json`과 아래 마감 기록으로 연결한다.
