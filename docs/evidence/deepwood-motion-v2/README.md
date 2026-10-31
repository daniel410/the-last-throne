# Deepwood 몬스터·무기 동작 v2

2026-10-31 · TLT-005/032/033/055/057/084 · 3D/ENG/QA · 0.49.0 로컬 시험 구현, 미게시

[조사·선택 이유](../../research/2026-10-31-deepwood-monster-refinement-v2.md) · [원본·해시](../../../assets/animations/deepwood-monsters-v2/manifest.json) · [Blender 편집 원본](../../../assets/animations/deepwood-monsters-v2/deepwood-motion.blend)

## 결과와 제작 계약

- TD10종의 원형/PBR를 보존하면서 종별 대기·보행·일반2종·강공격2종·스턴을 제작했다. 70개 논리 클립/350 Action, 채널당201표본이다. Blender MCP를 통해 bpy에서 실제 Action과 F-curve를 편집·평가했다. 외부 모델 생성·새 Roblox 에셋 업로드는 없다.
- 무기 머리가 포함된 메시 최고점을 어깨 회전축으로 쓰던 문제를8종의 별도 어깨 좌표로 보정했다. 양팔의 새 C0/C1은 중립 실루엣과 손/무기 결합을 유지한다. 원본 메시/텍스처 자체의 토폴로지는 변경하지 않았다.
- 서버 예고·판정·회복 시간을 기존 계약대로 .62 타격에 대응한다. 서버 시퀀스 홀짝으로 일반/강공격 변주를 고정한다. 피해·범위·보상·스턴 시간·공격 빈도는 변경하지 않았다.
- Blender 정점에서 추출한 무기8종 끝점에 짧고 절제된 궤적을 연결했다. 주술사2종은 준비 중 3D 초점 조각을 추가하며, 이번 프레임의 관절 합성으로 지팡이 끝을 따른다. 장식은 충돌/쿼리/피해가 없다. 스턴·사망·텔레포트·거리 밖·스트리밍 해제에서 정리한다.
- 발의 메시 경계 보정·실제 거리 기반 보폭·서버 루트 권위와 기존 피격 반응을 유지한다.

Blender NLA 검토 타임라인: Idle 0~120 / Walk 140~260 / Attack 280~400 / AttackAlt 420~540 / Heavy 560~680 / HeavyAlt 700~820 / Stunned 840~960. 공격별 CONTACT 표식이 있다. 기본은 Goblin을 표시하며 다른 종은 해당 `_Root`와 자식을 표시하면 된다.

제작 재현 순서는 v1 원본을 Blender에서 열기 → `tools/author-deepwood-motion-v2.py`를 MCP execute_blender_code로 실행 → `tools/author-deepwood-sockets-v2.py` 실행 → scene의 `v2_export`와 소켓 JSON 저장 → `tools/prepare-deepwood-review-v2.py` 실행 → 별도 v2 `.blend` 저장 → `python3 tools/export-deepwood-blender.py`다. Python 스크립트로 별도 Blender 프로세스를 실행하지 않았다.

## 검증과 화면

실제 TD MeshPart/Motor6D를 사용하는 미게시 로컬 Rojo fixture에서 검증했다. [최종 네이티브 로그](final-native.log)와 [정적 원본 검사](static-assets.json)는 실제 통과 결과다. 최초 검사에서 큰 월드 좌표의 float 오차와 네이티브 importer의 Y180 소켓 반전을 발견하고 테스트 허용 오차/소켓 변환을 각각 수정했다. 서버 권위를 바꾸거나 검증 조건을 제거하지 않았다.

| 검사 | 결과 |
| --- | --- |
| `python3 tools/export-deepwood-blender.py` | 10종70클립·201표본·길이/유한값/루프 접합·소켓 경계 검증 및 런타임 생성 |
| `python3 tests/td-monster-assets.spec.py` | 원본/해시/LFS/런타임 XML134검사 통과 |
| `tests/deepwood-monster-motion-native.luau` | 종별 루프/발높이/거리 보행/타격 시각/늦은 관찰자/루트·HP 권위9,553검사 |
| `tests/deepwood-monster-refinement-native.luau` | 실제 어깨·무기 끝점·4공격 × 30/60/144Hz·시전 초점 지연·효과 정리·.62 정확 표본3,122검사 |
| `tests/enemy-streaming-presentation-native.luau` | 늦은 컨테이너/부분 리그/스트림 아웃·인10검사 |
| `tests/k0-timing-native.luau` | 서버 전투 타이밍110검사 |
| `tests/k0-basic-attacks-native.luau` | 기본기·기술·중복 피해/범위947검사 |
| `tests/knight-stun-and-control-effects-native.luau` | 기존 방패 스턴·제어 효과296검사 |

네이티브 총14,038검사와 정적134검사는 게시 클라이언트/실기기 수용과 구분한다. 기존 로그의 Roblox asset203785492 유형 오류는 테스트 실패가 아니며 그대로 보존한다.

[10종 타격 자세 모음](cast-impact-review.png) · [수정 전 검증 이력](validation-history.json)

![실제 엔진의 타격 자세](studio-ogre-impact.png)

위 화면은 미게시 Studio Run fixture의5종 공격 타격 시각이며 실제 플레이어와 교전한 게시 클라이언트 화면이 아니다. [전체 화면](studio-impact.png). 아래 Blender 프레임도는 준비→타격→회수를 확인하기 위한 제작 화면이다.

| 종 | 프레임도 | 종 | 프레임도 |
| --- | --- | --- | --- |
| Goblin | [칼 공격](goblin-attack.png) | Orc | [도끼 강타](orc-attack.png) |
| Ogre | [곤봉 내려찍기](ogre-attack.png) | Shaman | [지팡이 시전](shaman-attack.png) |
| Warlord | [무기 공격](warlord-attack.png) | GoblinKing | [왕의 무기](goblinking-attack.png) |
| KingOgre | [왕의 강타](kingogre-attack.png) | EnragedWarlord | [갑옷 몸 강타](enragedwarlord-attack.png) |
| KingShaman | [왕의 시전](kingshaman-attack.png) | Slime | [압축/도약/착지](slime-attack.png) |

## 마감과 남은 수용

고정 소스 커밋·Lobby/Battle 빌드·해시는 [build.json](build.json)에 기록한다. 관련 파일만 선별 커밋/푸시하며 기존 미커밋 로비/네트워크 이동 작업을 포함하지 않는다. 일반 로컬 빌드이므로 릴리스 태그/Roblox 게시는 하지 않는다.

미검증: 실제 클라이언트의 지연/교전 가독성, 실기기/4인 동시 성능, 경사 지형 IK, 최종 사용자 미술 수용. EnragedWarlord는 기존 일체형 몸체이며 독립 팔/무기 관절이 생기지 않았다. 로브·팔의 기존 강체 분할과 팔꿈치/손목 스키닝 한계도 남아 있다. 이 산출물을 전신 리그 완성이나 ‘최고 품질 수용 완료’로 기록하지 않는다. 상위 작업은 In Progress를 유지하며 다음 담당은 QA/DES다.
