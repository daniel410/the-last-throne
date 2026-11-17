# NPC 5k 모델 사전 검토

작업ID: `NPC-5K-20261117` · 2026-11-17 · 상태: 미리보기 산출물 준비, 사용자 외형 수용 대기.

사용자 요청에 따라 기존 6개 지역 콘셉트를 바탕으로 Selene를 제외한 NPC 29명의 개별 PNG와 Meshy 3D 후보를 제작했다. 최종 목표는 인물별 소품을 포함한 5,000삼각형 이하이며, 얼굴은 둥글고 몸통·팔다리는 블록형인 기존 계약을 유지한다. 게임 소스·기존 NPC·TD 원본·VERSION·Roblox 게시에는 변경이 없다.

## 검토 산출물

- [전체 비교 갤러리](index.html): 인물별 생성 PNG / 실제 메시 정면·사선·후면 / GLB / 지역 Blender 파일.
- [29명 전체 보드](all-npcs-preview.jpg).
- 지역별 보드: [Dawnspire](dawnspire-preview.png), [Deepwood](deepwood-preview.png), [Frozen Vale](frozen-vale-preview.png), [Ember Caldera](ember-caldera-preview.png), [Gloamwood](gloamwood-preview.png), [Haunted Graveyard](haunted-graveyard-preview.png).
- [입력 이미지·정확한 생성 프롬프트·원본 해시](../../../assets/concepts/2026-11-17-npc-blocky-5k-v1/manifest.json).
- [모델별 Meshy 작업ID·소비량·원본/후보 해시](../../../assets/models/npc-meshy-5k-v1/manifest.json).
- [내보낸 GLB 검사](validation.json), [Blender 기하·렌더 기록](geometry-summary.json).

## 제작 근거와 수정

원본은 `assets/concepts/2026-10-31-npc-cast-v1`의 지역별 보드다. 현재 카탈로그 30명 중 Selene는 사용자의 명시적 제외 지시에 따라 생성·변경하지 않았다. 신규 게임성·역할·밸런스 설계는 포함하지 않았다.

이미지는 내장 image_gen으로 인물별 생성했다. 처음 6명은 제작 중 잠시 지정된 10k 디테일 기준 PNG를 입력으로 보존했으며, 모든 실제 3D 요청은 사용자의 최종 지시인 5k를 사용했다. PNG에는 실제 삼각형 개념이 없으므로 디테일 가이드와 실측 메시 예산을 구분한다. Freya와 Orik은 도구 손잡이가 손 위·아래에서 같은 직선 축을 유지하도록 이미지를 추가 수정한 뒤 Meshy에 제출했다. 검의 곧은 중심선과 손잡이 정렬을 확인했고 활의 의도된 곡선은 유지했다.

Codex에 설정된 공식 `@meshy-ai/meshy-mcp-server`의 이미지→3D 도구를 사용했다. `meshy-t2.5`, `smart-topology`, `target_polycount=5000`, `triangle`, `meshy-n1`, 2K 텍스처, GLB 형식이다. 29개 작업이 모두 성공했고 작업당15, 총435 Meshy 크레딧을 소비했다. API 키와 서명 다운로드 URL은 저장소에 기록하지 않았다.

Blender의 원본 모델은 보존하고, 5,000을 초과한 모델만 작은 비율로 감면해 `candidates/`에 내보냈다. 이미 예산 안에 있는 모델에 불필요한 면을 추가하지 않았다. 후보는 검토용 전체 높이2m로 정규화했으며, 실제 게임 종족별 스케일과 소켓 계약을 확정한 것은 아니다.

## 검증 결과

- 개별 입력 PNG29, Meshy 원본 GLB29, 최종 후보 GLB29, 지역 Blender 파일6, 실제 메시 렌더87.
- 후보 전체 **4,401~4,995 tris**, 모든 인물의 전체 소품 포함 합계가5,000 이하다.
- Blender 메시의 유한 좌표·UV를 확인했고, 내보낸 GLB의 인덱스 수로 삼각형 합계를 별도로 확인했다. 29개 GLB 모두 텍스처를 파일 내부에 포함한다.
- Blender 5.2.0 LTS의 `Standard / sRGB / Look None / Exposure 0 / Gamma 1 / Curves Off`로 정면·사선·후면을 렌더했다. 지역 보드로 외형을 검토했고, Freya·Orik은 라이브 Blender에서도 직선 손잡이를 확인했다.
- 기존 열려 있던 Blender 장면은 보존했고, 별도 검토 장면 및 격리 백그라운드 프로세스를 사용했다.
- 생성·검증 도구: [Blender 처리](../../../tools/review-npc-meshy-5k.py), [검토 보드/갤러리](../../../tools/build-npc-meshy-review.py).

## 미검증과 다음 담당

이 패키지는 외형 검토용 정적 모델이다. 리그·애니메이션·관절별 분할·무기 분리·소켓·충돌·Roblox 자산 업로드/권한·Studio·게시 클라이언트·실기기 성능은 미검증이다. Lumi/Wispkeeper의 투명·발광 표현도 현재 텍스처 외에 게임용 재질 처리가 필요하다. 정적 모델의 생성 성공을 게임 적용 완료로 처리하지 않는다.

다음 담당은 사용자 외형 검토다. 수용 이후 요청된 범위에서 모델링/엔지니어가 리그·소품 분리·게임 스케일을 준비하고 QA가 엔진 검증을 진행한다.
