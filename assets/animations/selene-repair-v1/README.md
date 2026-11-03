# Selene 원형 보존 리그 수정본

TLT-016/057/061/072/084 · 2026-11-03

TD `meshy-priests-refresh-v1/derived/nun/rest.glb`를 `source-rest.glb`로 고정했다. 원본 SHA-256은 validation.json에 있다. 기존 모델의 손상된 AI6분할 결과는 입력으로 사용하지 않는다. 원본3메시의 표면·UV·텍스처를 유지하고 중복 정점을 용접해15뼈 가중치를 추가했다. 피부 최대4영향·가중치 합1, 원형2,989삼각형을 검사한다. GLB 정지 표면 대조 허용 정밀도는 소수4자리이며 이미지 바이트 해시는 동일하다.

`tools/author-selene-repair-blender.py`는 별도 Blender 장면을 생성하고 원본을 가져온다. 같은 이름의 검토 장면이 있으면 덮어쓰지 않고 중단하므로 재현에는 깨끗한 Blender 파일을 쓴다. 기존 사용자 장면을 포함하지 않도록 활성 장면/선택만 내보낸다. Idle·Walk·Heal·Protect·Cleanse·Return은 Blender 검토 액션이며 PNG14장은 정면/측면 포즈 검토다. **업로드 GLB에는 애니메이션 트랙이 없다.** 게임 동작은 SeleneSkinMotion의 클라이언트 Bone.Transform이다.

사용자가 새 모델의 Me 계정 업로드와 로컬 연결을 승인했다. 실제 가져온 모델과 메시 ID는 ../../shared/selene-repaired/manifest.json, 실행 파일은 runtime.rbxm이다. 원본 GLB에 포함된 이미지와 별개로 런타임은 기존 TD 텍스처113363552204383을 고정한다. 새로 가져온 이미지의 Roblox 렌더가 얼굴/장식과 맞지 않는 문제를 이 정본 텍스처로 교정했다.

검사: `python3 tools/check-selene-repair.py`. Blender 검토·엔진검사·게시 클라이언트·실기기 수용은 서로 다르다. 최종 상태는 ../../../docs/evidence/selene-repair-20261103/README.md를 따른다.
