# 마법사 지팡이 타격·시전 개선

2026-10-31 · TLT-005/032/033/055/057/084 부분 구현 · 로컬 시험 빌드0.43.3

[공식 RPG 조사/비교](../../research/2026-10-31-mage-staff-casting.md)를 바탕으로 물리 기본 타격과 마법 발사·물 구체·광역·보호·강한 시전6개 동작을 개선했다. 서버 피해/기술 해금/MP/쿨다운/사거리/공격 시간은 변경하지 않았다.

## 실제 제작과 산출물

Blender MCP `execute_blender_code` 내부 bpy API로 `TLT_Mage_Staff_Authoring` 장면과 오른손 소켓의 R15 편집 리그,12부품 나무 지팡이 메시,6개 Action을 제작했다. 별도 Python 실행 파일은 사용하지 않았으며 안전 모드를 유지했다. [조사](01-inspect-result.json) · [편집 호출](02-author.mcp.json) · [편집 결과](02-author-result.json) · [지팡이 형상 정리](04a-geometry-result.json) · [저장 결과](05-save-result.json).

Action별12관절/무기 채널과 float 초점 속성으로37 F-curve·259 keyframe, 전체222곡선·1,554키를 만든다. 지팡이의 기존 런타임 치수와 재질 역할을 따른 편집 원본이며 새 Mage 영웅의 최종 몸체/의상 제작을 의미하지 않는다. 보라색 몸체는 관절 검토용 프록시다. `.blend`에는 이전 무기 편집 장면도 보존돼 있고 Mage 장면이 활성화돼 있다. GLB는 Mage 리그/지팡이만 선택해 만든 정적 방출 자세 검토본이며 애니메이션 전체는 blend에 있다.

- [편집 가능한 Blender 원본](../../../assets/animations/mage-staff-v1/mage-staff-casting.blend)
- [Mage 전용 정적 검토 GLB](../../../assets/animations/mage-staff-v1/mage-staff-review.glb)
- [Blender 추출 곡선과 독립 평가390시점](../../../assets/animations/mage-staff-v1/blender-curves.json)
- [타격](blender-staff_strike-frames.png) · [비전 발사](blender-arcane-frames.png) · [물 구체](blender-water_orb-frames.png) · [광역](blender-ground_area-frames.png) · [보호](blender-ward-frames.png) · [강한 시전](blender-elemental_heavy-frames.png)
- [자산 바이트/해시](asset-manifest.json)

## 런타임 적용

`K0MageMotion`과 `K0MageClips`는 Blender의 공유 기울기 cubic curve를 승인된 서버 시작 시각으로 평가한다. 기존 windup/active/recovery에 준비·방출·후속 자세를 맞추며, 회복 중 새 공격은 이전 자세/각속도를 이어받는다. 현재 Mage의 기본 공격과32개 기술을6개 동작 가족에 배정했다.32개 독립 Action을 만든 결과는 아니다. R6는 상체 소켓 축을 변환한 관절 폴백, R15는 팔꿈치·손목까지 사용한다. 이동 중 하체 Animator를 보호한다.

`K0MageFocus`는 지팡이 끝에 원소색 입자 emitter1개와 거리5의 그림자 없는 PointLight1개를 사용한다. 충전이 물리 Part나 선행 발사체를 만들지 않는다. 방어/회피/사망/장비 해제/관절 소실에서 충전을 정리한다. 마법 투사체는 기존 서버 payload만 사용하며 관절 렌더 뒤 현재 `WeaponTip` 위치에서 시작한다. 같은 payload를 다시 렌더해도 중복 발사하지 않는다. 기존 드워프 투척과 엘프 화살 소비 순서는 유지한다.

## 검증

`node docs/evidence/melee-blender-0411/build-probe.mjs /private/tmp/tlt-mage-staff-qa-final-r2` 후 `run-in-roblox --place …/tlt-k0-qa-empty.rbxlx --script …/source-probe.luau`를 실행했다.13개 실제 생산 모듈, 실제 R6/R15와 기존 장비 부착 코드를 빈 비공개 검사 Place에서 사용했다.

| 범위 | 결과 |
| --- | --- |
| 기사/드워프 기본기 기하·접촉·연격/FPS 회귀 | 3,204 통과 |
| 기존 기사/드워프 Blender 독립 평가 대조 | 2,772 통과 |
| 드워프4동작 기술·회복·클래스 분리 | 1,642 통과 |
| 엘프 활/노크/발사·취소·기존 회귀 | 4,844 통과 |
| Mage390시점 독립 Blender 평가·모든 기술 선택/종료 경계·소켓/루트·30/144Hz·이어 공격·충전/취소·현재 팁 발사/중복 방지·분리/관절 소실 | 17,087 통과 |

합계 **29,549 통과**. Mage 최대 각도 오차 약0.000038153도, 직선/물 발사 시 지팡이 축과 캐릭터 전방 내적 최솟값0.97136이다. [원시 로그](native.log) · [구조화 결과](native-results.json) · [입력 해시](probe-source-manifest.json).

첫 검사에서 공격 종료의 부동소수점 오차 때문에 잠깐 기본 타격 가족으로 돌아가는 문제를 찾아 Attack 중 마지막 자세를 유지하고 Idle에서만 기록을 정리하게 고쳤다. 추가 장비 분리 검사에서 발견한 nil 캐릭터 접근도 수정했다. [초기 종료 검사](native-first.log)와 [초기 분리 검사](native-detached-first.log)를 최종 통과 로그와 구분해 보존했다. 지팡이 cylinder 변환의 평가 전 좌표 문제는 메시 정점에 강체 좌표를 직접 베이크하여 수정하고 여섯 미리보기를 재확인했다.

수동 FK 검사는 관절을 끊고 C0·Transform·C1로 개별 부품을 배치하는 독립 기하 검사다. 이를 실제 Animator/IK 물리 시뮬레이션이나 게시 클라이언트 수용으로 보고하지 않는다. 후반 다중 pulse는 기존 서버 active 시간 동안 시전을 유지하는6가족 동작이며 매 pulse마다 별도 full-body 동작을 추가하지 않는다.

빌드 입력은 이 변경과 VERSION을 커밋한 뒤 고정한다. 빌드/소스 포함 검증 결과는 후속 증거 커밋에서 같은 문서에 연결한다. 실제 Roblox 게시·릴리스 태그는 이 로컬 개선 작업의 완료 근거에 포함하지 않는다.

## 미검증과 다음 담당

QA/애니메이터: 실제 게시 클라이언트·모바일/게임패드·다인 환경에서 주관적 자연스러움, 이동/조준 중 Animator 혼합, 다양한 아바타 비율/손가락과 지팡이 접촉, 장시간 원소 입자 성능과 최종 미술 수용이 필요하다. 문서/네이티브 통과로 이 게이트나 전체 TLT 티켓을 완료 처리하지 않는다.
