# 부유 지형·식생과 내비게이션 가림 교정

2026-11-04 · TLT-028/031/057/061/062/063/064/065/084 · ENG → QA · 0.71.3 · 로컬 수정·미게시.

사용자 첨부2장(Deepwood의 머리 높이 잔디 판·도로 위 분리 덤불)을 기준으로 공통 생성 코드를 확인했다. TD ForestKit의 ContinuousTerrain/DeepCliff/BankVegetation은 재질별로 여러 섬을 합친 메시다. 이를 지역 크기에 맞춰 늘리거나 개별 덤불처럼 반복 배치하면 Terrain의 낮은 접근로 절삭과 일치하지 않고, 하나의 피벗만 접지돼 부유 표면·분리된 식생이 남는다. 원본 공유 자산은 보존하고5에픽44구역의 해당 반복 배치를 제거했다. 연속 지형은 기존 Terrain과 서버 바닥이 담당한다.

나무·소형 바닥 장식·장식 길은 절삭 이후의 실제 Terrain/서버 바닥에 접지한다. 다른 지역으로 돌아가는 목표를 현재 지역에서 장식 도로로 직접 잇던 경우도 제한했다. 전투/상호작용/스폰 좌표·보상·물리 콜라이더는 보존한다. 캐시 ArtVersion은5로 올려 이전 생성물을 재사용하지 않는다.

길 안내는 기존 금색 갈매기 화살표의 형태·직선 방향·설정·도착 유지 계약을 따른다. BoxHandleAdornment의 AlwaysOnTop/ZIndex로 가려짐 없는 표시를 겹치고 숨김/사망/훈련/목표 해제/정리를 동기화한다. 바닥 투영에는 smooth Terrain과 기존 전망대·경사로·후반 Ground도 포함한다. API 근거: [HandleAdornment](https://create.roblox.com/docs/reference/engine/classes/HandleAdornment), [Raycasting](https://create.roblox.com/docs/workspace/raycasting) (2026-11-04 확인). 명확한 배치/렌더 결함 수정으로 별도 RPG 기능 비교 조사는 생략했다.

검증 결과·고정 빌드/소스/해시·한계는 마감 후 아래 기록으로 연결한다. 부모 티켓은 In Progress를 유지한다. 실제 게시 클라이언트·모바일 실기기·다인 성능·최종 사용자 미술 수용은 별도다. 기존 사용자 Studio/다른 미커밋 파일·TD 운영·게시·상품/저장은 변경하지 않는다.
