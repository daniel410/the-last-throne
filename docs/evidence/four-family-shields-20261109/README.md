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
- 네이티브 착용/로딩 및 고정 빌드 결과는 소스 고정 후 기록한다.

Place 게시/TD 변경/라이브 DataStore 접근 없음. 실제 계정·게시 클라이언트 자산 권한/조명·실기기/4인 성능·사용자 최종 미술 수용은 미검증. 다음 담당은 QA/미술 수용이다.
