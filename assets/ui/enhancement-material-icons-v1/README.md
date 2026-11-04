# 강화 재료 아이콘

2026-11-03 · TLT-028/031/043/084 · ENG/DES

사용자 요청으로 기존 아이템 아틀라스의 입체감·선명한 면·하이라이트에 맞춘 빨간 Enhancement Gem과 보라색 Magic Stone을 built-in ImageGen으로 각각 생성했다. 새 투명 PNG를 보존하며 TD 원본은 변경하지 않았다. 전체 프롬프트는 `prompt.txt`, 크기/알파/해시/업로드ID는 `manifest.json`에 기록한다.

`ItemSpriteAtlas.images`와 `ItemSprites.create`를 연결해 `ItemArtwork.create`를 사용하는 가방·상세·대장간에서 두 재료를 독립 이미지로 표시한다. 기존 아이템 아틀라스와 재료ID·수량·강화/교환 규칙은 유지한다.

검증: Luau 컴파일 성공, Lua 생성자 스텁에서 두 재료의 Image/DefinitionId/SpriteKey/Fit/투명 배경과 기존 광석 아틀라스·미등록 항목 fallback 통과. PNG 두 파일 모두1254×1254·알파0~255 확인. `git diff --check` 통과. 별도 게임 빌드/버전 증가·Place 게시는 수행하지 않았다.

Roblox Studio upload_image는 두 자산ID를 반환했으나 로비 Play Client의 최초 PreloadAsync는 둘 다 Failure였다. 실제 게임 표시 검증·게시 Experience 권한·실기기/최종 미술 수용은 미완료다. 다음 담당 QA는 자산 처리 후 로딩 성공과 가방/대장간 실제 표시를 확인해야 한다. 상위 티켓은 완료 처리하지 않는다.

## 사용자 승인 후 게임 적용

2026-11-03 후속 요청으로 기존 RPG Lobby0.67.0/Battle0.65.0 Studio의 `ItemSpriteAtlas`와 `ItemSprites`를 저장소 코드와 같은 내용으로 교정했다. 후보 맵 Studio는 변경하지 않았다. 로비를 재시작하기 전 Client에서 두 자산의 GetAssetFetchStatus가 모두 Success임을 확인했다. 배틀 Edit에서는 실제 생성자가 재료별 ImageLabel/자산ID를 반환했다.

로비 재시작 후 실제 `ItemArtwork.create`에서도 두 재료가 독립 ImageLabel로 생성되고 자산 상태는 Success였다. 다만 비활성/화면 밖 검증 GUI에서 IsLoaded=false였으므로 실제 가방/대장간 화면 표시 성공으로 간주하지 않는다. 온스크린 재검증 전에 로비가 Edit 전환 후 연결 해제되어 최종 시각 검증을 완료하지 못했다. 계정 재료 지급/소비나 저장 데이터를 변경하지 않았다.

적용본을 별도로 보존하기 위해 VERSION0.67.2로 고정 소스 Lobby/Battle을 빌드한다. 소스 커밋·산출물 해시·결과는 `build.json`에 기록한다. 실제 Place 게시/릴리스 태그·게시 클라이언트/실기기 검증은 수행하지 않는다. 다음 담당 QA는 이 빌드를 열어 실제 가방/대장간 화면과 기기별 표시를 확인한다.
