# 강화 재료 아이콘

2026-11-03 · TLT-028/031/043/084 · ENG/DES

사용자 요청으로 기존 아이템 아틀라스의 입체감·선명한 면·하이라이트에 맞춘 빨간 Enhancement Gem과 보라색 Magic Stone을 built-in ImageGen으로 각각 생성했다. 새 투명 PNG를 보존하며 TD 원본은 변경하지 않았다. 전체 프롬프트는 `prompt.txt`, 크기/알파/해시/업로드ID는 `manifest.json`에 기록한다.

`ItemSpriteAtlas.images`와 `ItemSprites.create`를 연결해 `ItemArtwork.create`를 사용하는 가방·상세·대장간에서 두 재료를 독립 이미지로 표시한다. 기존 아이템 아틀라스와 재료ID·수량·강화/교환 규칙은 유지한다.

검증: Luau 컴파일 성공, Lua 생성자 스텁에서 두 재료의 Image/DefinitionId/SpriteKey/Fit/투명 배경과 기존 광석 아틀라스·미등록 항목 fallback 통과. PNG 두 파일 모두1254×1254·알파0~255 확인. `git diff --check` 통과. 별도 게임 빌드/버전 증가·Place 게시는 수행하지 않았다.

Roblox Studio upload_image는 두 자산ID를 반환했으나 로비 Play Client의 최초 PreloadAsync는 둘 다 Failure였다. 실제 게임 표시 검증·게시 Experience 권한·실기기/최종 미술 수용은 미완료다. 다음 담당 QA는 자산 처리 후 로딩 성공과 가방/대장간 실제 표시를 확인해야 한다. 상위 티켓은 완료 처리하지 않는다.
