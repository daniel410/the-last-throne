# Blender MCP 검·도끼 모션 제작 / 0.41.1

2026-10-31 · TLT-005/032/033/055/057/084 부분 구현 · ART/ENG → QA/DES

사용자는 별도 Python 구현 대신 Blender MCP 연결을 요청했고, 후속 답변으로 **Blender MCP 내부 API 사용**을 선택했다. Blender5.2.0 LTS에 MCP for Blender2.2.6을 설치·등록하고 실제 MCP stdio 요청으로 장면 조회·리그 생성·Action 키프레임 편집·곡선 평가·다각도 화면·원본 저장을 수행했다. 연결만 등록한 결과와 구분한다. [연결 상태](connection-status.json) · [실행 요청과 응답](03-keyframes.mcp.json).

## 원본과 동작

[편집 가능한 Blender 원본](../../../assets/animations/melee-blender-v1/melee-attacks.blend)에 기사 Forehand/Return/Finisher와 Dwarf HeavyCut **4 Action·144 F-curve·720 keyframe**을 보존했다. 두 Armature는 Roblox에서 측정한 R15 C0/C1을 사용한다. 몸통·하체 준비를 팔보다 먼저, 팔꿈치/무기 회복을 늦게 배치했고 준비 자세와 전투 준비 끝 자세를 조정했다. 서버가 승인하는 타격 자세와 기존 공격 시간은 기준으로 유지했다. 기사3타의 방향과 도끼 내려치기를 구분한다.

검·도끼·방패는 TD 원본 검토 GLB를 불러왔다. 검에는 생산용 yaw180도/위치0.3 보정을 적용했다. **흰색 몸체는 관절 편집용 프록시**이며 완성 영웅 외형이나 드워프 고유 체형을 제작한 결과가 아니다. Blender의 손 치수/방패 오프셋은 프록시 기준이며 최종 간섭은 실제 Roblox 원본 어댑터에서 별도 검사한다. TD 메시·UV·텍스처·업로드 ID는 변경하지 않았다.

초기 리그 작업의 EditBone 참조 수명 오류와0길이 본의 회전축 오류를 발견했다. 본 이름을 보존하고 길이를 먼저 지정한 뒤 실제 C0/C1 행렬을 적용해 수정했다. 도끼 접촉 시점의 native joint chain과 Blender 본 행렬 차이는 최대 약4.8e-7이며 좌표계 변환 뒤 무기 끝이 일치했다. [축 대조](axis-parity.json). 이 한 시점의 대조를 모든 UGC 체형의 검증으로 확대하지 않는다.

[영상 비교](../../research/2026-10-31-sword-axe-motion-video-review.md)는 앞서 확인한 Monster Hunter Wilds 검·방패 약11.1~11.7초, God of War 도끼 약65.35~65.85초를 이어 사용했다. 타 게임의 애니메이션/리그 데이터를 복제하지 않았다.

## 게임 적용

Blender MCP에서 실제 F-curve의 key·접선과 `fcurve.evaluate` 기준132시점을 추출했다. [추출 데이터](../../../assets/animations/melee-blender-v1/curves.json)를 `node tools/export-melee-blender.mjs`로 Luau 데이터와 독립 기준 샘플로 변환한다. 런타임 `K0MeleeMotion`은 해당 곡선을 절대 서버 시각으로 평가하며 회복 중 새 공격은 이전 자세·속도를 이어받는다. Blender는 런타임 의존성이 아니며 기존 Roblox 관절/장착 코드를 사용한다. 새 AnimationId 업로드·피해/판정/사거리/쿨다운·Stamina 변경은 없다.

## 검증

| 조건·명령 | 결과 |
| --- | --- |
| `node docs/evidence/melee-blender-0411/build-probe.mjs /private/tmp/tlt-melee-blender-final` 후 출력 Place/runner로 `run-in-roblox` | 실제 TD 무기·방패·R6/R15 기하/접촉 시각/연격/30·144Hz 검사 **3,204개 통과**. [원시 로그](native.log) |
| 같은 엔진 실행, `tests/k0-melee-blender-native.luau` | Blender가 평가한132시점×12채널 **1,584개 통과**, 최대 오차 **0.00003052도**. [결과](native-results.json) |
| Blender MCP `look`의 다각도/6시점 strip | [다각도](blender-angles.png) · [연속 프레임](blender-frames.png). 기본 재생 Action은 Forehand/HeavyCut이며 나머지2개도 원본 Action에 보존했다. |
| Roblox Studio, 미게시 동일 아바타4개·원본 검/방패/도끼, 0.40.3과 새 곡선에 동일 합성 서버 시각 | 재생/준비/접촉/회복과 기사 타수 전환을 확인했다. PlayerScripts의 곡선 SHA256이 추출 데이터와 일치함을 MCP로 확인했다. 정상 전투 입력·게시 클라이언트 검사와 구분한다. |

모션 전용 native fixture는 현재7개 모듈과 원본 무기/방패를 읽으며 전체 서버/스토리 실행을 포함하지 않는다. 검날 중심선과 방패 OBB 검사는 모든 메시 삼각형의 충돌 검사가 아니다. 무기/상체 곡선 검증이며 바닥 위 하체 이동의 정상 입력 수용은 별도다. 기존 자산203785492 유형 경고는 로그에 남긴다. [0.40.4 선행 결과](../melee-motion-0404/README.md)의42개 방어 검사는 그 버전의 결과이며 이번에 다시 센 검사와 구분한다.

## 빌드·인계

동시에 진행된 스토리 작업이0.41.0으로 커밋돼 다음 버전은 **0.41.1**로 예약했다. 그 작업의 코드를 이 변경으로 재작성하지 않았다. 최종 빌드의 고정 커밋/해시와 역할 시작 검사는 build.json에 추가한다. Roblox 게시·릴리스 태그는 이번 범위가 아니다.

정상 전투의 이동/방어/회피 전환, 모바일·패드,4인 관전자·실제 네트워크 지연·다양한 아바타 비율·최종 사용자 미술 수용은 남아 있다. 상위 티켓은 In Progress다. 다음 담당은 QA/DES다. 복구 시 이전 모션 모듈로 되돌릴 수 있고 원본 모델에는 변경이 없다.
