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
