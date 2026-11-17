# NPC 모델 게임 적용

작업ID `NPC-APPLY-20261117` · 사용자 승인29명 · Selene 제외.

## 변경과 근거

수정된 Aldric·Brann 해머를 포함한 사용자 승인5k 모델을 `NPCVisual` 생성 경로에 연결했다. 원본 표면·UV·텍스처는 유지하며 하체5본으로 호위 이동을 표시한다. 상체와 소품은 강체다. 서버의 루트·역할·별칭·프롬프트·개인 NPC 권한 코드는 변경하지 않았다. 새 모델의 이름표·스케일·정면·발 위치를 기존 계약에 맞췄다. 전체 소품 포함4,401~4,995 tris이며 Selene 경로와 원본은 유지했다.

게임 템플릿은 [runtime.rbxm](../../../assets/models/npc-meshy-5k-v1/runtime.rbxm), 출처와 Roblox ID는 [자산 패키지](../../../assets/models/npc-meshy-5k-v1/README.md)에 있다.

## 검증

- Blender Standard/sRGB에서29명 정지 표면·UV 오차3e-6 이내, 하체 이동 시 유한 좌표·접지·이동량을 확인했다. [원본 비교](skin-validation.json), [보행 보드](walk-review.jpg).
- Roblox 업로드29건 모두 Approved/Active. 실제 TLT Place에서 기존 MCP 권한이 정상임을 확인했다. 재시작 전에 로컬 Place0에서 발생한 권한 오류를 실제 권한 미설정으로 오인했으며, 권한 변경 없이 해결했다.
- 실제 Roblox 메시29개에서48점씩 원본 좌표와 일치, 삼각형 수 일치, 텍스처·5본 보존. [엔진 형상](native-geometry.json).
- 실제 업로드 모델29명, 생성·이름표·Atomic 스트리밍 설정·접지·충돌·클라이언트 보행·루트 보존·텔레포트 초기화 **1,887검사 통과**. [실제 모델 계약](runtime-contract.json).
- [Studio 전체 배치](studio-all.png). 원본 미리보기는 [승인 갤러리](../npc-meshy-5k-20261117/index.html).

## 범위와 미검증

이동은 하체의 최소 호위 보행이다. 손가락·표정·독립 무기·전투 애니메이션 리그는 포함하지 않는다. 게시 Roblox 클라이언트, 실기기 성능과 멀티플레이 수용은 미검증이다. 로컬/Studio 검증을 라이브 게시로 보고하지 않는다. 다음 담당은 빌드 QA 후 실제 플레이 수용이다.
