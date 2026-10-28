# 플레이어 무기와 근접 기본 공격 부분 원형

2026-10-28 · 작업: TLT-032와 후속 직업 준비 · 담당: 3D·ENG·QA

## 범위와 결정

사용자가 지정한 TD 타워 원본을 기준으로 기사 철검, 드워프 도끼, 엘프 활을 연결하고, 초급 마법사의 나무 지팡이를 새로 제작했다. 드워프와 마법사의 **기본 공격은 들고 있는 무기를 휘두르는 근접 공격**이다. 별도 기술로 도끼를 투척하거나 주문을 사용하는 기획은 유지한다. 피해·사거리·타이밍은 현재 K0 실험용이며 최종 밸런스가 아니다.

현재 실행 흐름의 최초 클래스는 기사다. 드워프·마법사의 서버 프로필은 신뢰된 서버 전용 resolver를 주입하는 시험 환경에서만 실행했고, 엘프 활은 외형 어댑터에 준비했다. 직업 생성·선택·영구 저장, 엘프 원거리 전투, 직업별 기술과 정식 성장 완료를 의미하지 않는다.

## 출처와 산출물

| 직업 | 무기 | 출처·상태 |
| --- | --- | --- |
| Knight | 철검 | TD `TowerModels.swordsman`에서 분리된 기존 무기 메시 `130169610186060`, 기존 색맵 `97596525220590`. 현재 기사 외형에 연결. |
| Knight | 철방패 | TD `TowerModels.swordsman.Body`에서 분리한 비공개 메시 `86935256146675`와 기존 색맵 `97596525220590`. 기사 외형의 왼손에 연결. |
| Dwarf Axe Thrower | 손도끼 | TD `TowerModels.axe.Axe`의 기존 메시 `106045080642382`와 SurfaceAppearance. 직업 외형 어댑터에 연결. |
| Elf Archer | 활·시위·화살 | TD `TowerModels.archer`의 기존 메시 `83795343518288`, `108052120766619`, `77202496614276`과 SurfaceAppearance. 직업 외형 어댑터에 연결. |
| Mage | 초급 나무 지팡이 | `WoodenStaffBuilder.luau`에서 새로 만든 13개 기본 도형. 충돌·쿼리·접촉 비활성, 시각 전용. |

정확한 TD 원본 해시·모델 속성·검토용 GLB와 런타임 해시는 [공유 무기 매니페스트](../../../assets/shared/td-player-weapons/manifest.json), [출처](../../../assets/shared/td-player-weapons/provenance.json)에 기록했다. `python3 tools/extract-td-player-weapons.py --check`는 원본 파일의 해시와 3개 모델·5개 메시의 속성을 검사하고 통과했다. 소스 TD 프로젝트를 수정하지 않는다.

기사 방패는 TD Swordsman 몸체에 합쳐져 있던 원본에서 550개 면과 기존 UV를 [분리](../../../assets/shared/td-player-weapons/shield/manifest.json)했다. 사용자는 이 메시 1개의 개인 비공개 업로드를 허용했다. Roblox `AssetService:CreateAssetAsync`는 두 독립 Studio 실행 컨텍스트에서 `CreateAssetAsync and CreateAssetVersionAsync are not available yet`을 반환했으나, 이후 격리된 PlaceId 0의 Studio Importer에서 모델 묶음 업로드를 끄고 메시만 가져와 `86935256146675`를 생성했다. `GetProductInfo`는 현재 사용자 소유의 Mesh를 반환했고 Creator Dashboard에서 **Restricted**를 확인했다. 기존 색맵 `97596525220590`을 재사용하며 새 이미지 업로드는 없다. 가져온 메시의 550개 면과 메시·색맵 preload 성공을 확인했다. [Studio의 원본 색맵 렌더](td-shield-native.jpg)에서 정면 문양을 확인했다. Import된 Roblox 메시의 전면은 local `-Z`이며 원본 GLB의 `+Z`와 다르다.

## 검증과 한계

- `lua tests/k0-rules.spec.lua`: 122개 통과. `lua tests/k0-spawn.spec.lua`: 스폰·리스폰 수명주기 통과. `lua tests/k0-appearance.spec.lua`: 원본이 없을 때 기사 임시 장비로 전환하는 모의 수명주기 통과.
- 고정 소스의 `tests/k0-player-weapons-native.luau`: Roblox 엔진에서 종료 0, **2,107검사/34사례** 통과, Player 0. R6/R15, 방패 메시와 색맵·왼손 결합·부품 유실 자동 복구, 클래스 속성 관찰·손 교체·리스폰 모형·장비 소유권과 외형 연출 API를 확인하고 메시 6개·이미지 8개 요청 성공. 방패를 일부러 제거한 fallback 사례는 예상된 경고를 출력한다. [소스 fixture 로그](player-weapons-native-source.log). 실제 플레이어 선택·네트워크 복제·게시 환경 권한과 최종 화면 수용은 별도다.
- `tests/k0-basic-attacks-native.luau`: 신뢰된 서버 클래스 resolver, 실제 서비스 콜백과 엔진 인스턴스·가상 시간·신원 모형으로 **54검사/13사례** 통과, 재실행 종료 0. 근접 범위·장애물·중복 피해·누락 프레임·위조 클래스·기사 방어 차단을 검사했다. [성공 로그](basic-attacks-native-source.log). 첫 명령은 검사 보고서가 통과했으나 Studio 내장 플러그인 React 오류 출력 후 종료 1이었다. [첫 로그](basic-attacks-native-first.log). 실제 플레이어·네트워크 공격 검사는 아니다.
- 기존 `rbxassetid://203785492` 자산 유형 경고가 재관측됐다. Studio 내장 Toolbox의 프로파일 경고도 일부 실행에 표시됐다. 게임 코드 결함이나 원인 해결로 단정하지 않는다.

기사 외형의 손 접촉과 공격·방패 방향, 드워프·마법사/엘프의 정식 선택 및 실전 애니메이션, 모바일·패드·다인·네트워크와 게시된 테스트 Experience의 제한 자산 권한은 아직 수용 검증하지 않았다. 다음 담당은 ART의 방패 장착 검증과 ENG/QA의 직업 선택 및 실제 클라이언트 검증이다. 이 문서와 원형만으로 TLT-032 또는 모든 직업을 완료 처리하지 않는다.
