# 영웅 컨셉 대조 머리카락 v2

TLT-028/032/057 · 2026-11-11 · 로컬 제작 후보, Roblox 반영 대기.

승인 `2026-10-27-shared-ui-v2/heroes/hero-{elf,mage,knight,dwarf}.png`를 실제로 열어 비교했다. 최신 Meshy 4계열 방어구는 유지하고 머리에 맞는 안쪽 면과 끝이 가늘어지는 여러 겹의 닫힌 메시를 별도로 제작했다. TD 원본 및 기존 v1은 보존한다.

| 파일 | 컨셉 대조 및 수정 |
| --- | --- |
| `elf.glb` | 갈색의 짧은 비대칭 앞머리·관자놀이, 후드 앞에서 분리된 머리 다발 |
| `mage.glb` | 기존 판 모양 옆머리를 겹친 다발로 변경, 모자 아래 뒤통수 연결 |
| `knight.glb` | 얼굴 노출을 유지하는 짧은 목덜미, 드워프와 공유하지 않음 |
| `dwarf.glb` | 적갈색 겹친 뒷머리·구레나룻·콧수염·턱수염으로 컨셉 정체성 보강 |

마법사 컨셉은 머리 대부분이 가려져 있으므로 현재 머리카락 요청에 따른 절제된 갈색 머리 해석이며, 컨셉에서 색이 확정됐다고 주장하지 않는다. 렌더의 노란 머리는 착용 크기 확인용 둥근 블록 프록시다. 실제 Roblox Head 형상·애니메이션 검증을 대체하지 않는다. 컨셉의 모든 장식/수염 땋기까지 재현한 최종 미술 수용본은 아니다.

`headgear-hair-review.blend`에 영웅별 장면4개·기존 Traveler 머리/몸 장비·조명·카메라를 포함한다. Standard/sRGB/None/Exposure0/Gamma1/CurvesOff. GLB는 흰색 tintable 머리 메시1개씩만 포함하며 렌더 색은 manifest의 영웅별 sRGB다. 텍스처가 누락된 것이 아니라 의도적으로 사용하지 않았다.

재현:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/author-headgear-hair-concept-v2.py
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/review-headgear-hair-concept-v2.py
```

원점은 기존 방어구 좌표계, Head 기준점은 Roblox `(0,1.586,0)`이다. manifest의 size/center/samples/hash를 가져오기 후 실측 비교한다. 기존 런타임의 hood 추가 이동 `(0,.05,-.13)`은 이 후보에 적용하지 않는다. 영웅별 템플릿/색으로 연결하며 장비 계열에 따라 머리색을 자동 변경하지 않는 후보다. 이 연결은 아직 게임 코드에 적용하지 않았다.

[비교·검증·차단 사유](../../../docs/evidence/headgear-hair-concept-20261111/README.md).
