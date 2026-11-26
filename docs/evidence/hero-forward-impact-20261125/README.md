# 네 영웅의 찌르기·착지·관통 공격

2026-11-25 · TLT-033/057/059 · ART·ENG → QA · 기준 0.115.125 · 후보 0.115.127

| 영웅과 기술 | 애니메이션과 VFX |
| --- | --- |
| Knight · Vanguard Strike | 앞발로 돌진을 받아낸 뒤 팔꿈치를 접으며 검과 방패를 회수한다. 검끝에서 시작한 짧은 강철 잔상은 확인된 끝점으로 모인다. |
| Dwarf · Stonebound Leap | 착지 직후 양 무릎이 더 깊이 구부러지고 반대 팔이 벌어져 충격을 받아낸다. 범위 외곽선 안에서 착지점의 균열 세 갈래가 퍼진다. |
| Elf · Piercing Line | 시위에서 엄폐 끝점까지 한 줄이 남고 시위 손은 어깨 뒤로 돌아온다. 기본 화살 모델과 적의 확정 피격 표시는 별도로 재생한다. |
| Mage · Stone Lance | 빈손을 모았다가 내밀면서 앞다리로 무게를 받는다. 손에서 시작한 황갈색 잔상 끝에 얇은 석판이 갈라져 돌창 윤곽을 그린다. |

세 전방 공격은 서버가 보낸 위치를 사용하며 소켓이 엄폐보다 앞에 있으면 공격 원점에서 시작한다. 대미지, 전투 거리, 판정 시각은 기존 서버 정의를 사용한다. [기준 연출과 공식 RPG 자료](../../research/2026-11-25-hero-forward-impact.md)

## 검증 결과

- 기준과 후보의 패키지 SHA-256 및 클라이언트 런타임 5모듈이 각 입력 커밋과 일치했다. [기준 빌드](../lobby-hud-lumi-20261125/build.json) · [후보 빌드](build.json) · [패키지 대조](package-check.json)
- 같은 R15 리그·조명·카메라에서 준비, 방출 41ms, 119ms를 전후 24장 비교했다. 첫 후보 0.115.126에서 약하게 보인 돌창의 면과 착지 균열을 보강했다. 카메라 뒤쪽에서 볼 때 착지 중심 일부가 드워프의 다리에 가린다. [전후 화면](comparison.jpg)
- 집중 Studio 검사 51건을 통과했다. 기준은 실행한 39건 중 29건에서 개선 조건에 미달했다. 근거리 엄폐와 장비 소켓, 균열의 지면·반경, 잔상 회수와 효과 예산 초과 시 대체 표시를 확인했다. [집중 검사와 계측](studio-results.json)
- 자신 1명과 아군 3명의 효과를 겹친 장면에서 Beam 71→13, 표면 56→0, 보조광 1→0, 입자 요청 8→0이었다. 양쪽 빌드에서 적 붉은 예고선 16개와 피해 숫자 42를 확인했다. 이 수치는 Studio 장면의 효과 개수다. [겹침 계측](studio-results.json)
- 기존 Studio 회귀 24묶음 중 22묶음 259,582건을 통과했다. R6·R15의 128개 기술, 자세·발사·타격·취소·VFX 예산을 포함한다. 두 빌드 모두 Lightning Line 가지 검사와 Caldera Central Plume의 누락된 BillboardGui 검사에서 각각 중단됐다. CPU 15,270건, 패키지 정적 336건 및 변경 Luau 8파일 컴파일을 통과했다. [회귀 결과](studio-results.json)

```sh
run-in-roblox --place builds/0.115.127/TheLastThrone-0.115.127.rbxlx --script tests/hero-forward-impact-native.luau
python3 tests/single-build.spec.py --artifact builds/0.115.127/TheLastThrone-0.115.127.rbxlx
```

후보는 미게시 상태다. QA·ART는 시험 Experience의 로비→배틀, 실제 4인 교전에서 스킬과 적 예고 구별, 저사양 터치 실기기의 프레임 시간과 사용자 타격감 수용을 확인한다.
