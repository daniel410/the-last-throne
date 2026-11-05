# 포션 마시는 소리 편집본

2026-11-05 · TLT-005/028/032/057/084 · AUDIO/ENG → QA · 편집 완료·Roblox 업로드 대기

사용자가 기존0.85초 음원이 너무 짧아 두 번의 재생 호출 대신 한 파일로 편집하기를 요청했다. `potion-drink.wav`는 두 gulp를 합친1.756375초 단일 WAV다. 두 번째 음량94%·중간55ms 간격·각 조각의 양 끝8ms fade를 적용했다. 재생 코드를 두 번 호출하거나 Looped를 켜지 않는다.

## 출처와 재현

- 원본: ProSoundEffects [Drinking Cu Gulping 2 (SFX)](https://create.roblox.com/store/asset/9114171855), 기존 프로젝트 선택 음원.
- 원본 전달 OGG를 macOS `afconvert -f WAVE -d LEI16`으로 디코딩한 `source.wav`를 함께 보존한다. 기존 원본 선택/로딩은 [검증 기록](../../../docs/evidence/potion-drinking-sound-20261105/README.md)을 따른다.
- `python3 tools/edit-potion-drink.py`로 편집본을 재현한다. 표준 라이브러리만 사용한다.
- WAV 두 파일은48kHz·모노·PCM16이며 Git LFS로 관리한다. 길이/해시/peak는 `manifest.json`에 기록했다. 출력 peak3971/32767로 클리핑 없으며 첫/끝 샘플0이다. 리샘플링·정규화·외부패키지 설치는 하지 않았다.
- 편집 후 SHA-256을 재생성해 같은 결과임을 확인했다. 채팅에 편집 WAV를 직접 제공했다. 사용자 청취 취향/최종 수용은 별도다.

## Roblox 연결 상태

[공식 오디오 가져오기 문서](https://create.roblox.com/docs/audio/assets)를 확인하고 Studio Open Cloud `POST /assets/v1/assets`에 Audio/본 WAV로 업로드를 시도했다. 도구가 업로드 승인 디렉터리에 포함되지 않아 요청을 거부했다. 파일을 다른 폴더로 옮겨 우회하지 않았다.

사용자에게 Studio **Assistant Settings → MCP Permissions**의 업로드 허용 폴더에 이 디렉터리를 추가하도록 안내했다. 새 자산ID가 아직 없어 `PotionUseSound`는 기존 원본ID를 유지한다. 게임의 두 번 재생/루프를 추가하지 않았고 VERSION/빌드/Place 게시도 변경하지 않았다.

다음 ENG는 디렉터리 승인 후 같은 파일을 업로드하고 자산 완료/권한/로딩을 확인해 `PotionUseSound.SoundId`를 교체한다. QA는 새 단일ID를 한 번 재생해 두 gulp가 들리는지, 실제 HP/MP 성공만 재생되는지 검사한다. 현재 열린 Studio의 사용자 세션·별도 드워프 모션 변경은 보존한다.

## 사용자 볼륨 피드백 반영

사용자가 우선 편집본만 확인하기로 선택한 뒤 볼륨이 작다고 피드백했다. `potion-drink-louder.wav`를4배(+12.0412dB)로 증폭해 별도 미리 듣기로 제공한다. 길이1.756375초·간격/페이드는 유지하며 peak15884/32767(-6.29dBFS)로 클리핑이 없다. 최초 편집본도 비교용으로 보존한다. 게임 Sound.Volume/음원ID와 업로드 상태는 변경하지 않는다.

## 2026-11-05 업로드·Studio 연결 완료

사용자가 `assets/` 업로드 디렉터리를 허용한 뒤 볼륨 증가 편집본을 Roblox Audio **103385691872375**(User9156786071·revision1)로 업로드했다. operation40be0c90-bdc1-4e2a-bc55-b403eebffc65의done=true 및 자산 Active를 확인했다. 검토 상태는현재Reviewing이며 심사 통과로 보고하지 않는다.

저장소 `PotionUseSound`의 단일SoundId를 교체했고, Roblox에 저장된 로비 Place70829337938054 / Universe10773575153의 Studio 편집 세션에 모듈 생성과CombatService 사용 성공 호출을 적용했다. 기존 로비 소스 전체를 덮어쓰지 않고 포션 연결만 수정했다. 실제 Studio Source에서 모듈/ID/require/호출을 재확인했다. 해당 Place의 ContentProvider fetch=Success, IsLoaded=true, TimeLength=1.756375초와 PlayLocalSound 미리듣기를 확인했다.

`luau-compile` 두 모듈PASS·기존 인벤토리271개PASS·실제회복본문 격리8개PASS·diff검사PASS. Studio 실행 중 실제 포션 소비→음원 재생 통합/클라이언트·모바일/다인·Battle Place 접근 권한/심사 완료는 미검증이다. 현재 클라우드 Studio 편집과 로컬 소스 적용이며 게임 Place 게시/새 빌드/VERSION/릴리스 태그는 생성하지 않았다. 앞선 업로드 대기 기록은 당시 상태이며 이절과manifest가최신이다. 다음QA는심사완료 후 실제포션·두Place/기기에서 검증한다.
