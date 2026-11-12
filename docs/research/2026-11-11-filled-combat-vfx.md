# 면 중심 전투 VFX 강화 근거

TLT-033/057 · 2026-11-11. 사용자 후속 지시: 더 화려하게 개선하되 선과 함께 면으로 된 효과를 선호한다. 기존128개 개별 실루엣은 유지하면서 검기 면·원소 체적·폭발 코어·바닥 파도·바람 리본을 추가했다.

[Diablo IV VFX 개발 자료](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)의 가독성·효과 강도 위계를 제작 원리로 재확인했다. 출시 전 자료이며 현행 게임 자산이나 스킬 외형을 복제한 것은 아니다. 사용자 지시에 맞춰 큰 흰 선의 개수를 늘리는 대신 채워진 형태를 주 시각 정보로 삼았다.

[Roblox ParticleEmitter](https://create.roblox.com/docs/effects/particle-emitters)에서 입자 방출·수명·투명도·오버드로 비용을 확인했다. 설치된 Roblox 기본 fire/smoke/sparkles 텍스처를 사용해 별도 외부 자산 업로드 없이 짧은 일회성 방출을 구성했다. [CFrame](https://create.roblox.com/docs/reference/engine/datatypes/CFrame)의 기저 회전을 사용해 프로젝트의 삼각형/리본 면을 배치했다. 생성 면은 서버 판정에 참여하지 않는다.

Studio MCP의 `rbx-docs-search`, `rbx-perf-profiling`, `rbx-configs-experimentation` 본문을 실제 조회했다. ConfigService는 서버 실험/라이브 값 갱신용이며 이번 클라이언트 제작값에는 새 외부 설정 서비스를 도입하지 않았다. LibMP는 로드·백엔드 준비를 확인했으나 스냅샷의 유효 프레임이0개여서 GPU 성능 근거로 사용하지 않았다. 별도 네이티브 fixture의 Lua 갱신 비용과 실제 엔진 이미지로 구현을 확인했다.

최소 실험은128개 기술의 생성·좌표·정리·범위 의미 회귀, 채워진 검기의 면적/충돌 없음, 공유 면/외곽광/입자 상한, 대표12기술의 전후 픽셀 관찰이다. 추가 면 PC160/터치80개를 Hero와 Wind가 공유하며 외곽광 PC96/터치48개, 예약 입자 PC192/터치96개를 제한한다. 실기기·실제 멀티플레이·GPU P95와 위험 예고 가림은 별도 수용한다. [구현·이미지·검증](../evidence/hero-vfx-flourish-20261111/README.md).
