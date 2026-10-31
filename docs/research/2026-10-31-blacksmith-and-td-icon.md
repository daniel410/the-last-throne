# 대장간 분류·TD 목적지 아이콘

TLT-028/043/046/061/084 · 2026-10-31 확인

관찰: [Guild Wars 2 공식 Trading Post 소개](https://www.guildwars2.com/en/news/introducing-the-new-trading-post/)는 기대에 맞춘 품목 분류와 무기/방어구 직업 필터를 설명한다. 기존 조사와 함께 재사용한다. [Roblox SurfaceGui](https://create.roblox.com/docs/reference/engine/classes/SurfaceGui)와 [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel) 계약으로 월드 표지판에 이미지를 배치하고 원본 비율을 유지할 수 있다.

적용 제안/구현: 사용자 요청의 WEAPONS / ARMOR / ACCESSORIES를 BUY와 SELL 양쪽에 적용하고 ALL을 유지한다. 직업 제한은 구매와 장착을 구분해 기존 구매 가능/착용 자격 계약을 보존한다. 서버·클라이언트의 상점 허용 함수를 공유하고 Gold 구매만 허용한다. Lv10 신규 장비12종 가격/능력치는 시험값이며 정상 성장·장착 계약과 기존 보상은 변경하지 않는다.

TD 원본/적합성: 공유 레지스트리의 원본 프로젝트 ../throne-defense를 확인했다. 기존 TD ExperiencePortal.lua의 GameIcon 방식과 같은 방법으로 반대 목적지 TD의 실제 아이콘을 참조한다. Roblox universes API에서 Place103116209434833 → universe10770905829를 확인했고 thumbnails API는 Completed/TN3를 반환했다. 새 이미지 업로드 없이 해당 경험의 게시 아이콘을 읽는다. 외부 캐시 갱신 시 아이콘이 바뀔 수 있다. TD 운영 코드/잔액/이동 로직은 수정하지 않는다.

최소 실험: 전 품목 서버 구매/판매/동일 요청 재시도·잘못된 상점 거부, 실제 메뉴 분류/필터, 표지판 아이콘/원본비율/영문 제목 경계. 비용은 소형 SurfaceGui 이미지1개이며 실제 기기와 게시 클라이언트 수용은 후속이다.
