# 로브와 맞춘 TD 기반 마법사 모자 4종

2026-11-11 · TLT-031/032/033/057/084 · 디자인 PNG 완료 / 사용자 미술 수용 대기

[개별 미리보기와 로브 비교](index.html) · [PNG 4개 ZIP](TLT-Mage-Hats-4-PNG.zip) · [프롬프트·원본 경로·SHA256·검증](manifest.json)

사용자 요청으로 TD Arcanist의 넓은 챙·휘어진 뾰족 정수리·각진 스타일을 참고해 Traveler(Common), Tempered(Common), Veteran(Uncommon), Sentinel(Rare)용 모자를 각각 제작했다. 직접 참조한 TD 원본은 `../throne-defense/assets/concepts/towers/blocky-v1/mages/arcanist.png`이며, 공유 레지스트리의 Mage 초상 원본도 육안 확인하고 현재 SHA256이 등록값과 같음을 확인했다. 공통 TD 세계관 자산의 로컬 파생 컨셉 제작이며 TD 파일은 편집하지 않았다.

두 번째 이미지 참조는 기존 `2026-11-11-starter-armor-cutouts-v1/<family>/robe.png`다. Traveler=베이지/청록 천 테두리/가죽 버클, Tempered=청회색/강철 테두리, Veteran=올리브/강철/브론즈/모루 문양, Sentinel=남색/은색/작은 파란 보석/탑 문양을 맞췄다. 내장 image_gen으로 한 계열당 한 번씩 생성했고 투명 알파 원본을 그대로 복사했다. 기존 후드·로브와 런타임 정의는 유지했다.

검증: Pillow로 PNG 4개 RGBA·alpha=0 픽셀·alpha>128 실루엣의 사방 여백·SHA256을 확인했다. 밝은 회색 배경의 실제 알파 합성 검토본에서 네 모자와 대응 로브를 나란히 비교해 범주·전체 모자·색/재료 방향·장식을 확인했다. ZIP CRC와 내부 PNG 해시 검사도 통과했다. 이것은 제작용 단일 시점 참고 PNG이며 실제 3D·리깅·Roblox 적용·사용자 미술 수용은 미검증이다. 다음 담당은 사용자 리뷰 후 3D 담당이다.

Blender 제작/비교 시 View Transform=Standard, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off를 적용한다. 색 텍스처=sRGB, 데이터맵=Non-Color이며 scene-linear 재질 입력 규칙을 지킨다. AI PNG는 Standard 렌더나 실제 Roblox 조명 검증의 증거가 아니다. 게임 빌드·VERSION·게시·릴리스 태그 변경은 없다.
