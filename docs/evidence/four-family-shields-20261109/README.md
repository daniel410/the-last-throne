# 최신 4계열 Meshy 방패 적용

TLT-028/029/032/041/052/073/082/084 · 2026-11-09 · 사용자 요청: 방패3D 모델 적용.

## 변경/근거

기존 무기16종 묶음과 같은 최신 Meshy 텍스처 완료 방패4종을 공개 UI에서 생성시각/Task ID/컨셉과 대조해 받았다. [원본·출처·자산ID](../../../assets/models/four-family-shields-meshy-v1/README.md). Traveler Ironbound Guardian, Tempered Aegis of the Deep, Veteran Bulwark of the Citadel, Sentinel Azure Citadel Crest다. 기존 [등급 미술 조사](../../research/2026-11-08-equipment-rarity-visuals.md)를 재사용한 자산 교체이며 새 경제/전투 설계를 추가하지 않았다.

`FourFamilyShieldVisuals`, `WeaponAppearance`, `KnightAppearance`에 기존 offhand 정의4개를 연결한다. CombatService/HeroSessionService의 기존 서버 확정 TLTEquippedOffhand를 읽는다. 알맞은 방패 중복 장착을 방지하고, 잘못된/누락 템플릿의 교체 실패는 기존 부품을 유지한다. 다른 방패/클래스·무기16종·아이콘32종·보유/거래/수치·블록 판정 유지.

Roblox rbx-import-asset / rbx-open-cloud-usage / rbx-permissions 스킬과 프로젝트 제작 절차를 적용했다. 기존 사용자 승인 asset:read/write와 assets 폴더 업로드 권한을 재사용했고 GET200으로 확인했다. 소유자9156786071의 Model4건 모두 Approved/Active. 가져오기에서 자동 생성된 하위 Mesh4/Texture4는 native-import에 별도 기록한다. 원본 패키지를 직접 런타임에 두지 않고 스크립트/PackageLink 없는 복제본을 고정해 패키지 갱신 영향을 없앴다.

Blender는 별도 background 프로세스로 사용자 live 장면을 보존했다. Standard/sRGB/None/Exposure0/Gamma1/CurvesOff 비교 렌더4종을 직접 확인했다. 원본 총5,794삼각형, 각20,000제한 이하. 공식 사양 https://create.roblox.com/docs/art/modeling/specifications 에서 확인했다.

## 검증

- 원본 해시 보존, 준비본 높이1.88studs·좌우폭약1.32studs·정면-Z. 실제 메시192점(48×4)이 준비본과 일치. 중심 재배치/180도 방향 보정.
- 가져오기 초기 검사에서 샘플을 메시 중심에 대한 상대좌표로 비교해야 함을 발견해 harness를 수정했다. 재업로드 없이 동일4개 자산으로192점 통과. 초기 실패를 성공에 포함하지 않는다.
- `python3 tools/validate-four-family-shields.py`: 원본/준비본 해시·정확한4ID·삼각형·4승인·192표본·런타임해시·양쪽 프로젝트 연결 통과.
- `run-in-roblox --place builds/0.95.0/TheLastThrone-0.95.0.rbxlx --script tests/four-family-shields-native.luau`: **151검사 통과**, R6/R15×4종의 실제 부품 교체·왼손 용접/멱등·중복/해제/클래스전환·실패 시 기존 부품 유지·방패 강타 정면·HP/루트 보존. 메시4/텍스처4 로딩 모두 Success. [JSON](native.json) / [원문](native.log).
- 첫 자세 harness는 네이티브 메시 자체 -Z를 정면으로 가정해 실패했다. 형상에서 확인한 앞면을 메시 좌표로 환산해 검사하도록 수정했고, 같은 고정 빌드에서151검사를 통과했다. [초기 결과](native-initial.log)를 보존한다. 런타임이나 모델을 다시 업로드/수정하지 않았다. 로그에 일부 새 content representation의 초기 경고가 있으나 ContentProvider 최종8건은 모두 Success이고 실제 렌더에서 모든 텍스처를 확인했다.
- 기존 회귀: 무기16종R6/R15 **700**, 로비 영웅/계열 전환 **49**, 기존 방패 강타 **86**검사 모두 통과. [회귀 JSON](regressions.json) / [원문](regressions.log).
- `python3 tests/single-build.spec.py --artifact builds/0.95.0/TheLastThrone-0.95.0.rbxlx`: 역할10/도착192·프로젝트 호환/실제 산출물 검사 통과.

## 고정 빌드·Studio

버전0.95.0, 소스 `828f3d16efebeb28c4023cf83a62e5daaf3e2b57`, SHA256 `f47c0f10d3ac548a87ba8d050433c80e27f0047e80f73f6a397b53c416bb5a7e`, 16,634,482bytes. [빌드 기록](build.json). `builds/0.95.0/TheLastThrone-0.95.0.rbxlx`를 별도 Studio로 열어4개 텍스처/정면을 직접 확인했다. 아래는 실제 Roblox 편집 렌더이며 왼쪽부터 Traveler/Tempered/Veteran/Sentinel이다. 검토용 남색 배경/보조광을 임시 배치했으며 게임 UI/게시 조명 증거가 아니다. 검토용 모델/배경/조명은 촬영 뒤 제거했다.

![실제 Roblox 방패4종](studio-shields.jpg)

기존 TLT 업로드 세션에는 검토한4개 런타임 템플릿만 유지하고 임시 package import4개/hex export 폴더는 정리했다. 이전 버전 프로젝트에 최신 서버 모듈을 부분 덮어쓰지 않았고, 최신 코드 전체는 열린0.95.0 빌드에서 검증했다. 두 세션 모두 Place 게시는 하지 않았다. 원본14개 LFS 전송과 source origin/main 반영 성공, 후속 검증/증거 커밋도 push한다.

Place 게시/TD 변경/라이브 DataStore 접근 없음. 실제 계정·게시 클라이언트 자산 권한/조명·실기기/4인 성능·사용자 최종 미술 수용은 미검증. 다음 담당은 QA/미술 수용이다.
