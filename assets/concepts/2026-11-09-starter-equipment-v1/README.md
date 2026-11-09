# 시작 장비 4계열 추가 컨셉

2026-11-09 · TLT-031/032/033/057/084 · 디자인 산출물 · 사용자 최종 수용 대기

[전체 갤러리](index.html) · [PNG 묶음](TLT-Starter-Equipment-Concepts.zip) · [프롬프트·입출력 해시·정의 매핑](manifest.json)

## 변경과 근거

사용자가 요청한 Traveler(Common), Tempered(Common), Veteran(Uncommon), Sentinal(Rare)의 무기·장비 컨셉을 제작했다. Sentinal은 현재 카탈로그의 Sentinel로 해석했으며 런타임 이름은 변경하지 않았다. 반지·목걸이는 제외했다.

검·활·도끼·지팡이·방패·기사 헬멧·드워프 헬멧·후드·코트·마법사 로브·장갑·부츠의 비교 PNG 12장이다. 각 보드 4계열로 외형 시안 48개이며, 실제 카탈로그 정의는 40개다. 머리 슬롯의 동일 정의에 기사 헬멧/드워프 헬멧/엘프·마법사 후드 외형을 제안한다. 새 아이템ID나 클래스별 방어구 능력치를 만들지 않았다.

기준은 `src/shared/EquipmentFamilies.luau`, `docs/production/equipment-four-tier-reorganization-2026-11-09.md`, 기존 승인 `2026-11-08-equipment-rarity-v2`다. 기존 리서치 `docs/research/2026-11-08-equipment-rarity-visuals.md`의 색상 외 구조·재료 단계 구분 원칙을 활용했다. 높은 등급의 원본은 미술 스타일·비율 참고이며 시작 장비에 왕관·날개·과도한 금장식을 복사하지 않았다.

| 계열 | 통일 색상·재료 | 형태 방향 |
| --- | --- | --- |
| Traveler · Common | 베이지 천·호두색 가죽·무광 철·작은 청록 포인트 | 기본 구조·단순 봉제와 고정구 |
| Tempered · Common | 청회색 천·갈색 가죽·깨끗한 강철 | 정돈된 금속 밴드와 보강 |
| Veteran · Uncommon | 올리브 천·갈색 가죽·강철·절제된 브론즈 | 겹판과 실용 보강·작은 제작 문양 |
| Sentinel · Rare | 남색 천·은색 강철·작은 파란 인레이 | 경비대 문양·일체화된 금속 테두리 |

기사·드워프는 각진 판금과 능선이 있는 헬멧을 유지했다. 후드는 낮고 부드러운 정수리다. 기존 승인 무기 길이·그립 비율을 참고했고 동일 계열은 클래스에 관계없이 동일 재료 팔레트를 지시했다. 팔레트 숫자는 제작 목표이며 AI 이미지의 조명 포함 픽셀 색상 일치 측정값은 아니다.

2026-11-09 후속 리뷰: Veteran·Sentinel 도끼는 나무 자루 대신 강철 자루를 사용한다. Veteran의 브론즈·올리브와 Sentinel의 은색·남색 포인트를 유지했다. 현재 비교 보드는 `boards/axe-v2-metal-shafts.png`이며 이전 보드와 해시는 보존했다. [투명 개별 무기·방패20개](../2026-11-09-starter-cutouts-v1/index.html)에도 반영했다.

## 검증과 한계

내장 imagegen 스킬과 이미지 도구로 기존 승인 보드를 참조해 생성했다. 원본은 기본 생성 경로에 보존하고 이 폴더에 복사했다. 프롬프트·참조 경로·SHA256·출력 크기·카탈로그 매핑은 manifest에 기록했다. 각 보드를 육안 검토해 범주, 네 계열 표기, 전체 형태, 헬멧/후드 구분과 색상 방향을 확인했다.

검증 명령:

```sh
python3 scripts/build_starter_equipment_concepts.py --check
python3 scripts/build_equipment_rarity_concepts.py --check
```

결과: 신규 PNG 12장/외형 48개/고유 정의 40개, 등급 순서, 참조 해시, 갤러리·ZIP CRC와 이미지 해시를 확인했다. 기존 승인 40개 보드의 기준 검사는 유지된다.

이번 산출물은 배경 있는 비교 컨셉이며 투명 개별 PNG·실제 3D·아이콘·리깅·Roblox 적용·사용자 최종 수용은 후속이다. Blender 렌더가 아니므로 Standard 비교 렌더나 Roblox 조명 검증으로 보고하지 않는다. 후속 Blender 제작/가져오기/렌더는 View Transform = Standard, Display = sRGB, Look = None, Exposure = 0, Gamma = 1, Use Curves = Off를 명시하고 재확인한다. 색 텍스처 sRGB/데이터맵 Non-Color 및 scene-linear 재질 입력 규칙을 따른다.

다음 담당은 사용자 아트 리뷰 후 디자인·3D 담당이다. 기존 승인 컨셉·투명 무기 원본·런타임·VERSION은 변경하지 않는다. 게임 빌드나 릴리스 태그를 생성하지 않는다.
