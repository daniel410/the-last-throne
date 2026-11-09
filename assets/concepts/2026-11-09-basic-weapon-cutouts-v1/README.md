# 기본 무기 PNG — 최종 이미지 선택

2026-11-09 · TLT-028/029/032/041/052/084 · ART → 3D 제작

[전체 보기](index.html) · [PNG 12개 ZIP](TLT-Basic-Weapons-12.zip) · [선택·출처·해시](manifest.json) · [알파 검사](alpha-report.json)

사용자 최신 지시에 따라 **Traveler와 Tempered는 기존 Tempered 이미지로 통일하고, Veteran은 현재 게임 이미지로 사용**한다. 4무기 × 3단계의 파일명 12개를 유지하며 실제 서로 다른 그림은 8개다. 생성한 이전 Traveler/Veteran 시안보다 이 선택이 우선한다.

| 단계 | 선택한 이미지 | 크기 |
| --- | --- | --- |
| Traveler / Common | 기존 Tempered 검·활·도끼·지팡이와 바이트 단위로 동일 | 1024×1536 |
| Tempered / Common | 기존 Tempered 검·활·도끼·지팡이 | 1024×1536 |
| Veteran / Uncommon | 현재 게임 아이콘 아틀라스의 해당 클래스 무기 셀 그대로 | 256×288 |

Traveler/Tempered는 단순한 철검, 목제 곡궁·철제 끝마개, 철제 도끼날·나무 자루, 나무 지팡이·작은 철제 마개를 사용한다. 이전 Traveler 전용 목재 시안과 철제 날 수정안은 이번 공용 선택으로 대체한다.

## Veteran의 현재 게임 원본

`src/client/ItemSprites.luau`는 무기 아이콘을 클래스별 `classId .. "_weapon"` 셀로 선택한다. `src/shared/ItemSpriteAtlas.luau`의 `rbxassetid://135019494060990`에 연결된 로컬 원본은 `assets/ui/item-icons-v1/item-atlas.png`다. 첫 행의 검/도끼/활/지팡이 256×288 셀을 그대로 추출했다. 금색/보석 장식이 있는 현재 게임 외형을 유지하며 새 디자인으로 생성하지 않았다.

이미지 확대·재해석·리터치는 하지 않았다. 원본 셀 경계의 자투리나 가장자리 접촉도 현재 게임의 셀 선택을 그대로 보존한다. 이 저해상도 게임 아이콘은 고해상도 신규 모델링 도면과 구분한다. 단일뷰이므로 후면/메시 구조는 미확정이다.

기존 Tempered는 내장 image_gen 생성물이다. 이번 선택 변경에서는 생성 도구 호출 없이 파일을 재사용하고 기존 게임 아틀라스 셀을 추출했다. 과거 최종 프롬프트·생성 경로/해시는 [선택 이전 기록](selection-history.json), 현재 출처·셀 좌표·해시는 [manifest](manifest.json)에 있다. 원본 아틀라스는 변경하지 않았다. 갤러리·ZIP은 현재 선택과 일치한다.

## 검증·인계

`python3 assets/concepts/2026-11-09-basic-weapon-cutouts-v1/verify.py` PASS: Traveler=Tempered 4쌍의 바이트 동일성, 고유 이미지 8개, Veteran 원본 아틀라스 SHA-256, 12개 PNG 알파/치수/해시와 ZIP CRC/내장 해시를 확인했다. 새 공용 8파일은 잘림 검사, Veteran은 실제 게임 셀 경계 보존을 검사했다. Veteran 4개는 현재 원본 아틀라스를 열어 대응을 확인했다. 사용자 최종 미술 수용·실제 3D/게임 연결은 후속이다.

이번 범위는 PNG 제작 패키지 선택 반영이다. 런타임 소스·게임 빌드/VERSION·게시·장비 성능/보상·부모 티켓 상태는 변경하지 않았다. 다음 담당 ART의 실제 모델 제작, ENG의 게임 적용이다. Blender 제작/비교 시 **View Transform = Standard, Display = sRGB, Look = None, Exposure = 0, Gamma = 1, Use Curves = Off**를 적용한다. 색 텍스처는 sRGB, 데이터 맵은 Non-Color로 구분한다.
