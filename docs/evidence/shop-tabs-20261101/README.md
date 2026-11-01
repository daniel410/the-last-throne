# Potion Shop 이름과 데스크톱 상점 버튼 정렬

2026-11-01 · TLT-028/043/061/084 · ENG/DES → QA · 0.58.12 로컬 시험판·미게시

사용자 요청과 철자 확인에 따라 로비 메뉴 캡션·상세창 제목·실제 상점 간판을 POTION SHOP으로 통일했다. 안정ID ItemShop/items 및 기존 취급 품목·거래 코드는 유지한다.

Potion Shop과 Blacksmith의 데스크톱 BUY/SELL을 잔액 표시 아래 별도 중앙 행에 배치했다. 카테고리 그리드가 Name 기본 정렬로 생성 순서를 무시하던 원인을 고쳐, Potion Shop은 POTIONS → ACCESSORIES → ETC, Blacksmith는 WEAPONS → ARMOR → ACCESSORIES로 고정했다. Diamond Shop의 기존 이름 정렬·원본 TD 프레임/버튼/아이콘은 유지한다. 모바일의 짧은 상세창은 기존 BUY/SELL 배치를 유지한다. 명확한 정렬 결함 교정으로 별도 신규 사례 조사 없이 기존 공통 UI 계약을 적용했다.

Studio Client에서 실제 모듈/TD 자산으로1280×720 → 750×323 → 1280×720 크기의 fixture를 생성해68개 검사 통과: 두 상점의 실제 카테고리 X좌표 순서·한 행·제목·BUY/SELL 비중첩, 데스크톱 버튼 쌍의 창 중심 오차1px 미만, 잔액 행 분리 및 상품 목록 비중첩. 실제 화면으로 두 데스크톱 창을 확인했다. fixture는 검증 후 제거한다. 호스트 크기 검사이며 실제 모바일 기기/Device Simulator 수용을 뜻하지 않는다. [재현 코드](verify.luau) · [도구 결과](studio-result.json).

정확한 고정 소스 커밋·빌드 명령/산출물 해시는 build.json에 남긴다. git diff --check 통과. 게시·실기기·실제 거래 회귀는 미검증. 다음 담당 QA는 실제 데스크톱에서 두 창의 카테고리 전환/BUY/SELL 및 모바일 기존 배치를 확인한다.
