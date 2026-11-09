# 시작 무기·방패 투명 PNG 20개

2026-11-09 · TLT-028/029/032/041/052/073/082/084 · 디자인 산출물

[개별 PNG 갤러리](index.html) · [전체 ZIP](TLT-Starter-Weapons-Shields-Transparent-20.zip) · [프롬프트·매핑·해시](manifest.json) · [알파 검사](alpha-report.json)

Traveler(Common), Tempered(Common), Veteran(Uncommon), Sentinel(Rare)의 검·활·도끼·지팡이·방패를 각각 한 파일로 제작했다. 총 20개, 각 1024×1536 RGBA PNG이며 장갑·헬멧·부츠·코트·로브·장신구는 포함하지 않는다.

후속 사용자 리뷰로 Veteran과 Sentinel 도끼의 노출된 나무 자루를 연속된 강철 자루로 변경했다. Veteran은 브론즈 고정구·올리브 그립, Sentinel은 은색 고정구·남색 그립을 유지한다. 갤러리와 ZIP은 `*_axe_metal_shaft.png`를 사용하며 옛 나무 자루 PNG는 archive에 보존하고 ZIP에서 제외했다. 비교 컨셉 도끼 보드도 v2로 교체했다. 직접 Veteran PNG 편집은 도구의 입력 폭력 필터에 거부됐고, 수정된 비교 보드를 참조한 별도 개별 생성은 성공했다. 상세 경로·프롬프트·거부 이력은 manifest에 기록했다.

사용자 요청을 근거로 내장 imagegen 스킬/이미지 도구에 신규 [비교 컨셉](../2026-11-09-starter-equipment-v1/index.html)의 해당 열만 지정해 투명 개별 시안을 생성했다. 형태·길이/그립·재료·문양·계열 색상을 참조했으며 이미지 재생성이므로 원본 보드의 픽셀을 그대로 잘라낸 결과는 아니다. 원본 생성 파일은 기본 경로에 보존하고 프로젝트에 복사했다. 배경 제거용 별도 픽셀 편집이나 알파 후처리는 하지 않았다.

각 보드의 해당 계열과 개별 이미지의 범주·재료·실루엣을 육안 검토했다. `python3 scripts/build_starter_cutouts.py --check`는 PNG를 읽어 RGBA/실제 alpha=0 배경/거의 불투명한 장비/장비 끝의 잘림 없음/20개 고유 이미지/참조 해시/ZIP CRC와 내장 PNG 해시를 검증한다. 미리보기의 체크무늬·흰색·어두운 배경은 HTML이며 원본 PNG에는 포함되지 않는다. 투명 픽셀에 RGB 값이 남을 수 있으므로 알파를 지원하는 프로그램에서 사용한다.

Sentinel 활의 초기 결과는 완전 투명 비율이32.62%이고 배경의 낮은 알파 잔여량이 커서 재생성했다. Traveler 도끼도 낮은 알파 잔여 픽셀을 줄이도록 재생성했다. 이전 생성 경로·교정 이유는 각 manifest 기록의 attempts에 남겼다. 로컬 HTML 브라우저 미리보기는 브라우저의 file URL 정책으로 열리지 않았으며 브라우저 렌더 검증으로 보고하지 않는다. 파일의 실제 알파 검사는 별도 Python PNG 디코더로 수행했다.

이 파일은 3D 모델링을 위한 단일 시점 참고 이미지다. 메시·UV·리깅·후면/측면 설계·실제 Roblox 적용과 사용자 최종 미술 수용은 후속이다. 게임 소스·VERSION·기존 승인 컨셉은 변경하지 않는다. Blender 렌더나 실제 Roblox 조명 검증으로 보고하지 않는다.

다음 담당은 3D 제작/아트 리뷰 담당이다. Blender 제작·가져오기·렌더 직전에 View Transform = Standard, Display = sRGB, Look = None, Exposure = 0, Gamma = 1, Use Curves = Off를 재확인한다. 색 텍스처 sRGB, 데이터맵 Non-Color 및 scene-linear 재질 입력을 지킨다.
