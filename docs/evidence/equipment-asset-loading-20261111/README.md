# 장비 텍스처 지연 표시 수정

2026-11-11 · TLT-057/084 · ENG · 구현/소스 회귀/엔진 자산 로딩 시험 통과, 게시 클라이언트·사용자 수용 미검증.

## 변경과 원인

새 무기·방어구는 클라이언트에서 메시가 준비되어도 색상 텍스처를 기다리지 않고 표시했다. 기존 기사 대체 모델도 메시 ID 성공만으로 원본을 복원했다. 로비부터 장착 장비를 감시하는 `EquipmentAssetLoading`을 추가하고, 메시와 색상 텍스처 요청이 완료될 때까지 렌더 직전 해당 메시만 가린다. 서버 소유·전투·장착 상태는 변경하지 않는다.

텍스처 ID를 직접 `PreloadAsync`에 넘기면 일부 ID가 `No asset content representation found`로 실패함을 실제 Studio 클라이언트에서 확인했다. 같은 ID `124825290649611`은 문자열 입력에서 Failure, `Decal.Texture` 입력에서 Success였다. 최종 구현은 `MeshPart.TextureID` 및 SurfaceAppearance의 비어 있지 않은 맵을 임시 Decal로 요청하고 완료/예외 후 정리한다. 기사 대체 모델도 이 공통 로더의 모든 요청 성공을 확인한다.

진행 중인 마스크는 다음 시뮬레이션 전에 복원하므로 공격·투사체·장착 해제·카메라의 기존 숨김 값을 보존한다. 스트림 아웃은 요청을 취소하고 이전 완료가 재진입 요청을 해제하지 못하게 한다. 세 번의 요청이 실패하면 경고하고 기존 표시 경로로 복귀한다. 이 장애 경로에서는 원본의 회색 표시 가능성이 남으며 영구 투명 상태를 만들지 않는다.

## 빌드와 검증

- 최종 빌드 **0.102.8**, 소스 `a50c20a88fb858b0d52691499c3221cd164027ee`. [build.json](build.json)의 단일 rbxlx·해시 기준이며 게시/릴리스 태그는 만들지 않았다.
- `lua tests/equipment-asset-loading.spec.lua`: 21검사 통과. 지연 색상·프록시 정리·기존 투명도·중복 시작·스트림 재진입·늦은 완료·실패 재시도/복구를 확인했다.
- `lua tests/arrival-loading.spec.lua`: 기존 도착 화면 192검사 통과. [소스 결과](source-tests.json).
- `run-in-roblox --place builds/0.102.8/TheLastThrone-0.102.8.rbxlx --script tests/equipment-asset-loading-native.luau`: 네 계열 무기16·방패4·방어구28, 총48모델/120메시. 실제 ContentProvider 요청 콜백368개·최종 실패0, 준비 전 숨김/준비 후 기존 마스크 복원 포함243검사 통과. [결과](native.json), [로그](native.log).
- 기존 `weapon-render-loop-native.luau`: 실제 무기 시작/프레임 콜백 3검사 통과. [로그](weapon-render-loop.log).
- 최초0.102.7은 원시 맵 ID 요청으로 엔진 시험에 실패했다. [빌드](build-01027.json), [실패 로그](native-raw-id-failure.log)를 보존하며 최종 통과로 계산하지 않는다. 최종 로그에도 엔진 내부 표현 요청 경고가 있으나 Decal을 통한 최종 콜백368개는 모두 Success였다.

## 검증 한계와 다음 담당

공식 [ContentProvider 문서](https://create.roblox.com/docs/reference/engine/classes/ContentProvider)(2026-11-11 확인)는 SurfaceAppearance/MaterialVariant 자체가 PreloadAsync 대상이 아니라고 명시한다. 개별 맵을 요청했어도 엔진의 가공 PBR 팩·최종 GPU 렌더 준비를 보장한다고 판단하지 않는다.

엔진 시험은 별도 로컬 빌드에서 실제 자산을 다운로드하되 프레임 신호를 통제한 시험이다. 게시된 실제 클라이언트의 캐시 없는 첫 접속·저속망·실기기 화면·다인 관찰·사용자 수용은 미검증이다. 다음 담당 QA는 로비 첫 영웅 표시→다른 클래스 선택→무기/방패/방어구 교체→배틀 이동→재접속, 도끼 투척·기사 방어·엘프 화살·장착 해제에서 회색 노출/의도하지 않은 재표시를 확인한다. SurfaceAppearance 팩의 추가 지연도 별도로 관찰한다. TLT-057/084 전체 완료 상태는 변경하지 않는다.
