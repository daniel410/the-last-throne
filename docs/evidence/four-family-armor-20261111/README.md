# 4계열 방어구28종 게임 적용

2026-11-11 · TLT-028/029/032/041/057/084 · ART·ENG · 0.102.0 로컬 구현/엔진 검증 완료, 게시·실기기·미술 수용 후속.

사용자 요청: 이미 생성된 Traveler/Tempered/Veteran/Sentinel 후드·헬멧·마법사 모자·코트·로브·장갑·부츠만 적용하고 무기/방패는 제외한다. [원본·가져오기·권한·ID·복구 경로](../../../assets/models/four-family-armor-meshy-v1/README.md).

InventoryRules가 소유 장비의 head/body/hands/feet 정의를 집계하고 HeroSessionService와 CombatService가 로비·전투의 확정 캐릭터 속성으로 투영한다. 새 ArmorAppearance가 생명/클래스·부위별 착용/교체/해제와 신체·머리 액세서리 복원을 담당한다. 기존 무기/방패 코드·데이터를 수정하지 않았다. 장비 능력치·가격·획득·강화·프로필 저장 형식은 변경하지 않는다. 작업 중 별도 커밋된 Mage Hat 최대MP10/20/30/60 계약도 보존한다.

## 자산 검증

- Meshy 공개 UI에서28개 최신 텍스처 Task를 구분했다. 첫 다운로드 선택과 마지막 ZIP 누락을 실제 파일 검사로 발견하고 필요한 항목만 다시 받아28개 고유 해시를 확인했다. 미리보기 전환을 다운로드 성공으로 계산하지 않는다.
- 원본43,892삼각형/28종. 준비본92개 패널. Blender Standard/sRGB 색상 기준을 적용했다.
- 초기 로브 소매의 정점별 분류에서 커프 경계가 찢어지는 것을 확인해 면을 먼저 분류한 뒤 소매 전체를 변환했다. Model4개를 같은ID revision2로 수정했으며 모두 Approved다.
- 네이티브92개 메시의2,208표본이 준비본과 일치한다. 원본 색 텍스처28개와 메시92개 ID를 기록했고, 전체 모델에서 가져오기180도 차이를 보정했다.
- `python3 tools/validate-four-family-armor.py`: 해시/28ID·계열×부위/승인·삼각형 보존·92부품·2,208표본·두 프로젝트 연결 통과.
- 로컬 Lua 인벤토리274·Mage Hat129·4계열492·기본 장비206·장비 비교52·특수 효과281·로비 복귀27검사 통과. 실제 계정 저장이나 게시 검증은 아니다.

## Studio 착용 검토

업로드용 TLT 클라우드 편집 세션의 격리된 R15 마네킹12개에서 실제 텍스처/외형을 확인했다. 왼쪽부터 Sentinel·Veteran·Tempered·Traveler다. 임시 남색 배경·보조광·기본 얼굴/피부와 클래스 팔색을 사용했으므로 게시 조명/실계정 아바타 증거와 구분한다. 코트는 원본처럼 소매 없는 형상으로 기존 클래스 팔이 보인다.

![Knight 착용](studio-knight.png)

![Elf 착용](studio-elf.png)

![Mage 착용](studio-mage.png)

현재 Place 게시·릴리스 태그·TD 변경·라이브 DataStore 접근 없음. 게시 클라이언트·실계정 재접속·임의 UGC 체형·실기기/4인 성능·최종 미술 수용은 미검증이다. 상위 티켓/게이트를 완료 처리하지 않는다. 다음 담당은 QA/사용자 미술 수용이다.

## 고정 빌드와 엔진 회귀

버전 **0.102.0**, 소스 `20a74fdde4f983811c46e1904071653821964d18`. [빌드 기록](build.json). 산출물 `builds/0.102.0/TheLastThrone-0.102.0.rbxlx`, 18,365,590bytes, SHA256 `8682538b47bc516e5e047d4924c906875180a38b23bedb5e4f513c6439d810c6`. source origin/main에89개 LFS 원본277MB 전송 및 소스 커밋 원격 일치를 확인한 뒤 고정 소스에서 빌드했다. 생성 빌드 파일은 Git 소스에 포함하지 않는다.

- `run-in-roblox --place builds/0.102.0/TheLastThrone-0.102.0.rbxlx --script tests/four-family-armor-native.luau`: **5,758검사 통과**. R6/R15×4클래스×4계열의 기존 정의/실제 부품·소켓·멱등·복제/누락 복구·교체 실패 시 이전 외형 보존·해제/클래스 제한·원래 투명도 복원·HP/루트/기존 무기·방패 모델 보존. 기존 액션 렌더러의 Attack/Dodge/Idle 호출 후 관절/소켓 계약 검사 포함. [결과](native.json), [원문](native.log).
- 실제 메시92개·텍스처28개, 총120개의 최종 `ContentProvider` 결과가 모두 Success다. 초기 content representation 경고는 원문에 보존했으며 최종 로드/실제 텍스처 렌더와 구분한다.
- 같은 고정 빌드에서 기존 `four-family-weapons-native.luau` **700**, `four-family-shields-native.luau` **199**, `lobby-selected-weapons-native.luau` **49**검사를 한 격리 하네스의 각각 do블록으로 실행해 모두 통과했다. [결과](regressions.json), [원문](regressions.log).
- `python3 tests/single-build.spec.py --artifact builds/0.102.0/TheLastThrone-0.102.0.rbxlx`: 역할10·도착192·두 프로젝트 경로/실제 산출물 검사 통과.
- 0.102.0 파일을 별도 Studio로 열어 ServerStorage에28개 템플릿/92개 MeshPart와 서버/공유 모듈이 들어 있음을 재확인했다. 업로드용 클라우드 편집 세션의 임시 원본 패키지28개·마네킹/배경/보조광·테스트 모듈·hex export는 제거하고 검토한28개 템플릿만 유지했다. Place 게시는 하지 않았다.

로브는 옷감 시뮬레이션이 아닌 분할 패널이다. 이 검증은 격리된 로컬 엔진과 편집 렌더이며 전체 실시간 애니메이션 시각 수용·실계정 입장/저장/재접속·임의 UGC 체형·게시 클라이언트 권한/조명·실기기/4인 성능을 대신하지 않는다. 다음 담당은 QA/사용자 미술 수용이다. 빌드에 최신 Mage Hat MP 정의가 포함되지만 최대MP 변경의 전용 엔진 검증 완료를 이 외형 검사로 주장하지 않는다.
