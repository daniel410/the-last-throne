# K0 TD 자산 로딩 probe

작업 ID: `TLT-002`, `TLT-032` 일부 · 2026-10-28 · 담당: 3D 모델링

**격리된 Studio Edit에서 12개 요청의 실제 인스턴스 콜백이 모두 `Success`였다.** 시간 초과·누락 콜백·요청 오류는 없었다. 이는 현재 Studio 계정의 로딩 결과이며 게시된 RPG Experience의 접근 권한, 실제 클라이언트 렌더, 리그 또는 품질 수용을 뜻하지 않는다.

## 조건과 결과

- 독립 임시 파일 `/private/tmp/tlt-k0-td-asset-probe-20261028-5941/empty-fixture.rbxlx`, SHA-256 `91ca3073f2b0a167d9a84356a6f6119583e096edf6e05b7645b0f74fc1e8b2ec`. Workspace에 게임 콘텐츠가 없는 미게시 fixture이며 `ServerStorage`에 검사 전용 식별자와 MeshPart 3개만 넣었다. 게임 빌드가 아니다.
- [검사 스크립트](../../../tests/k0-td-asset-probe.luau) SHA-256 `9725739fa19d4461f0d6f95d960a2ad91874f228da193eab42bcb36ff25b393b`. `PlaceId=0`, `GameId=0`, Edit, Player 0, 전용 마커와 fixture 구성을 확인한 뒤 실행했다. `StudioService:GetUserId()`는 `9156786071`을 반환했으며 [기존 원본 감사](asset-audit.md)의 당시 소유자 기록과 일치한다.
- 2026-10-28 약 09:02 EDT, `run-in-roblox 0.3.0`으로 별도 Studio를 열었다. 기존 TD 프로젝트와 기존 Studio 세션, 자산의 설정·권한, 운영 데이터는 변경하지 않았다. 업로드·게시·게임 빌드는 수행하지 않았다.
- 아래 각 결과는 지정 ID를 담은 인스턴스 하나에 대한 `ContentProvider:PreloadAsync` 호출의 동일 ID 콜백이다. 모든 값은 `Enum.AssetFetchStatus.Success`다. Mesh는 `MeshPart`, UI·색맵·PBR 맵은 `ImageLabel`로 요청했다. PBR 맵의 이미지 로딩과 `SurfaceAppearance`로 실제 재질이 바르게 렌더되는지는 다르다.

| 대상 | 인스턴스 유형 | Roblox ID | 콜백 결과 |
| --- | --- | --- | --- |
| 메뉴 아틀라스 | ImageLabel | `98305074323052` | Success |
| 전투 아틀라스 | ImageLabel | `97570429280107` | Success |
| 기사 아이콘 아틀라스 | ImageLabel | `101027288850338` | Success |
| 기사 검 | MeshPart | `78152429410586` | Success |
| 검 ColorMap | ImageLabel | `129747040508630` | Success |
| 검 NormalMap | ImageLabel | `123540236668043` | Success |
| 검 RoughnessMap | ImageLabel | `82984644200263` | Success |
| 검 MetalnessMap | ImageLabel | `123863432588878` | Success |
| Goblin Body | MeshPart | `77403549111699` | Success |
| Goblin 색맵 | ImageLabel | `134919664038207` | Success |
| Ogre Body | MeshPart | `98618217378067` | Success |
| Ogre 색맵 | ImageLabel | `90412861785322` | Success |

명령은 `run-in-roblox --place /private/tmp/tlt-k0-td-asset-probe-20261028-5941/empty-fixture.rbxlx --script tests/k0-td-asset-probe.luau`이고 종료 코드는 0이었다. 계정 식별을 추가하기 전 선행 실행도 같은 12개 결과였고, 위 표는 식별을 포함한 최종 실행이다. 종료 코드만으로 성공을 판정하지 않고 각 콜백을 확인했다. `luac -p tests/k0-td-asset-probe.luau`도 통과했다. 원본 TD UI 소스와 두 runtime XML에서 위 12개 ID가 현재 작업 트리에 존재하는지 정적으로 대조했다.

두 실행 모두 별도로 `ContentId: rbxassetid://203785492 failed due to: Asset type does not match requested type` 경고가 출력됐다. 이 ID는 본 probe의 12개 요청에 없으며 출처·영향은 확인하지 못했다. 각 요청의 성공이나 전체 게임의 무오류로 이 경고를 덮지 않는다.

## 재현용 임시 fixture

검사 스크립트는 다른 Place에서 실수로 동작하지 않도록 식별자를 요구한다. 저장소 루트에서 아래 명령으로 동일한 구조의 고유 임시 fixture를 만든 뒤 실행할 수 있다. 파일은 검사 자료이며 게임 소스나 빌드 산출물이 아니다.

```sh
TLT_PROBE_DIR="$(mktemp -d /private/tmp/tlt-k0-asset-probe.XXXXXX)"
python3 - "$TLT_PROBE_DIR/fixture.rbxlx" <<'PY'
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

root = ET.Element("roblox", version="4")
ET.SubElement(root, "External").text = "null"
ET.SubElement(root, "External").text = "nil"
storage = ET.SubElement(root, "Item", {"class": "ServerStorage", "referent": "PROBE_STORAGE"})
p = ET.SubElement(storage, "Properties")
ET.SubElement(p, "string", name="Name").text = "ServerStorage"
folder = ET.SubElement(storage, "Item", {"class": "Folder", "referent": "PROBE_FOLDER"})
p = ET.SubElement(folder, "Properties")
ET.SubElement(p, "string", name="Name").text = "TLTK0AssetProbeFixtures"
marker = ET.SubElement(folder, "Item", {"class": "StringValue", "referent": "PROBE_MARKER"})
p = ET.SubElement(marker, "Properties")
ET.SubElement(p, "string", name="Name").text = "ProbeMarker"
ET.SubElement(p, "string", name="Value").text = "TLT-K0-ASSET-PROBE-20261028-5941"
for i, (name, asset) in enumerate([
    ("KnightSword", "78152429410586"),
    ("GoblinBody", "77403549111699"),
    ("OgreBody", "98618217378067"),
]):
    item = ET.SubElement(folder, "Item", {"class": "MeshPart", "referent": f"PROBE_MESH_{i}"})
    p = ET.SubElement(item, "Properties")
    ET.SubElement(p, "string", name="Name").text = name
    content = ET.SubElement(p, "Content", name="MeshId")
    ET.SubElement(content, "url").text = "rbxassetid://" + asset
    for key, value in [("Anchored", "true"), ("CanCollide", "false"), ("CanTouch", "false"), ("CanQuery", "false")]:
        ET.SubElement(p, "bool", name=key).text = value
with Path(sys.argv[1]).open("xb") as target:
    target.write(ET.tostring(root, encoding="utf-8", xml_declaration=True))
PY
run-in-roblox --place "$TLT_PROBE_DIR/fixture.rbxlx" --script tests/k0-td-asset-probe.luau
```

## 미검증과 다음 담당

이번 실험은 Studio 계정과 캐시를 포함한 로컬 환경이다. 현재 Roblox 에셋 권한 설정의 전수 조회, 게시된 RPG Place의 다른 계정 및 실제 클라이언트, 나머지 적 팔·다리 메시, 검의 PBR 적용, 시각 비교, 손·방패·발 접지, 모바일 성능은 검사하지 않았다. 이미지/메시 파일을 새로 업로드하거나 공개 전환할 근거도 아니다.

다음으로 Engineer가 재사용 후보의 안전한 연결과 대체 경로를 설계하고, QA가 대상 **게시된 테스트 Experience**와 다른 계정의 인스턴스 로드 및 실제 화면·모션을 별도 확인한다. 이 probe 하나로 자산 구현이나 G1 수용을 완료 처리하지 않는다.
