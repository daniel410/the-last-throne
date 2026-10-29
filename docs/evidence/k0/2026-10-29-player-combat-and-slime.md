# 실제 Player 전투 점검과 슬라임 분열 타격 수정

2026-10-29 · TLT-005/006/007/008/032/036/084 일부 · ENG/QA 자체 검증 · 전체 티켓 수용 대기

## 0.18.9에서 관측

입력 빌드는 `0.18.9`, 소스 `ea21dd0e59a4cf55248699608030470e78ed2ec5`, SHA-256 `131694ba180af11c4c644ea03221b6c9281a140717008ebe3933983bf48d2792`다. 독립 비게시 Studio Play에서 R15 Player 1명과 도구로 보낸 PC 입력을 사용했다. 서버에서 시험 HP를 바꾼 사례는 아래에 별도로 표시한다. [속성 관측 자료](2026-10-29-play-0189.json).

| 조건 | 실제 결과 | 범위 |
| --- | --- | --- |
| Knight E 유지/해제, Q 유지/해제 | 달리기 속도 24→16, 방어 상태 Block/속도 8→Idle/16 | 한 플레이어 입력과 복제 상태 |
| V 후 R 회피 | 동작 완료 뒤 회피 시퀀스 1→2 | 별도 쿨다운 없이 연속 수락. 기기별 이동·벽 수용은 아님 |
| 공격 버튼 1.6초 유지 후 해제 | 공격 시퀀스 4, 해제 0.9초 후에도 4 | 유지/해제 경로의 단일 관측 |
| 전체 HP에서 Z, MP 없는 Knight에서 C | 각각 `HealthFull`/`NoManaPool`, 해당 물약 각 3개 유지 | 세션 시험 물약 |
| 서버에서 HP를 500으로 설정 후 약 5.016초 대기 | 509.999, 약 초당 1.994 회복. `Health` 대체 Script 존재 | 단일 실제 Player에서 초당 최대 HP의 약 0.2%; 중복 기본 회복 징후 없음 |
| 손상 HP에서 Z 3회, 추가 Z | 1회 후 수량 3→2 및 약 40 HP 증가, 3회 후 0·`ItemEmpty` | 회복 시간에 자연 HP 회복도 포함. 정식 가방/저장 아님 |
| 실제 조작으로 Slime 교전, 사망 후 대기 | 기본 공격으로 Slime HP 220→145. Player 사망 뒤 같은 Knight가 HP 1000으로 재생성 | 아이템 수량도 시험 프리셋으로 초기화됨 |
| Provoke 사용 뒤 테스트 서버에서 Player 사망 처리 | 남은 쿨다운 약 11.78→리스폰 후 6.15초; 조기 사용은 `SkillCooling`·공격 시퀀스 0 | 현재 세션의 리스폰 경계. 영구 저장/재접속 아님 |

### 발견한 결함

슬라임에 접근한 뒤 시험 서버에서 부모 HP를 75로 설정하고 Knight 기본 공격을 한 번 입력했다. 두 `SmallSlime` 생성은 관측됐지만 그중 하나가 생성 약 0.014초 후 같은 공격 시퀀스 1에서 사망했다. 기존 활성 검격의 후속 프레임이 새로 생긴 자식까지 대상으로 삼을 수 있었다. 수정 전 서버 fixture도 같은 조건에서 자식 HP가 55에서 -20으로 변해 실패했다. 이는 실제 Player 1명과 제어된 HP 조건의 재현이며 여러 플레이어의 네트워크 지연 실험은 아니다.

## 수정과 소스 검증

부모를 처치한 **해당 타격의 적중 집합**에 새 자식을 등록해 그 타격의 후속 샘플이 자식에 피해를 주지 않게 했다. 다음 별도 공격, 다른 플레이어의 공격과 Rapid Fire의 다음 화살은 기존처럼 자식을 타격할 수 있다. 분열 크기·HP·재생성 조건은 바꾸지 않았다.

- 수정된 실제 서버 소스의 격리 Studio `tests/k0-basic-attacks-native.luau`: 466개 통과. 기본 검격·Whirlwind의 새끼 보호, 다음 공격·다른 플레이어 공격·연속 사격의 다음 화살은 유효한지 검사했다. Player 신원 모형과 가상 시각을 사용하는 fixture다.
- `tests/k0-timing-native.luau`: 106개 통과. 첫 명령은 보고서상 통과였으나 종료 코드 1이었고 원인은 확인하지 못했다. 동일 소스의 재실행은 종료 0이었다. `lua tests/k0-rules.spec.lua` 125개, `lua tests/k0-hero-session.spec.lua` 89개 통과.
- 고정 빌드 검사와 실제 Player 재검증은 아래와 [빌드 기록](build.md)에 기록한다.

## 0.18.10 고정 빌드와 실제 Player 재검증

입력 소스는 `a054243d2ce4d4c4aa49075f36525e5869afa2f8`, `VERSION=0.18.10`이다. Rojo 7.7.1로 만든 로컬 빌드의 크기는 907,341 bytes, SHA-256은 `e7e0fdf6ce5ae63ab0be90afa6b06e65515960abbda0449def27a4d90c662b00`이다. 빌드 전 소스 커밋과 `origin/main`의 일치를 확인했다. [빌드 파일](../../../builds/0.18.10/TheLastThrone-0.18.10.rbxlx)은 Git에서 제외된 로컬 산출물이다.

- 고정 빌드의 격리 Studio 서버 fixture: `tests/k0-basic-attacks-native.luau` 466개, `tests/k0-timing-native.luau` 106개, `tests/k0-build-smoke.luau` 458개 통과. 각 명령 종료 0, smoke의 실패 및 수집 런타임 오류 0이다. [서버](slime-01810-server.log) · [타이밍](slime-01810-timing.log) · [smoke](slime-01810-smoke.log). 모두 Player 0명의 서버 검사이며, 다른 플레이어와 Rapid Fire 후속 화살은 fixture 조건에서 확인했다.
- 독립 비게시 Studio Play의 R15 Player 1명이 도구로 보낸 PC 입력으로 Knight를 조작했다. 시험 서버에서 부모 HP를 75, Player HP를 1000으로 설정하고 기본 공격을 1회 입력하자 시퀀스 1에서 생성된 작은 슬라임 두 마리는 각각 HP 55/55, 크기 0.5로 살아 있었다. 두 번째 공격 시퀀스 2에서는 두 자식이 피해를 받고 사망했다. 자식 생존 및 이후 공격 가능 여부를 실제 Player 경로로 확인한 결과다.
- 같은 빌드에서 Mage를 선택하고 C를 입력했다. MP가 100/100일 때 `ManaFull`, 수량 3을 유지했다. Gravity 사용으로 MP 80이 된 후 C 입력 시 MP 100, 수량 2 및 HUD `MP x2`를 확인했다. 자연 회복과 입력 간 시간은 통제하지 않아 정확한 물약 회복량 측정으로 간주하지 않는다. [실제 Player 속성 관측](2026-10-29-play-01810.json).

고정 빌드 검증 명령은 아래와 같다. 서버 로그에는 Studio `MaterialManager`의 `debug.profileEnd` 경고와 기존 자산 유형 경고가 있으며, smoke의 수집 오류 0과 구분한다.

```sh
run-in-roblox --place builds/0.18.10/TheLastThrone-0.18.10.rbxlx --script tests/k0-basic-attacks-native.luau
run-in-roblox --place builds/0.18.10/TheLastThrone-0.18.10.rbxlx --script tests/k0-timing-native.luau
run-in-roblox --place builds/0.18.10/TheLastThrone-0.18.10.rbxlx --script tests/k0-build-smoke.luau
```

## 남은 검증

다음 담당 QA/DES는 나머지 직업과 무기·스킬 전투 흐름, Mage MP 부족, 분열의 화면 가독성과 사용자 조작감을 확인한다. QA/ENG는 다인 네트워크·지연, 모바일/패드, 게시 클라이언트 및 저장/재접속을 별도로 확인한다. HP 중복 회복의 관측은 한 Player의 한 조건에 한정된다. 기존 `203785492` 자산 유형 경고는 이 작업에서 출처를 확인하지 못했다. 부모 티켓과 G1/G3를 완료로 표시하지 않는다.
