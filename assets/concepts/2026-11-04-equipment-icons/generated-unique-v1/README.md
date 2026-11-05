# Unique 장비 아이콘 40종

2026-11-05 · TLT-028/029/044/045/052/082/084 · ART/DES → ENG/QA

사용자 요청으로 각 Legendary 원본을 개별 참조한 Unique40종을 생성했다. [Unique40 보드](index.html) · [네 등급160종 비교](../comparison.html) · [전체 모아보기](contact-sheet.png) · [검/도끼/지팡이 교정 전후](weapons-review.png). 공통11·기사8·엘프7·드워프7·마법사7이며 Unique는 모두 비세트다. 원본 Rare/Epic/Legendary PNG는 보존한다. 실제 게임 정의/효과/장착3D모델 수와 이미지 수를 구분한다.

더 큰 보스 보석·백금/금 세공·빙정·뿌리/잎·거미줄 문양·화산석으로 Legendary보다 강하고 귀한 외형을 의도했다. 세 등급을 무조건 같은 장식으로 묶지 않고 품목별 고유 이름/보스 모티프를 반영했다. 파일/표시 식별자는 `Unique_Knight_Rootwardens_Oath.png`, `Unique_Mage_Groveheart_Staff.png`처럼 등급_클래스_이름으로 통일한다. 글자/등급 테두리는 PNG에 굽지 않고 보드와 런타임 텍스트에서 표시한다.

## 사용자 교정과 원본 보존

검이 휘어 보인다는 사용자 리뷰에 따라 기사 검을 정면 수직 구도로 다시 생성했다. 칼끝·칼날 중심·가드·손잡이·끝장식이 한 축에 놓이는 형태를 육안 확인했다. 이어 짧고 뭉툭한 무기 비율 지시에 따라 도끼 머리/지팡이 장식을 줄이고 긴 자루가 드러나는 정면 실루엣으로 교정했다. 활의 시위는 유지한다. 일부 활·장신구·지팡이에 생성된 흰 안개/광채를 image_gen 편집/재생성으로 제거했다.

초기40회와 추가 교정8회, 총48번의 개별 image_gen 호출 결과 중 최종40종을 선택했다. 선택 전 이미지는 superseded/에 보존한다. PNG를 Python 등으로 잘라 늘리거나 뒤틀지 않았다. 원본 픽셀 그대로 저장하고 비교 모아보기만 macOS AppKit으로 별도 렌더했다. 기사 검 최종본은1145×1374, 다른39종은1254×1254다. 보드는 원본 비율을 유지해 정사각형 슬롯 안에 표시한다.

## 착용 레벨과 드롭

유니크 최소 착용 레벨은 **Lv60 확정**이다. 중간 Lv50 지시는 최신 Lv60 지시로 대체한다. **Hell 전용 드롭**, Legendary보다 높은 기본치+고정 효과1개, MP/효과 비강화 방향을 유지한다. 이전 Lv10 비교용 기본치/강화값은 statReferenceTier=10 및 statsStatus로 표시하고 **Lv60 실전 능력치로 승인하지 않는다**. Lv60 성장 예산 재산정·실제 효과/장착/드롭은 후속이다. 기존 proposalId는 참조 호환을 위해 유지하고 실제 값은 requiredLevel=60, 후보 definitionId는 t60으로 기록했다. 기존 보유품/상품/이야기 보상을 바꾸지 않는다.

## 검증과 다음 담당

- generation.json: 실제 프롬프트·Legendary 참조/해시·원본 출력·선택본SHA256/치수·교정 입력/출력 이력·보스·등급/클래스/이름/Lv60 메타데이터.
- `python3 scripts/build_equipment_icon_boards.py`: 40개 단독 보드4개와160개 비교를 재생성. 기본 비교는 Legendary/Unique이며 전체 등급·클래스/이름·48px/배경 전환을 제공한다.
- `python3 scripts/validate_equipment_icon_assets.py`: 160개 고유 PNG/이름·40계열×4등급·해시·참조·메타데이터·로컬 링크 검사 PASS.
- `python3 scripts/validate_unique_equipment_plan.py`, `python3 scripts/validate_equipment_stats_plan.py`, `python3 scripts/validate_boss_equipment_drop_policy.py`: Lv60 착용·Lv10 수치 참조 분리, 기존120종 수치 보존, Hell 전용·금지 모드0% 등 PASS.
- AppKit 디코딩/알파와 전체 모아보기를 확인했다. alpha-check.json에서 네 모서리 중4품목의 한 모서리에1/255 알파 잔여가 있고 나머지는0이다. 이는 엄격한 전체 알파 청결 통과를 뜻하지 않는다. 최종 승인 TD 프레임48/64px·실제 Roblox 이미지 로딩/권한·모바일/패드 가독성은 후속이다.

다음 담당은 DES/사용자 미술 수용 → ART 잔여 정리/업로드 → PLAN Lv60 수치 → ENG 카탈로그/효과/보스 드롭 → QA 실계정/기기 수용이다. 이번에는 자산/계획/검사만 저장하며 게임 빌드·VERSION·Place 게시·릴리스 태그를 만들지 않는다.
