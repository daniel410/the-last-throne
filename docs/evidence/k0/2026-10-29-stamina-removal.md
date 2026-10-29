# Stamina 제거: 세션 전투 원형

2026-10-29 · TLT-005/006/008/042/052 일부 · ENG → QA · 상태: 구현 및 격리 소스 검증, 실제 플레이 수용 대기

최신 사용자 결정에 맞춰 Knight·Elf·Dwarf의 물리 기술에서 Stamina 비용·부족 거부·회복을 제거했다. 모든 기술의 서버별 쿨다운은 유지하고 Mage 주문은 MP 비용과 쿨다운을 모두 검사한다. 공통 공격·방어·회피·달리기는 자원을 사용하지 않으며 공격·회피의 기존 동작 시간과 입력 제한은 별도 쿨다운이 아니다. 기존 캐릭터 객체가 재사용되는 경우 오래된 `K0Stamina`/`K0MaxStamina` 속성을 지운다. 세션 원형에는 저장된 Stamina 프로필이 없으며 영구 저장 이관을 구현하거나 검증한 것은 아니다.

로비 스킬 설명은 물리 기술의 쿨다운만, 마법 기술은 MP와 쿨다운을 보여 준다. 전투 HUD는 Stamina 막대 없이 서버가 복제한 최대 MP가 있을 때만 MP를 표시한다. 이 표시 방식은 추후 MP가 있는 다른 직업에도 대응하지만 마법궁수 전직이나 MP 지급을 구현하지 않는다. 직업별 기존 스킬·수치·5슬롯 연습 모드와 비영속 세션 경계는 유지한다.

## 빌드 전 소스 검증

| 조건 | 결과와 한계 |
| --- | --- |
| `lua tests/k0-rules.spec.lua` | 125개 통과. 순수 규칙 검사이며 Studio 실플레이가 아니다. |
| `lua tests/k0-hero-session.spec.lua` | 89개 통과. 서버 세션 신원·전환·쿨다운 경계를 검사하며 영구 저장은 포함하지 않는다. |
| `python3 tests/make_k0_source_probe.py --output-dir /private/tmp/tlt-stamina-server --test-script tests/k0-basic-attacks-native.luau` 다음 `run-in-roblox --place /private/tmp/tlt-stamina-server/tlt-k0-qa-empty.rbxlx --script /private/tmp/tlt-stamina-server/source-probe.luau` | 격리 Studio 서버 fixture 452개 통과. 세 물리 직업의 연속 기술·독립 쿨다운과 재사용 거부, Mage MP 비용·부족·회복, 4직업의 구 속성 정리·재생성 및 세션 쿨다운 유지를 검사했다. 신원은 모형이고 실제 Player·원격 전송은 아니다. |
| 같은 생성기에서 `tests/k0-resource-ui-native.luau`를 선택해 격리 Studio 실행 | GUI 인스턴스 및 상태 변경 83개 통과. 12개 기술의 설명, 잠금/빈 슬롯, MP 막대 표시·초기화를 확인했다. LocalPlayer를 모형으로 대체했으므로 실제 렌더·입력이나 화면 크기 수용은 아니다. |
| 같은 생성기에서 `tests/k0-timing-native.luau`를 선택해 격리 Studio 실행 | 106개 통과. 최초 실행은 기존 HP 회복분을 빠뜨린 과거 테스트 기대값으로 5개 실패했다. Heartbeat의 피해 후 회복을 기대값에 반영한 뒤 재실행했다. 실제 Player·지연·입력 전송은 아니다. |

격리 검사에서 기존 `203785492` 자산 유형 경고가 다시 출력됐다. 유형 불일치의 출처와 게시 Experience 사용 권한은 이 작업에서 확인하지 못했다. 위 결과는 별도 게임 빌드 또는 게시/사용자 플레이 검증이 아니다. 빌드 결과와 정확한 입력 커밋은 [빌드 기록](build.md)에 별도로 남긴다.

## 미검증과 인계

QA는 같은 빌드의 실제 Player로 네 직업의 연속 시전·쿨다운·MP 부족, 캐릭터 전환/사망·리스폰과 화면 표시를 확인한다. 모바일·패드·4인·지연·실제 사용자 체감은 미검증이다. PLAN/ENG는 자원 제거 후 물리·마법 사용 빈도와 MP 비용/회복을 별도 밸런스로 검토하고, 정식 성장·저장 및 전직별 MP 경계를 구현할 때 이 세션 fixture와 분리해 검증한다. 부모 티켓과 G1/G3를 완료로 표시하지 않는다.
