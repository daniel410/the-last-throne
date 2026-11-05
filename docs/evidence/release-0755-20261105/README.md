# 최신 소스 통합 빌드·게시 0.75.5

2026-11-05 · TLT-003/005/028/032/033/057/084 · ENG → QA

사용자 요청으로 최신 확정 소스86fc3cae5297fa97e3ba6874b629e61e74b1d88c를 단일빌드0.75.5로 고정하고 기존 RPG 로비/배틀에 게시했다. 드워프 자연스러운 도끼 그립·연속 공격 보정, 몬스터 원위치 복귀HP유지,1.756375초/+12dB 포션 단일음원103385691872375를 포함한 전체 확정 소스를 사용한다. 기존 미커밋Blender·검토증거/백업·첨부는 보존하고 포함하지 않았다. TD Place/권리·공개 범위는 변경하지 않았다.

## 빌드와 검증

`python3 tools/build-game.py --source HEAD --record docs/evidence/release-0755-20261105/build.json` 성공. VERSION0.75.4→0.75.5를 먼저커밋·푸시하고 해당입력커밋에서 LFS내용/해시를 검증해 빌드했다. [빌드 기록](build.json), [검사 기록](validation.json)을 참조한다.

- 산출물: `builds/0.75.5/TheLastThrone-0.75.5.rbxlx`,13,168,673bytes.
- SHA-256:`34602d42d4bb56e5431353de3542238eb422f30d680b90a4373ea145f9d15a1c`. 게시후에도동일해시다.
- `lua tests/inventory.spec.lua`:271 PASS. `lua tests/k0-rules.spec.lua`:125 PASS.
- `python3 tests/single-build.spec.py --artifact builds/0.75.5/TheLastThrone-0.75.5.rbxlx`:프로젝트정합·실제산출물 역할10/로딩108 PASS.
- CombatService/PotionUseSound/K0DwarfDiagonalClip/K0MeleeMotion Luau컴파일PASS. 네모듈의산출물소스가고정커밋과바이트일치함을확인했다.
- `git diff --check`:PASS.

## 게시

같은파일을 Studio Publish As로 Experience10773575153의 로비70829337938054(18:37:17 Toronto),배틀129388473517823(18:38:43)에각각게시했다. 로비의ready to test/제한접근,배틀의Successfully published!/Private 화면을직접확인했다. 필요한자산의Grant Permissions and Publish를실행했다. [결과](publication.json),[실제성공로그](publication-studio.log).

Studio가처음에는기존클라우드창에연결돼있어해당창을정상닫고새빌드창에다시연결했다. 강제종료나사용자미커밋파일수정은하지않았다. 게시중스크립트자산버전이력업로드HTTP429경고가있지만두Place게시자체는PublishSuccessful을반환했다. 숫자게시버전은조회하지못했으며로컬Edit의PlaceVersion0을게시버전으로보고하지않는다.

게시후배틀로연결된Edit세션에서포션모듈의새ID와음원fetch Success/IsLoaded=true/1.756375초를확인했다. 새세션은asset:read미허용이어서음원심사상태는갱신조회하지못했다. 이전Reviewing을통과로바꾸지않는다. 실제게시클라이언트/포션소비/몬스터재교전·모바일/다인수용은미검증이며다음QA범위다. Studio성공화면만으로플레이수용을완료처리하지않는다.

검증된소스커밋에주석태그v0.75.5를생성·푸시한다. 게임게시와Git릴리스결과를별도로기록하며부모티켓완료상태는유지한다.
