# 최신 Meshy 4계열 방패

2026-11-09 · TLT-028/029/032/041/052/073/082/084.

사용자 지시로 기존 무기16종 가져오기에서 빠졌던 Traveler/Tempered/Veteran/Sentinel 방패4개를 Meshy 공개 UI에서 직접 내려받았다. 2026-11-09 16:55–17:00 America/Toronto의 동일 최신 텍스처 완료 묶음이다. `manifest.json`에 정확한 Task ID·생성시각·다운로드 파일·원본 해시를 고정했으며 자동 이름으로 등급을 추정하지 않았다. 원본은 총5,794삼각형이고 각1,309–1,510삼각형이다.

`source/`는 받은 GLB 그대로다. `prepared/`는 높이1.88studs·뒷면 손잡이 원점·정면 -Z로 정규화한 파생본이다. 형상/UV/텍스처는 유지했다. `geometry-report.json`과 `native-import.json`의 원본 표본48점×4를 EditableMesh와 대조했다. 가져오기에서 메시가 중심0으로 이동하고180도 회전하는 것을 보정했다. 기본 흰색·원본 color texture를 사용한다.

`renders/`와 `four-family-shields-review.blend`는 실제 모델 비교 렌더/장면이다. **Standard / sRGB / Look None / Exposure0 / Gamma1 / CurvesOff** 기준이며 색 텍스처는 sRGB다. Roblox 조명 검증과 구분한다. 라이브 Blender의 사용자 장면은 수정하지 않았다.

`runtime.rbxm`은4개 스크립트/PackageLink 없는 복제 템플릿이다. 프로젝트에서 ServerStorage.FourFamilyShieldModels로 연결한다. 각 모델은 Grip/Shield 두 부품과 GripSocket만 가진다. 업로드한 원본 패키지 자동 갱신에 의존하지 않는다. 수정된 런타임 복제본은 Git/LFS와 빌드에 고정한다.

직접 Model4건 업로드 Approved/Active. 자동 생성 Mesh4/Texture4는 `native-import.json`에 별도로 기록했다. `FourFamilyShieldVisuals`가 기존4개 offhand 정의만 연결한다. 서버 확정 TLTEquippedOffhand에 따라 실제 왼손 외형이 교체된다. 나머지 방패는 기존 TD 모델을 유지한다. 가격·수치·보유품·블록 판정·공격 범위·아이콘 변경 없음.

[업로드 응답](uploaded.json) · [검증/빌드/미게시](../../../docs/evidence/four-family-shields-20261109/README.md). 실제 계정·게시 클라이언트·실기기/파티 성능·최종 미술 수용은 후속이다.
