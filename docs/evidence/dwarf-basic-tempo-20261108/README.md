# 드워프 기본 공격0.65초·지속 피해 보정 적용

2026-11-08 · TLT-005/013/014/015/027/054/055/057/084 · ENG/ART → QA/DES · 0.86.4 · Studio 적용·미게시

사용자가 [디아블로/워크래프트 공속·민첩 조사](../../research/2026-11-08-attack-speed-dexterity-diablo-warcraft.md)의 적용을 요청했다. 추천 순서대로 드워프 기본 주기를 중심 후보0.65초로 고정하고 한 방 피해를 보정했다. 민첩의 기존 역할/계수는 유지하며 미정인 후반 소프트캡 곡선을 임의 확정하지 않았다. 부모 티켓의 실전 밸런스/기기/최종 미술 수용은 후속이다.

## 변경

| 항목 | 이전 | 현재 |
| --- | ---: | ---: |
| 기본 공격 주기 | 0.42초 | **0.65초** |
| 첫 타격 시각 | 0.22초 | 약0.34048초 |
| 한 방 피해 계수 | 0.75 | 약1.160714 |
| DEX 미투자 이론APS | 2.38095 | 1.53846 |
| 최대DEX 배율의 주기 | 0.21초 | **0.325초** |
| 최대DEX 배율의 이론APS | 4.76190 | 3.07692 |

`dwarfBasicTempo=0.65/0.42`로 준비/active/회복/hitDelay를 모두 같은 비율로 늘렸다. 기존 Mixamo 내려찍기와 종료 idle 복귀를 같은 경로로 느리게 재생하며 새 가로/대각 클립을 섞지 않는다. raw 저작 클립0.42초와 런타임0.65초를 구분한다. 기존 리타이밍 앵커가 새 시각에 접촉/복귀를 맞춘다. 실제 이식/재베이크가 필요한 변경이 아니므로 Blender 원본/채널 Action/무기 소켓은 수정하지 않았다.

새 동작의 준비 약0.247619·active0.154762·회복0.247619초다. 같은 배율로 피해 계수를 올려 `0.75/0.42 = 1.160714/0.65`의 기본 지속 피해를 보존한다. 기사 평균0.50초 대비 이제 드워프의 횟수는약23.08% 적지만 한 방이 더 크다. 지속 피해 보존은 초기 피격 시각/막타 횟수/폭딜/기술 혼합까지 같다는 뜻은 아니다.

`K0MeleeMotion`의 연속 공격 진입 가속도도 저작 초 단위에서 현재 행동 초 단위로 제곱 비율 환산했다. 전체 길이가 같을 때는 기존 값과 같고, 새 기본 주기에서는 회복 취소/다음 공격 연결의 가속도가 잘못 확대되지 않는다.

- 기사3연격0.42/0.46/0.62초·피해0.75/0.90/1.20, 드워프 스킬/쿨다운, 원거리 클래스는 유지한다.
- DEX 투자당 기본 공속+0.5%/최대100%, 이속+0.1%/최대30%와 투자분 기준 계산을 유지한다. DEX0/40/100/200에서 드워프 주기는0.650/0.54167/0.43333/0.325초다.
- 사거리5.5·각100·최대3표적과 **자세 피해12/타격은 그대로**다. 자세 피해의 초당 양과 적중당 효과 빈도는 공격 횟수에 따라 감소한다. 기본 DPS 보정과 구분해서 실전 수용해야 한다.
- 피해/주기·기본 공속 시간축은 서버가 확정한다. 별도 기본 공격 쿨다운/자원은 추가하지 않았다. 성장/저장/장비 소유권·기존 투자분은 변경하지 않았다.

## 검증

[정본 결과](results.json)·[입력 해시](test-inputs.json). **17묶음·116,938검사 통과**.

1. [모션 통합](motion-native.log): 기존 Blender 독립 평가와 런타임의 새 리타이밍을 비교한다. 고정0.42초 기대 대신 저작 시간→현재 Config 주기 환산을 사용한다. R6/R15의 팜/도끼날 방향·기본기/스킬 종료 손목·도끼 idle 복귀·연격/회복 취소·2배 공속·기사/활/화살통 회귀를 통과했다. 저작 곡선 자체는 변경하지 않았다.
2. [실제 서버 템포](tempo-native.log): `startAttack/processCombatSamples/acceptAction/stepPlayer`를 최종 return만 치환한 테스트 복제 모듈로 실행한다. 피해/판정/이동 검증 함수는 모킹하지 않았다. 신원만 trusted context mock을 사용한다. DEX0/40/100/200/300/316 ×30/60/144Hz ×공격력100/337/969의54경우·2429검사. 타격 전 피해0, 첫 도래 서버 프레임에서1회 피해, 반복 표본 중복 없음,0.65/R 전 재공격 불가와 버퍼 연결을 확인했다. 실플레이어/RemoteEvent 수송 검사는 아니다.
3. 실제 반올림 피해는공격력100에서116,337에서391,969에서1125다. 같은 배율의 이전 기본DPS와 비교한 최대 차이는**약0.13986%**로 표본 전부1% 이내였다. 이는 기본/정상 방어 상태의 표본 결과이며 모든 적/스킬/강화/적중 효과의 최종 밸런스 수용은 아니다.
4. [기존 서버7경우](selected-basics-native.log): 드워프 사거리의 선택/미선택·옆 표적 회전·내려찍기 타격 시각·중복/버퍼·벽 차단·건너뛴 active 회수의32검사. 기존 전체K0 서버 검사를 통과했다고 주장하지 않는다. 바뀐 드워프 기대 피해와 타이밍을 갱신했으며 다른 클래스 수치 기대는 유지한다. 선택 필터와 격리 Place 생성은 `tools/prepare-dwarf-tempo-tests.py`로 재현한다.

```sh
python3 tools/prepare-mixamo-dwarf-tests.py /tmp/tlt-dwarf-tempo-native
run-in-roblox --place /tmp/tlt-dwarf-tempo-native/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-dwarf-tempo-native/source-probe.luau
python3 tools/prepare-dwarf-tempo-tests.py /tmp/tlt-dwarf-tempo-server
run-in-roblox --place /tmp/tlt-dwarf-tempo-server/tlt-dwarf-tempo-empty.rbxlx --script tests/dwarf-basic-tempo-native.luau
run-in-roblox --place /tmp/tlt-dwarf-tempo-server/tlt-dwarf-tempo-empty.rbxlx --script /tmp/tlt-dwarf-tempo-server/server-probe.luau
```

실행 로그의203785492 자산 유형 경고는 assertion 성공과 별도다. 실제 입력/네트워크·여러 체형/최종 스킨·장기 처치시간·기술 혼합·4인+AI·사용자 무게감 평가는 미검증이다. 다음 담당 QA/DES가 느려진 첫 타격과 한 방 피해, 자세 붕괴 빈도를 실전에서 수용한다.

## Studio·문서·복구

실제 TLT Place70829337938054의 Edit에서 기존 원문 정확 비교 후 Config/MeleeMotion 두 소스를 적용하고 새 원문 일치와 복제Config require를 확인했다. [Studio 기록](studio-source-readback.json). 기존 글로벌 require 캐시는 검증 근거로 쓰지 않았다. Roblox 게시는 하지 않았다.

연구 표/JSON은0.86.3의 비교 기준으로 보존한다. 계산 도구는 작성 당시 소스 커밋을 읽도록 고정해 이후 적용값을 과거 조사표에 섞지 않는다. 현행 값은 이 기록과 Config가 정본이다. 복구할 때 이 작업의 Config/MeleeMotion 변경을 이전0.86.3으로 역적용하며 기존 종료 자세 수정은 유지한다. 사용자 미커밋3D/삭제/장비 컨셉 작업은 포함하지 않았다.

## 고정 빌드·마감

`0.86.4`의 소스 커밋은 `0814db02429275d093f2b9770ad8dcab5ee059f8`다. `python3 tools/build-game.py --source 0814db02 --record docs/evidence/dwarf-basic-tempo-20261108/build.json`으로 `builds/0.86.4/TheLastThrone-0.86.4.rbxlx` 단일 빌드에 성공했다. SHA256은 `d3bc97bea2657ff582ff98281fe85f81c97cf1a525111abaac120242d5d20528`다. [빌드/LFS 입력 기록](build.json).

동일 파일에 `run-in-roblox --place builds/0.86.4/TheLastThrone-0.86.4.rbxlx --script /tmp/tlt-dwarf-tempo-pinned.luau`를 실행해17묶음·**116,938검사 재통과**했다. pinned 스크립트는 위 모션 통합+새 서버 템포+기존 서버7경우를 순서대로 연결하며 실제 런타임 모듈을 치환하지 않았다. private 함수 노출은 테스트 복제 모듈만 사용한다. [정본 결과](pinned-results.json)·[원시 로그](pinned-native.log).

소스 커밋의 origin/main 푸시 성공을 확인했다. 새 LFS 자산은 없으며 기존 빌드 입력은 빌드 도구가 해시 검증했다. 일반 빌드이며 Roblox 게시/릴리스 태그는 수행하지 않았다.
