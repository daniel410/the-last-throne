# 스토리 몬스터 크기 조정 (2026-10-31)

- 작업: 트레이닝 오크·오우거와 스토리 개체의 크기를 일치시키고 Frozen Vale / Ember Caldera 개체를 오크와 비교한다.
- TD 원본 `TargetHeight` 기준 트레이닝 오크는 6.9 studs, 오우거는 약 10.33 studs다. 스토리에서는 각각 4.6, 약 6.05 studs였다. 스토리 스폰에 트레이닝과 같은 리그 및 시각 배율을 적용했다.
- 지역별로 작은 늑대·임프·슬라임과 큰 트롤·골렘을 구분하고, 왕·보스가 관련 일반 개체보다 커지도록 조정했다. 충돌과 사거리 영향을 제한하기 위해 다른 지역의 전투 리그는 유지하고 TD 시각 배율만 변경했다. 보상·체력·공격력은 변경하지 않았다.
- [Roblox Model 문서](https://create.roblox.com/docs/reference/engine/classes/Model/ScaleTo)는 모델 배율이 크기뿐 아니라 위치·관절 등에도 영향을 준다고 설명한다. 이 프로젝트는 별도의 전투 리그와 TD 시각 메시를 사용하므로 기존 생성 경로에서 각각의 배율을 지정했다.
- 검증: `python3 tests/story-monster-sizing.spec.py`는 TD 모델 23종의 기준 높이와 트레이닝 크기, 지역별 크기 관계를 확인한다. `lua tests/deepwood-encounter-balance.spec.lua`는 전투 밸런스 계약을 회귀 검사한다.
- 실제 플레이 화면의 시각 수용, 대형 개체와의 근접 전투 및 지형 충돌은 Roblox 클라이언트에서 추가 확인이 필요하다. 다음 담당: 게임플레이 QA.
