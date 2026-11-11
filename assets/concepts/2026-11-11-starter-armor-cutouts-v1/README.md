# Starter 방어구 투명 PNG 24개

2026-11-11 · TLT-031/032/033/057/084 · 3D 제작 참고 이미지 완료 / 사용자 미술 수용 대기

[전체 미리보기](index.html) · [24개 PNG ZIP](TLT-Starter-Armor-24-PNG.zip) · [프롬프트·참조·해시·알파 검사](manifest.json)

사용자 요청에 따라 Traveler(Common), Tempered(Common), Veteran(Uncommon), Sentinel(Rare) 각각 후드·기사형 헬멧·코트·Mage 로브·장갑·부츠를 개별 투명 PNG로 제작했다. 장갑·부츠는 한 파일에 좌우 한 쌍이다. 무기·방패는 제작하지 않았다. 기존 2026-11-09 starter 비교 보드의 각 계열 외형을 참조했고 원본은 보존했다. 내장 image_gen으로 생성했으며 전체 프롬프트와 참조 SHA256은 manifest에 기록했다.

## 검증

Pillow로 PNG 24개의 RGBA 모드, 실제 alpha=0 픽셀, alpha>128 실루엣의 사방 여백, 크기와 SHA256을 검사했다. 밝은 회색 바탕에 실제 알파 합성한 4계열×6종 검토본에서 배경 제거·범주·형태·장갑/부츠 쌍·기존 계열별 색상 방향을 육안 확인했다. 일부 도구 미리보기는 투명 픽셀의 RGB 정보를 배경처럼 보여 주지만 실제 합성에서는 배경이 투명하다. 최종 파일은 생성 원본의 알파를 그대로 보존한 사본이다. 초기 배경 수정 시도본은 최종 채택하지 않았다. ZIP CRC와 내부 PNG 해시도 검사했다.

## 후속

실제 3D 모델·정사영 도면·후면 구조 확정·리깅·Roblox 적용은 이번 범위에 포함하지 않는다. 다음 담당은 사용자 아트 리뷰 후 3D 제작 담당이다. Blender 비교 기준은 View Transform=Standard, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off다. 색 텍스처=sRGB, 데이터맵=Non-Color를 지킨다. AI 이미지 생성은 Blender Standard 렌더나 Roblox 조명 검증의 증거가 아니다. 런타임·VERSION·게임 게시·릴리스 태그 변경은 없다.
