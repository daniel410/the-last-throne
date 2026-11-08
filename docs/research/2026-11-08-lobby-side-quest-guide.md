# 로비 사이드 추천 구현 근거

2026-11-08 · TLT-028/031/041/050/052/057/084 · RES/ENG/DES → QA

[기존 Diablo 우선 비교와 NPC 의뢰/현장 발견 구분](2026-11-07-lobby-side-quest-return.md)을 재사용한다. NPC가 소문을 알려 주되 발견/전투를 대신하지 않는 방향을 유지했다. 느낌표/물음표와 적극 추천은 사용자 요구이며 Diablo 현행 UI를 복제하거나 인기/유지율 근거로 주장하지 않는다.

2026-11-08 [Roblox BillboardGui 공식 API](https://create.roblox.com/docs/reference/engine/classes/BillboardGui)에서 Adornee·AlwaysOnTop·MaxDistance·Size/StudsOffset 속성을 확인했다. 개인 클라이언트가 선택 영웅의 저장 진행을 투영해 Tessa 표식을 만들고 서버 공유 NPC 상태를 바꾸지 않는다. [공식 접근성 지침](https://create.roblox.com/docs/production/publishing/accessibility)은 색과 기호/텍스트 병기·음향 외 정보·모션 선호를 안내한다. 기호+영어 라벨과 정적 강조를 적용했고 지속 점멸·소리 전용 안내는 추가하지 않았다.

대안인 저널 목록만 강화는 NPC의 적극 안내 요구를 충족하기 어렵다. 기존 Tessa의 새 대화 프롬프트·개인 표식·귀환 알림·추천/전체 목록·위치 안내를 연결했다. 기존 지도에는 같은 상태의 Tessa 바로가기를 둔다. 보고 가능한12개 목표는 현장 전투/선택 분기를 끝낸 뒤 기존 원정/초회 보상 경로를 호출한다. 새 보상량·무료 보급·유료 지원 조건을 만들지 않았다.

비용/위험은 개인 상태 일치·계정 공용 저장 펜스·응답 유실/구원정 보상·UI 축소/포커스·스트리밍 NPC 재부착이다. 최소 검증은12개 의뢰의 현장/로비 지급 동일성·중복/저장불명 복구, 세 화면 크기의 실제 TD GUI/표식, NPC 서버 거리 검사다. 실제 사용자의30초 내 인지·재미·실기기/게시 계정 저장·Teleport는 후속이며 자동 성공을 주장하지 않는다. [구현/검증 증거](../evidence/lobby-side-quest-guide-20261108/README.md).
