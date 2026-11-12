# 스킬별 VFX 검토 기준과 캡처 경로

TLT-033/057 · 2026-11-11. 기존 [Diablo IV·Lost Ark 비교](2026-11-11-hero-combat-vfx.md)의 가독성/동작 분리 원리를 스킬별로 적용한다. 작품의 고유 자산이나 전투 규칙은 복제하지 않는다.

[Diablo IV 개발 자료](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)의 전투 가독성·강도 구분 원칙은 계속 유효한 제작 참고다. 출시 전 자료이므로 현행 패치의 기술별 외형을 직접 확인한 것으로 보고하지 않는다. 이번에는 색보다 베기 방향·분기 형태·접지/공중·실제 발사점·서버 확정 중심을 먼저 검토했다.

[StudioCaptureService](https://create.roblox.com/docs/reference/engine/classes/StudioCaptureService)는 현재 설치본의 권한 요청에서 `Feature not supported yet`로 실패했다. [CaptureService의 공식 CaptureScreenshot](https://create.roblox.com/docs/reference/engine/classes/CaptureService/CaptureScreenshot)으로 얻은 임시 이미지와 EditableImage 픽셀 읽기는 실제 로컬 엔진에서 작동했다. 별도 로컬 Place에서 생산 렌더러의 효과를 고정한 뒤 캡처하고,320×240 샘플을 개별 PNG와 검토판으로 복원했다. MCP가 연결되지 않은 상태에서도 이 공식 엔진 경로의 실제 픽셀을 검토할 수 있었다.

위 결과는 합성 캐릭터 옆 VFX 단독 고정 프레임의 비교다. 전체 영웅 모션·실기기·실제 멀티플레이·저/고 그래픽 품질의 최종 수용을 대체하지 않는다. 잔상 시간은 엔진 검사/개별 제작값으로 검토했으며 고정 이미지로 동영상 품질을 통과시키지 않는다. 원본 이미지/검토판·스킬별 판정·입력 해시와 상세 제한은 [개별 리뷰 증거](../evidence/skill-vfx-individual-20261111/README.md)에 연결한다.
