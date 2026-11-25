# 검격·단발·전기 화살·비전탄 방출

2026-11-25 · TLT-033/057/059 · 기준 0.115.117 · 후보 0.115.120

| 영웅 | 기술 | 준비와 타격 |
| --- | --- | --- |
| Knight | Oathbreaker Strike | 방패 뒤에서 검을 들어 올린 뒤 앞발에 체중을 싣고 어깨 위에서 내려벤다. 금빛 검격은 한 호로 움직인다. 기존 Oath 소모·자세 붕괴 피드백은 서버 확인에 맞춰 표시한다. |
| Dwarf | Gunner Shot | 오른손 도끼를 든 채 왼손 포구로 조준하고 뒷무릎으로 한 발의 반동을 받는다. 탄선이 서버 엄폐 지점까지 이어진 뒤 끝점 쪽으로 짧아진다. 발사한 플레이어에게 짧은 포구 섬광을 표시한다. |
| Elf | Spark Volley | 활을 고정하고 발사마다 시위 손을 회수한다. 첫 두 화살은 전기 획을 서로 다른 쪽으로 떨치며, 셋째 화살은 앞발 디딤과 끝점의 짧은 전기 획을 강조한다. |
| Mage | Mana Bolt | 지팡이 곁으로 팔을 모으고 지팡이 끝을 내민다. 회전하는 비전 결정의 앞부분이 서버 끝점에 닿으면 짧게 갈라진다. 효과 한도에 도달하면 기본 명중 섬광을 표시한다. |

서버 승인 발사 시각, 피해, 타격 범위, 상태 효과와 엄폐 경로를 사용한다. [이전 연출과 공식 RPG 자료 비교](../../research/2026-11-25-hero-weapon-releases.md)

## 검증

- Rojo로 고정한 두 빌드의 SHA-256과 각 런타임 모듈 7개의 커밋 소스 일치를 확인했다. [기준 빌드](../epic-third-chapter-entry-silhouettes-20261125/build.json) · [후보 빌드](build.json) · [패키지 대조](package-check.json)
- 같은 R15 리그, 무기, 조명, 카메라에서 준비·방출·회수 또는 착탄 장면을 총 24장 비교했다. 0.115.118의 가려진 검격과 옅은 셋째 전기 획을 0.115.120에서 보강했다. 근접 비교 각도에서 검격 중간 일부는 여전히 표적 몸과 겹친다. [전후 화면](comparison.jpg)
- 집중 Studio 검사 40건 통과. 기준 38건 중 28건은 이번 개선 조건을 충족하지 못했다. R6·R15 준비와 반동, Gunner Shot의 근접 엄폐, Spark Volley의 중복 펄스 무시, Mana Bolt의 실제 비행·착탄·예산 초과 시 대체 표시를 포함했다. [Studio 결과](studio-results.json)
- 한 플레이어 시점에서 네 영웅 효과를 겹친 Studio 장면의 Beam은 74→12, 표면은 88→16, 보조광은 12→0, 입자 요청은 8→0이었다. 적의 붉은 예고선 16개와 피해 숫자 42는 두 빌드에서 표시됐다. 이 수치는 재현 장면의 인스턴스 계수다. [Studio 결과](studio-results.json)
- Studio 회귀 20묶음 262,248건 통과. 128개 기술 각각의 R6·R15 재생, 초기 투사체 수명, 아군 효과 우선순위, 표식·취소·아이콘 연출을 확인했다. [회귀 결과](studio-results.json)
- CPU 15,294건과 패키지 정적 336건을 통과했다. 별도 CPU 검사 두 개는 기준·후보 모두 기존 Luau 복합 대입의 순수 Lua 파싱 오류와 `TargetAssistRules` 스텁 누락으로 중단됐다.

```sh
run-in-roblox --place builds/0.115.120/TheLastThrone-0.115.120.rbxlx --script tests/hero-weapon-releases-native.luau
python3 tests/single-build.spec.py --artifact builds/0.115.120/TheLastThrone-0.115.120.rbxlx
```

후보는 미게시 상태다. QA·ART가 승인된 테스트 Experience에서 로비→배틀, 실제 4인 교전의 예고·타격 판독, 저사양 터치 기기의 프레임 시간과 사용자 타격감 수용을 확인한다.
