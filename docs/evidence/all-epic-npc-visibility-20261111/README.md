# 전체 에픽 NPC 얼굴·몸 표시 수정

2026-11-11 · TLT-050/070/084 · ENG · 로컬 수정/전체 에픽 엔진 검증 완료. 게시·실기기·화면 시각 수용 미검증.

사용자 요청: Dawnspire에서 보인 떠 있는 얼굴 문제를 다른 에픽 맵에서도 수정한다. [앞선 원인과 로비 수정](../npc-floating-faces-20261111/README.md)을 이어서 확인했다. 제작 스킬·제품 계약의 서버 권위/독립 Experience·기존 미커밋 보존 범위를 적용했다.

## 추가 원인과 변경

- `NPCPresentation`은 중복 인물과 다른 플레이어의 개인 동행 NPC를 숨길 때 BasePart만 처리했다. 얼굴/머리카락 Decal과 Texture에도 독립적인 `LocalTransparencyModifier`를 적용하고 원래 값을 복원한다. 실제 엔진에서 Decal의 해당 속성 읽기/쓰기를 확인했다.
- 뒤늦게 유입된 신체·얼굴·레이블·프롬프트에도 현재 NPC 표시 상태를 즉시 적용한다. 컨트롤러 종료 시 연결을 해제하고 기존 표시값을 돌려준다.
- `WorldPresentationBudget`이 NPC의 신체 투명도를 거리별로0/1로 덮어써 중복 NPC를 다시 드러내거나 얼굴만 남길 수 있었다. NPC 및 중첩 FaceRig 신체의 투명도는 NPC 표시 코드에 맡긴다. 일반 배경 거리 숨김과 NPC 그림자 최적화는 유지한다. NPC 거주 여부는 기존 스트리밍에 맡긴다.
- 앞선 지역 장면의 `ExpansionTransparency`와 이번 개인별 마스크는 각각 Transparency/LocalTransparencyModifier를 사용하여 서로의 상태를 덮어쓰지 않는다. 원래 얼굴의 반투명도·서버 상호작용/자격·보상·저장·동행 소유권 계약은 보존한다.

기존0.102.1에서 전체 맵을 생성한 회귀 검사로 `DW-01static.FaceRig.Head.FaceDecal`의 숨김 누락을 재현했다. [수정 전 실패](before.log). 이 로그는 동일 개인 마스크 검사를 포함한 초기 검사본이며, 최종 검사에는 늦은 표면·기존 투명도·배경 간섭 검사를 추가했다.

## 고정 빌드와 검증

**0.102.2**, 입력 소스 `66efc400c65b7211d18bfd031c0bbd4944d497ac`. [빌드 기록](build.json). 산출물 `builds/0.102.2/TheLastThrone-0.102.2.rbxlx`, 18,367,088bytes, SHA256 `511f15b4914848d44d72c467fd98ecc573dfee3fde11946130b7067ab6518252`.

`run-in-roblox --place builds/0.102.2/TheLastThrone-0.102.2.rbxlx --script tests/all-epic-npc-visibility-native.luau`: **24,233검사 통과**. 격리 Studio에서 실제 CampaignWorld 생성 경로로5개 맵을 모두 생성했다. 아래 숫자는 맵 전체 주민 수가 아니라 CampaignExpansion 이야기 장면의 수다.

| 에픽 | 이야기 장면 | 장면 NPC | Decal/Texture |
| --- | ---: | ---: | ---: |
| Deepwood | 44 | 5 | 8 |
| Gloamwood | 63 | 4 | 8 |
| Frozen Vale | 55 | 8 | 16 |
| Ember Caldera | 101 | 6 | 20 |
| Haunted Graveyard | 49 | 9 | 26 |
| 합계 | 312 | 32 | 78 |

검사 범위: 서버의 지연 등장 장면 기본 숨김, 전체 실제 장면의 미완료/완료 마스크 전환, 영웅 전환, 늦은 얼굴/장면 유입, 각 에픽 좌표에서 실제 NPCVisual로 만든 중복/개인 동행15개 모델의 선택·숨김·복원, Decal/Texture의 원래 로컬 투명도, 컨트롤러 종료. 실제 거리 최적화 Heartbeat를 실행해 NPC 마스크 보존과 일반 배경의 근거리 표시/원거리 숨김을 함께 확인했다. 모든 장면의 표면 전환을 검사하는 구간에서는 격리본의 표시 구간/조건 속성을 일시 통일한 뒤 원래 값으로 돌렸다. 퀘스트 완료 자격 자체를 검증한 결과와 구분한다. [전체 로그](native.log).

- 같은 빌드에서 기존 `npc-scene-visibility-native.luau`: **12,084검사 통과**. 로비17명과 귀환/지역 장면의 기존 검증 보존. [회귀 로그](regressions.log).
- `python3 tests/single-build.spec.py --artifact builds/0.102.2/TheLastThrone-0.102.2.rbxlx`: 역할10·도착192·프로젝트/실제 산출물 검사 통과.
- 기존 `npc-role-unification-native.luau`는27검사 후 `Selene_91.ActorRoot.Rest`를 찾지 못해 실패했다. 동일 하네스를 수정 전0.102.1에서도 실행하여 같은27검사/같은 오류를 확인했다. 이번 변경으로 새로 생긴 실패로 보지 않으며 기존 스크립트의 현재 Selene 프롬프트 계약 대조가 후속이다. [기준 빌드 로그](regressions-baseline.log). 최초 하네스에는 Remotes 폴더가 빠져24검사에서 중단됐고 이를 격리 하네스에 추가한 뒤 두 빌드를 동일하게 비교했다. [첫 하네스 로그](regressions-initial.log). 회귀 하네스는 두 기존 테스트를 각각 함수로 감싸 순차 실행했으며 라이브 서버/계정에 연결하지 않았다.

기존 실행 중인 Studio와 클라우드 편집 Place는 수정하지 않았다. 새0.102.2 파일에서 Play해야 반영된다. 미커밋 방어구·Blender·삭제 자산은 이번 커밋/빌드에 포함하지 않았다. Roblox 게시·릴리스 태그·TD 변경·라이브 DataStore 접근은 없다. 게시 클라이언트·실기기·시각 전후 비교·멀티플레이 네트워크/성능·사용자 수용은 미검증이다. 상위 티켓/게이트 전체 완료로 처리하지 않는다. 다음 담당은 QA의 새 빌드 화면 확인과 기존 Selene 회귀 하네스의 프롬프트 계약 대조다.
