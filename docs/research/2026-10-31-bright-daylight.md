# 밝은 파란 낮 조명 조사

2026-10-31 · TLT-031/050/061/084 · 리서치 → 디자인/엔지니어/QA

대상은 로비와 Deepwood의 PC·터치·패드. 기존 [Deepwood 밝은 시야 조사](2026-10-30-grounded-deepwood.md)는 근거리의 짙은 안개와 녹색 필터를 피하고 먼 배경만 밝게 처리하는 기준을 남겼다.

Roblox [전역 조명](https://create.roblox.com/docs/environment/lighting)과 [야외 조명](https://create.roblox.com/docs/tutorials/use-case-tutorials/lighting/enhance-outdoor-environments)(2026-10-31 확인)은 환경광과 시간대 및 대기 밀도의 역할을 설명한다. [ColorCorrectionEffect](https://create.roblox.com/docs/reference/engine/classes/ColorCorrectionEffect)는 채도·밝기 조정이 렌더 품질에 따라 다르게 보일 수 있다고 설명한다. [Atmosphere](https://create.roblox.com/docs/reference/engine/classes/Atmosphere)는 거리 안개를 대체한다. 타 게임 화면의 최신 비교나 직접 플레이는 수행하지 않았다.

적용 가설: 파란 기본 하늘, 더 밝은 실내/실외 환경광과 절제한 채도 보정으로 화사한 모험 분위기를 강화한다. 비용과 위험은 밝은 오브젝트의 클리핑, 색상 구분·피격 표시와 원거리 가독성 저하다. Atmosphere를 제외해 기존 먼 거리 안개와 장식물 표시 거리 계약을 보존한다. QA는 서로 다른 그래픽 품질·시간대/화면, 밝은 장비와 전투 표시, 로비/숲/훈련 전환에서 시각적 차이를 확인한다. 시각적 선호·실기기 성능은 미측정이다.
