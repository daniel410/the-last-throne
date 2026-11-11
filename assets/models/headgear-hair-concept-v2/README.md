# 영웅 컨셉 대조 머리카락 수정 후보

TLT-028/032/057 · 2026-11-11 · 로컬 제작 후보, Roblox 반영 대기.

승인 `2026-10-27-shared-ui-v2/heroes/hero-{elf,mage,knight,dwarf}.png`를 실제로 열어 비교했다. 최신 Meshy 4계열 방어구는 유지하고 납작한 능선과 비대칭 사선 끝을 가진 닫힌 메시를 별도로 제작했다. TD 원본 및 기존 v1은 보존한다.

| 파일 | 컨셉 대조 및 수정 |
| --- | --- |
| `elf.glb` | 컨셉의 옆가르마에서 사선으로 흐르는 넓고 뾰족한 갈색 앞머리 |
| `mage.glb` | 컨셉에서 머리가 거의 노출되지 않는 점에 맞춰 긴 옆머리·앞머리 제거, 정수리·뒤통수·관자놀이를 완전히 모델링하고 노출되는 목덜미는 짧게 유지 |
| `knight.glb` | 컨셉의 얼굴 노출 유지, 투구 안 정수리·뒤통수와 짧은 목덜미 포함 |
| `dwarf.glb` | 컨셉의 바깥으로 뻗는 적갈색 뒷머리. 최신 사용자 지시로 수염·콧수염·구레나룻 제거 |

마법사 컨셉은 머리 대부분이 가려져 있으므로 현재 머리카락 요청에 따른 절제된 갈색 머리 해석이며, 컨셉에서 색이 확정됐다고 주장하지 않는다. 렌더의 노란 머리는 착용 크기 확인용 둥근 블록 프록시다. 실제 Roblox Head 형상·애니메이션 검증을 대체하지 않는다. 사용자가 이전 둥근 다발 형태를 거부한 후 재제작한 후보이며 최종 미술 수용 전이다.

모든 영웅은 가려진 정수리·뒤통수·옆머리까지 이어지는 닫힌 두께 있는 머리캡을 포함한다. `*-hair-only.png`에서 모자를 숨겨 윗머리 존재를 확인한다.

`headgear-hair-review.blend`에 영웅별 장면4개·기존 Traveler 머리/몸 장비·조명·카메라를 포함한다. Standard/sRGB/None/Exposure0/Gamma1/CurvesOff. GLB는 흰색 tintable 머리 메시1개씩만 포함하며 렌더 색은 manifest의 영웅별 sRGB다. 텍스처가 누락된 것이 아니라 의도적으로 사용하지 않았다.

재현:

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/author-headgear-hair-concept-v2.py
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/review-headgear-hair-concept-v2.py
```

원점은 기존 방어구 좌표계, Head 기준점은 Roblox `(0,1.586,0)`이다. manifest의 size/center/samples/hash를 가져오기 후 실측 비교한다. 기존 런타임의 hood 추가 이동 `(0,.05,-.13)`은 이 후보에 적용하지 않는다. 영웅별 템플릿/색으로 연결하며 장비 계열에 따라 머리색을 자동 변경하지 않는 후보다. 이 연결은 아직 게임 코드에 적용하지 않았다.

[비교·검증·차단 사유](../../../docs/evidence/headgear-hair-concept-20261111/README.md).
