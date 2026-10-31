# 영웅·몬스터 피격 표시 · 0.47.0

2026-10-31 · TLT-005/032/033/084 · ENG/DIR → QA. 사용자 요청: Shield Bash 수정 게시, 이어서 영웅이 피해를 받을 때 짧은 신음과 아주 약한 붉은 효과, 몬스터 타격 효과 강화. [조사/선택 근거](../../research/2026-10-31-damage-feedback.md).

## 변경

- CombatService는 실제 TakeDamage 전후 HP 차이가 양수일 때만 캐릭터에 K0HurtDamage/MaxHealth/At를 확정한다. 회피·완벽 방어·전체 흡수·ForceField는 pulse0이다. 피해/방어 수치·서버 판정은 그대로다.
- K0PlayerHitFeedback: 재사용 Sound 하나, 설치된 Roblox 내장 `rbxasset://sounds/ouch.ogg`를 작은 음량0.24로 재생한다.4클래스별 약한 피치 차이, 최소0.55초 간격. 원본 오디오를 복제/업로드하지 않는다. 엔진 preload 성공, TimeLength **0.33229초**(설치 파일 afinfo의0.449초와 엔진 해석값이 다름).
- 화면 중앙 적색 불투명도2.5~4.5%, 가장자리10~18%,0.42초 fade. 입력을 가리지 않는 GUI이며 반복 피격에도 불투명도가 합산되지 않는다. 캐릭터 교체/제거 시 연결·소리·색을 정리한다. 회복이나 MaxHealth 변경을 피해로 간주하지 않는다.
- 몬스터 섬광/파편을 기존 루트 안쪽에서 공격자 쪽 접촉면으로 이동한다. 짧은 클래스별 윤곽·큰 섬광·2개 교차 광선·기존5개 파편을 강화한다.24개 효과 상한/임시 정리를 유지한다.
- 기존 몬스터 메시/Blender 동작에0.18초 국소 몸 반응을 합성한다. 보스 강도 절반, 기존 발 경계 보정 경로에 포함하며 서버 루트·공격/스턴 시간을 바꾸지 않는다.
- 앞선0.46.3 Shield Bash 방패 선행과5초 스턴을 포함한다. 기존 보상/저장/상품 계약은 유지한다.

## 검증

- 미게시 Rojo fixture에서 **10,699검사 통과**: 서버 기본/방어947 + 타격102 + 몬스터 동작9,525 + 방패86 + 신규 피격39. `regression-native.log`. 이후 실제10종 flinch의 발 경계/루트/HP/만료 검사를 추가해 고정 빌드에서 재확인한다.
- `damage-feedback-native`:4클래스 GUI 상한/연속 소리 중복 억제, 무효 값, 이전 캐릭터/오래된 pulse/중복 시각 무시, 리스폰/시간 경과 정리, 반응 루트 불변·복귀, 실제 Sound preload 확인.
- 첫 전체 fixture는 방어 시작0초를 완벽 방어로 잘못 예상해 실패했다. raiseTime0.10초 뒤의 정상 perfect 구간으로 시험을 수정하고 통과했다. `guard-fixture-initial.log` 보존. 동시 native CLI가50312포트를 사용한 시작 실패도 `fixture-port-contention.log`에 남겼다.

## 빌드·게시

고정 소스 **57fcfbf5698898984b1f8297e37f262cf51142a1**에서 두 빌드 성공.24개 embedded 핵심 모듈과5개 검증 입력 해시를 확인했다. 최종 시험 입력은 **fe69d2fb184b094574dd5a6f56220a02df62af67**다. 고정 소스 뒤의 변경은 QA 대기 조건만이며 게임 소스/산출물 바이트를 바꾸지 않았다.

고정 Battle에서 서버947 + 타격102 + 실제10종 몬스터9,553 + 방패86 검사가 통과했다. 같은 묶음의 피격 GUI fade 검사는0.5초 고정 sleep이 끝났을 때 아직 Tween이 종료되지 않아 실패했다. `fade-wait-initial.log`/`final-native.log`에 보존했다. 실제 완료를 기다리는2초 상한 predicate로 QA 대기를 수정한 뒤 **같은 고정 파일**에서 피격39검사 통과(`final-feedback-native.log`). 합계 **10,727검사 통과**이며 초기 전체 묶음을 모두 성공으로 바꾸어 보고하지 않는다.

정상 Studio Client의 CreateHero(Knight) → StartTraining → 실제 이동 → Goblin 피격 → Shield Bash 반격으로74프레임 관찰했다(`client-observation.json`). 실제 적용 피해80, 신음1회·Sound 로드/재생/TimePosition 증가, 중앙 적색3.78%·가장자리15.12% 및 fade, 몬스터 섬광/윤곽·교차 광선2개를 확인했다. 최초 spawn 관찰 HP100은 스탯 적용 이전 값이며 피해 직전 HP로 사용하지 않는다. 첫 피격 후170 + 서버 확정 피해80에서 직전250을 유도했다. 이후 약0.31 회복이 관찰됐다. 생명/루트/피해/시각을 덮어쓴 QA가 아니다. 실제 스피커 청음의 주관적 품질로 간주하지 않는다.

| 게시 대상 | Place ID | Roblox 게시 버전 | 현지 시각 |
| --- | --- | --- | --- |
| Lobby |70829337938054|19|2026-10-31 12:52|
| Battle |129388473517823|5|2026-10-31 12:59|

두 파일을 Studio Publish As에서 **기존 The Last Throne Experience10773575153의 해당 Place**에 게시했다. 자산 권한 게시 안내를 적용하고, Manage Audience의 테스트 준비 완료/기존 제한 범위를 확인했다. Dashboard **Show published only**에서도 위 현재 게시본을 확인했다. 기존 Private 공개 범위와 TD Place/잔액/상품은 보존한다. [게시 상세·SHA·복구](publication.json)와 `lobby-published.jpg`/`battle-published.jpg`에 증거를 남긴다. Roblox 원격 파일의 압축/메타데이터까지 로컬 원시 바이트와 같다고 주장하지 않는다.

주석 태그 `v0.47.0`은 실제 빌드 소스57fcfbf에 연결한다. 새 공개 출시/상위 게이트 전체 완료를 뜻하지 않는다. 다음 QA는 게시 Roblox 클라이언트의 음량·시각·Teleport/저장, 실기기/다인 성능을 확인한다. 이번 정상 플레이 관찰은 Studio Client이며 게시 클라이언트 실기기 수용과 구분한다.
