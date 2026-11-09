# Starter 무기만 · 투명 PNG 4개

2026-11-09 · TLT-028/029/032/041/052/084 · ART → 3D 제작

[개별 파일 보기](index.html) · [PNG 4개 다운로드](TLT-Starter-Weapons-Only-4.zip) · [출처·매핑·해시](manifest.json) · [실제 알파 검사](alpha-report.json)

사용자의 Starter 무기만 요청에 따라 검·활·도끼·지팡이를 각각 하나의 PNG로 별도 전달한다. 방패·방어구·장신구는 포함하지 않는다. 각 파일은 1024×1536 RGBA이며 3D 모델링 참고용 단일 시점 이미지다.

`src/server/Inventory/InventoryRules.luau`의 현재 기본 지급 무기는 `classId .. "_weapon_traveler"`다. [최신 기본 무기 선택 기록](../2026-11-09-basic-weapon-cutouts-v1/README.md)에 따라 Traveler=Tempered 외형을 사용한다. 해당 Traveler PNG 4개를 바이트 단위로 그대로 복사했으며 신규 생성·재해석·리터치·알파 후처리를 하지 않았다. 기존 선택을 보존하기 위해 이전의 장식이 많은4계열 비교 컨셉과 혼합하지 않았다.

내장 imagegen으로 생성된 기존 선택본을 재사용했다. 이번 작업에는 새 imagegen 호출이 없으며 원본 프롬프트·생성 정보는 위 원본 패키지 manifest/selection-history에 있다. 이번 출처·정의ID·복사 방법·SHA256은 이 폴더 manifest에 기록했다.

`python3 assets/concepts/2026-11-09-starter-weapons-only-v1/verify.py --check`로 원본과 동일한4파일·고유 해시·RGBA 크기·실제 alpha=0 배경·거의 불투명한 장비·잘림 없음·ZIP CRC/내장 이미지 해시를 확인한다. 체크무늬는 HTML 미리보기 배경이며 PNG에 포함되지 않는다. 이미지 표시기가 투명 영역의 RGB를 보일 수 있으므로 알파를 지원하는 프로그램에서 연다. 검·활·도끼·지팡이의 원본 외형은 육안 확인했으며 브라우저 갤러리 렌더링 검증은 별도다.

메시·후면/측면 도면·리깅·실제 게임 적용·최종 미술 수용은 후속이다. 런타임/VERSION·이전 자산과 다른 사용자 변경은 수정하지 않는다. Blender 제작·가져오기·렌더 직전 View Transform = Standard, Display = sRGB, Look = None, Exposure = 0, Gamma = 1, Use Curves = Off를 확인하고 색 텍스처 sRGB/데이터맵 Non-Color/scene-linear 재질 입력을 지킨다. 이번 PNG를 Blender Standard 비교 렌더나 Roblox 조명 검증으로 보고하지 않는다. 다음 담당은 3D 제작·아트 리뷰 담당이다.
