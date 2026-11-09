# 기본 무기 12종 — 3D 제작용 투명 PNG

2026-11-09 · TLT-028/029/032/041/052/084 · ART → 3D 제작

[전체 보기](index.html) · [PNG 12개 ZIP](TLT-Basic-Weapons-12.zip) · [최종 프롬프트·출처·SHA-256](manifest.json) · [알파 검사 결과](alpha-report.json)

사용자가 Traveler(Common), Tempered(Common), Veteran(Uncommon)의 단순한 최하위 무기와 Traveler의 나무활·나무지팡이·나무 도끼를 요청했다. 기존 고등급 무기 PNG와 같은 검·활·도끼·지팡이 구성으로 **4종 × 3단계 = 12개**를 신규 생성했다. 기존 컨셉을 교체하지 않는다.

| 단계 | 검 | 활 | 도끼 | 지팡이 |
| --- | --- | --- | --- | --- |
| Traveler / Common | 단순 철검·가죽 손잡이 | 목제 단궁·끈 시위 | 날과 자루 모두 나무·끈 결속 | 단순 나무 막대·끈 손잡이 |
| Tempered / Common | 기본 강철검 | 목제 곡궁·작은 철제 끝마개 | 철제 날·나무 자루 | 나무 몸체·작은 철제 마개 |
| Veteran / Uncommon | 중앙 홈·간단한 가드 | 적층 목재·소량 철제 보강 | 조금 정돈된 강철 날·보강 링 | 단순 목제 머리·철제 링 |

모든 무기는 보석·금장·룬·발광 없이 소박한 재료와 적은 부품으로 구성했다. Traveler 검의 재료는 사용자가 목재로 지정하지 않아 기본 철검으로 제작했다. 방패·화살·화살통은 포함하지 않는다.

내장 **image_gen**을 품목당 1회 사용했다. 모든 최종 프롬프트와 생성 원본 경로는 manifest에 있다. 원본 PNG를 그대로 복사했으며 코드로 픽셀/알파를 편집하지 않았다. 1024×1536px RGBA, 파일당 무기 하나이며 제목/라벨은 없다. 갤러리의 체커는 CSS 검수 배경이다.

검증: `python3 assets/concepts/2026-11-09-basic-weapon-cutouts-v1/verify.py` PASS. 기존 PNG 디코더로 12개 실제 알파·치수·잘림·해시, 3단계×4종 구성, ZIP CRC와 내장 파일 해시를 확인했다. 생성 결과에서 12개 단일 무기와 단순한 구조, Traveler 목재 3종을 육안 확인했다. 최종 미술 사용자 수용은 대기다.

이 산출물은 단일뷰 모델링 참고 이미지다. 실제 메시·후면·UV·소켓·Blender/Roblox 적용은 미검증이며 다음 담당은 ART의 3D 제작이다. Blender 작업/비교 시 **View Transform = Standard, Display = sRGB, Look = None, Exposure = 0, Gamma = 1, Use Curves = Off**를 적용한다. 색 텍스처는 sRGB, 데이터 맵은 Non-Color로 구분한다. 이번에는 Blender 렌더를 수행하지 않았다. 게임 빌드/VERSION·게시·성능/보상·기존 장비 정의와 부모 티켓 상태는 변경하지 않았다.
