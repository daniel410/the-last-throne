# 기본 스킬 동작과 명중 효과

2026-10-28 · TLT-008/032/036/084 · 엔지니어링·디자인·QA · 세션 시험 원형

네 직업의 기본 스킬 12개에 기존 TD 무기·리그를 활용한 절차적 준비/발동 자세와 효과를 적용했다. 별도의 Roblox Animation 자산을 업로드하지 않았다.

| 영웅 | 스킬별 시험 연출 |
| --- | --- |
| Knight | Shield Bash는 방패를 앞으로 밀고 방패 충격을 표시한다. Whirlwind는 상체 회전·무기 궤적과 광역 원을 표시한다. Provoke는 방패/검을 들고 외치듯 동작하며 실제 도발된 적에게 주황색 표시를 준다. |
| Dwarf | Overhead Smash는 도끼를 머리 위로 들어 내려치고 수직 타격을 표시한다. Axe Throw는 팔을 젖혔다 뻗으며 투척 도끼와 명중 효과를 표시한다. Ground Slam은 양팔 준비·내려찍기·충격 원과 타격 파편을 표시한다. |
| Elf | Aimed Shot은 깊게 활시위를 당기고 정밀 명중을 표시한다. Rapid Fire는 서버가 수락한 각 화살의 발사 시점에 맞춰 시위를 풀고 다음 화살을 다시 당긴다. Multi Shot은 여러 화살과 각각의 명중을 표시한다. |
| Mage | Mana Bolt는 지팡이를 앞으로 내밀어 마력 타격을 표시한다. Water Ball은 양팔로 모아 내밀고 물빛 충격·물방울을 표시한다. Gravity는 양팔을 올렸다 내밀고 보라색 광역·중력 타격을 표시한다. |

피해가 있는 기술의 효과 ID는 서버가 실제 체력 감소를 확인한 후 `K0HitEffect`에 함께 보낸다. 피해·상태 판정은 클라이언트 효과에 의존하지 않는다. Provoke는 피해가 없으므로 서버가 발급한 도발 상태와 만료 시각으로 표시한다. 투사체·동작·효과는 표현 전용이다. Axe Throw는 아직 투척 복제물을 보여주며 실제 무기 소유권/회수는 변경하지 않는다. 소리는 기존 임시 Roblox 내장 소리다.

## 검증

- 격리 Studio `tests/k0-skill-animation-native.luau`: R6/R15의 12개 스킬 준비/발동 팔·활시위, Rapid Fire 재당김 조건 30개 통과. [로그](skill-visuals-0170-animation.log). 이는 관절 검사이며 미적 수용이 아니다.
- `tests/k0-hit-effects-native.luau`: 11개 피해 기술의 스킬별 효과·클래스 경계·객체 정리 등 99개 통과. [로그](skill-visuals-0170-effects.log).
- `tests/k0-basic-attacks-native.luau`: 서버 확정 피해의 기술 ID와 기존 피해/스킬 회귀 376개 통과. [로그](skill-visuals-0170-server.log). `tests/k0-melee-motion-native.luau` 40개, `tests/k0-player-weapons-native.luau` 2,177개 통과. [근접](skill-visuals-0170-melee.log) · [무기](skill-visuals-0170-weapons.log). 무기 검사의 이전 투사체 이름 기대값을 현재 코드의 `K0VisualSpell`로 갱신 후 재검사했다.
- 빌드 전 격리 Studio R15 Player: Elf Rapid Fire의 서버 화살 3회와 발사 시각 복제, Aimed Shot의 실제 피해 140과 `precision` 효과, Knight Provoke의 무피해 표식, Whirlwind의 시간에 따른 상체 회전 값을 확인했다. 적의 위치는 격리 시험을 위해 일시적으로 고정했다. 기존 `203785492` 자산 유형 경고 외 콘솔 오류는 관찰되지 않았다.

전체 12개 기술의 실제 Player 모션·효과에 대한 사용자 시각 수용, 모바일·패드·다인·게시 환경, 다양한 체형과 발사-타격 지연 체감은 미검증이다. 다음 담당: 디자인/3D(미적 수용 및 완성 모션), QA(기기·다인·시각 검증), 엔지니어링(정식 투척/회수).
