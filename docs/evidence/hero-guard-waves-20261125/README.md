# 금빛 검격과 보호 기술의 공격 연출

2026-11-25 · TLT-033/057/059 · 기준 0.115.121 · 후보 0.115.123

| 영웅 | 기술 | 준비·타격·회수 |
| --- | --- | --- |
| Knight | Radiant Sweep | 뒷무릎에 체중을 싣고 방패 뒤에서 검을 모았다가 전방으로 올라오는 금빛 검격을 그린다. 기존 범위선은 별도로 표시하고 Oath는 확정 명중에서 읽힌다. |
| Dwarf | Tremor Guard | 도끼를 내려찍고 빈 팔로 몸을 받친다. 짧은 바닥 충격에서 양쪽 지면 균열이 퍼지며, 자신 시점에서는 접점에 작은 석편 두 개가 솟는다. |
| Elf | Warden Arrow | 시위의 화살 한 발이 서버 엄폐 끝점까지 흔적을 남긴다. 약 42ms 뒤부터 잔상이 끝점으로 줄고 시위 손은 가슴 쪽으로 돌아온다. |
| Mage | Searing Ward | 손을 지팡이 쪽에 모은 다음 바깥으로 쓸어 개방된 두 화염 호를 낮게 보낸다. 보호막은 서버가 확인한 수혜자에게 표시된다. |

서버 승인 시각·범위·피해·보호막 수혜자와 엄폐 끝점을 사용한다. [공식 RPG 자료와 기존 연출 비교](../../research/2026-11-25-hero-guard-waves.md)

## 검증

- 두 고정 패키지의 SHA-256과 패키지 런타임 7모듈이 각각 소스 커밋과 일치했다. [기준 빌드](../epic-second-chapter-entry-silhouettes-20261125/build.json) · [후보 빌드](build.json) · [패키지 대조](package-check.json)
- 동일한 R15 리그·무기·카메라·조명에서 네 기술의 준비, 방출 41ms, 방출 119ms를 전후 24장 비교했다. 첫 후보 0.115.122의 가려진 금빛 검격과 짧은 화살 궤적을 0.115.123에서 보강했다. 근접 시점에서 도끼 접점 일부는 영웅 몸과 겹친다. [전후 화면](comparison.jpg)

- 집중 Studio 검사 68건을 통과했다. 기준은 실행한 54건 중 33건에서 개선 조건에 미달했다. 서버 엄폐, 중복 펄스, 독립적인 보호막 부여와 효과 예산 초과 시 화살·범위선 대체 표시를 확인했다. [Studio 결과](studio-results.json)
- 자신 1명과 아군 3명의 효과를 같은 화면에 겹친 Studio 재현에서 Beam 111→24, 표면 160→0, 보조광 6→0, 입자 요청 8→0이었다. 적의 붉은 예고선 16개와 피해 숫자 42는 양쪽에서 표시됐다. 계수는 재현 장면의 인스턴스 수다. [겹침 측정](studio-results.json)
- Studio 회귀 23묶음 262,250건을 통과했다. 128개 스킬의 R6·R15 재생, 보호막 수혜자, 맞은 대상의 표식, 취소, 아이콘 연출을 포함했다. 기존 별도 RPG VFX 검사는 기준과 후보 모두 Caldera Central Plume의 BillboardGui 누락에서 중단됐다. [회귀 결과](studio-results.json)
- CPU 15,282건과 패키지 정적 336건을 통과했다. 두 별도 CPU 검사는 기준과 후보에서 각각 순수 Lua의 Luau 복합 대입 파싱 오류와 `TargetAssistRules` 스텁 누락으로 중단됐다.

```sh
run-in-roblox --place builds/0.115.123/TheLastThrone-0.115.123.rbxlx --script tests/hero-guard-waves-native.luau
python3 tests/single-build.spec.py --artifact builds/0.115.123/TheLastThrone-0.115.123.rbxlx
```

후보는 미게시 상태다. QA·ART는 승인된 테스트 Experience에서 로비→배틀, 실제 4인 교전의 적 예고와 기술 판독, 저사양 터치 기기의 프레임 시간과 사용자 타격감 수용을 확인한다.
