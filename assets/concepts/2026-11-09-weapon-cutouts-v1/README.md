# 무기별 투명 PNG — 3D 모델링 참고용

2026-11-09 · TLT-028/029/032/041/052/073/082/084 · ART → 3D 제작

[개별 파일 보기](index.html) · [PNG16개 ZIP](TLT-Weapons-Transparent-16.zip) · [생성 프롬프트/출처/해시](manifest.json) · [알파 검사](alpha-report.json)

최종 승인 컨셉의 검·활·도끼·지팡이를 Rare/Epic/Legendary/Unique별로 분리한 **16개 개별 투명 PNG**다. 각 파일에 무기 하나만 있으며, 제목·등급명·프레임·다른 무기를 제거했다. 방패/방어구는 이번 무기 요청 범위에서 제외했다.

- 크기: 모든 파일1024×1536px, 8bit RGBA PNG.
- 파일명: `클래스_무기_등급.png`(예: `knight_sword_unique.png`).
- 실제 알파 채널을 유지하며 페이지의 체커는 검수용 CSS 배경이다. PNG에 체커·검정/흰색 배경을 합성하지 않았다.
- 내장 image_gen의 background-extraction 편집을 파일당1회 사용했다. 원본4보드를 직접 열고 각 등급의 해당 열을 참조했다. 프롬프트는 manifest의 품목별 `prompt`, 원본 경로/해시와 생성 도구 출력 경로도 함께 기록했다.
- 승인한 길이/손잡이·실루엣·장비군 색·장식을 유지하도록 분리/확대했다. 생성형 편집이므로 원본 픽셀을 그대로 잘라낸 파일과는 구분한다. 최종 승인 컨셉 정본은 덮어쓰지 않았다.

## 구성

| 클래스 | 무기 | 파일4개 |
| --- | --- | --- |
| Knight | Oathguard Sword / Unique: Rootwarden's Oath | knight_sword_rare/epic/legendary/unique.png |
| Elf Archer | Briarwatch Bow / Unique: Thornsong | elf_bow_rare/epic/legendary/unique.png |
| Dwarf Axe Thrower | Stonehearth Axe / Unique: Stonebreaker's Resolve | dwarf_axe_rare/epic/legendary/unique.png |
| Mage | Aetherweave Staff / Unique: Groveheart Staff | mage_staff_rare/epic/legendary/unique.png |

표의 `/`는 등급별 개별 파일4개를 줄여 표기한 것이며 실제 파일명에 슬래시는 없다.

## 검증 결과

`python3 scripts/validate_weapon_cutout_pngs.py --write-report` PASS. PNG 필터를 실제 해제하여16개의 알파 값을 검사했다. 각 파일에서 alpha=0 배경·최대alpha≥250·투명 면적40% 초과·불투명 무기 경계가 캔버스 끝에서 잘리지 않음을 확인했다. SHA-256·1024×1536·4클래스×4등급·중복 없는16파일·승인 원본4보드/정본 해시를 확인했다. 자세한 실제 투명 면적/알파 경계는 JSON 보고서에 있다. PNG 픽셀/알파를 코드로 편집하지 않았다.

브라우저의 실제 체커 배경 위에서 검과 활의 투명 표시/빈 공간을 육안 확인했고, 도구 출력으로16개 전부의 단일 품목·글자 제거·원형을 확인했다. `zipfile.testzip()` CRC·압축 내16PNG의 해시·갤러리 링크와 `git diff --check`도 확인했다.

이 파일은3D 모델링 입력용 참고 이미지다. 실제 메시·후면 구조·소켓·Studio 장착/게시 검증은 이번에 수행하지 않았다. 후속 Blender 비교는 **Standard / sRGB / Look None / Exposure0 / Gamma1 / Curves Off** 기준을 사용한다. 게임 빌드/VERSION·릴리스·원본 컨셉·기존 아이콘은 유지한다. 다음 담당은 ART의 실제3D 제작이며 상위 구현 티켓은 미완료다.
