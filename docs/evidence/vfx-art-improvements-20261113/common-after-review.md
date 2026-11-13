# 공통 VFX 개선 후 ART 재검토

TLT-033/057/084 · 이미지 비교 소스 `7a80c50d2198b7233ea42330dc6c12dbde4a5944` ·0.104.26. 최종 엔진 소스는 `c1b578d470a26536bd1a22895f265b91d3c16669` ·0.104.28이며 아래에서 별도 구분한다. 개선 전0.104.25의31장과 개선 후31장을 직접 비교했다. 이 검토자는 공통지원05/06과 길안내07의 구현 담당자이므로 해당 부분은 **구현자 전후 검토**다. 팔레트·명중/Hero 수정은 다른 담당의 변경을 ART 관점으로 재검토했다. 독립 QA/사용자 최종 수용을 대신하지 않는다.

실제 본 자료: [개선 전 시트01](../vfx-art-review-20261113/common/sheet-01.png)·[02](../vfx-art-review-20261113/common/sheet-02.png)·[03](../vfx-art-review-20261113/common/sheet-03.png)·[04](../vfx-art-review-20261113/common/sheet-04.png), [개선 후 시트01](common/sheet-01.png)·[02](common/sheet-02.png)·[03](common/sheet-03.png)·[04](common/sheet-04.png). 개별 PNG와 해시는 [후 manifest](common/manifest.json)에 있다.

## 결과

| 기존 항목 | 직접 본 변화 | 이 범위의 판정 |
| --- | --- | --- |
| ART-COMMON-01 원소 명중 혼합 | Fire05가 주황·Frost07이 옅은청색·Lightning08이 청색·Earth09가 황토/갈색으로 이어진다. 기존 타깃 몸을 칠하던 보라색이 사라지고 접촉 주위에 색이 집중된다. ElfStorm31도 청색 접촉과 녹색 몸/파편의 혼합 대신 청색 계열로 이어진다. | 대표5장면의 팔레트 불일치 개선 확인.30기술 모두를 명중 화면으로 본 것은 아니며 전체128스킬 팔레트 일치는 별도 엔진562검사다. |
| ART-COMMON-02 번개 Focus 보라 | Lightning19의 보석/국소광이 청색으로 바뀌고 Arcane13의 보라와 구별된다. Water/Wind/Fire/Frost/Earth 준비색은 계열별로 유지된다. | 단순 지팡이 모형에서 개선 확인. 실제 지팡이/캐릭터·발사·명중 연속 합성 수용은 별도. |
| ART-COMMON-03 공통 명중 원형·층 중복 | 기본4명중에서 몸통을 감싸던 큰 원형띠가 빠지고 작은 방향성 섬광이 접촉점에 집중된다. 원소 명중의 고유 조형은 남아 있다. | 단일명중 미술 위계 개선 확인. 실제4인+AI에서 목표/위험 가림이나 프레임 비용이 개선됐다고 주장하지 않는다. |
| ART-COMMON-04 드워프 냉색 접촉 | Overhead11/ArmorSplitter12의 큰 옅은청색 띠가 사라지고 노란 세로 타격과 작은 따뜻한 파편이 남는다. | 이전 온색/냉색 혼합 감소 확인. 두 타격의 무게감/실제 도끼 접촉 정렬은 이 스틸로 판정하지 않는다. |
| ART-COMMON-05 치유 인지성 | FullHeal28에서 이전 바닥링 대신 수신자 옆/발밑의 작은 생명 줄기/잎이 보이고 연결선/+HP가 유지된다. 상승 이동은 전용125엔진검사의 위치 변화로 확인했다. | 전체지원의 인과/상승 단서는 명확해졌다. 7a의 단독Heal20 초기 스틸은 약해 최종0.104.28에서 재보강했다. 아래 최종 재촬영에서 작은 상승파편 가시성을 확인했다. |
| ART-COMMON-06 지원3종 구별 | FullHeal28은 작은 생명 줄기/잎, Protect29는 내부가 보이는 금빛 구형 외피/링, Cleanse30은 옆으로 씻겨 나가는 짧은 수평 스트로크로 구별된다. Cleanse 단독22에도 바깥으로 나가는 작은 흰/청색 조각이 보인다. | 단순모형/초기 시점의 형태 차이 개선 확인. 실제 TD Selene·수신자 장비·여러 시간대/동작 수용은 별도. |
| ART-COMMON-07 길안내 위계 | 이번 공통31장면에는 실제 길안내/위험 겹침 화면이 없다. AlwaysOnTop=false와 기존 경로/도착/fallback 유지 검사는 별도 nav.log에 있다. | 구현/엔진 검사 완료. 실제 위험바닥을 가렸던 버그가 재현됐다고 쓰지 않으며 실제 월드 가림 수용은 미검증. |
| ART-COMMON-08 실제 자산·지역·다인 공백 | 비교31장은 중립조명/단순모형이다. 실제 자산·두 지역 조명의 추가6장은 아래 별도 문맥 검토에 기록했다. | 전체 미술 최종 수용은 보류. 추가 실제 자산 문맥 캡처도 합성 stage/stockR15이며 실제 지역맵·다인·실기기 수용과 구분해야 한다. |

## 개선을 직접 확인한 대표 비교

- [Fire 전](../vfx-art-review-20261113/common/005-Fire_Hit_Composite.png) / [후](common/005-Fire_Hit_Composite.png)
- [Lightning 명중 전](../vfx-art-review-20261113/common/008-Lightning_Hit_Composite.png) / [후](common/008-Lightning_Hit_Composite.png)
- [Lightning Focus 전](../vfx-art-review-20261113/common/019-Lightning_Staff_Focus.png) / [후](common/019-Lightning_Staff_Focus.png)
- [FullHeal 전](../vfx-art-review-20261113/common/028-Selene_Full_Heal.png) / [후](common/028-Selene_Full_Heal.png)
- [FullProtect 전](../vfx-art-review-20261113/common/029-Selene_Full_Protect.png) / [후](common/029-Selene_Full_Protect.png)
- [FullCleanse 전](../vfx-art-review-20261113/common/030-Selene_Full_Cleanse.png) / [후](common/030-Selene_Full_Cleanse.png)

## 엔진 근거와 관찰 한계

최종0.104.28의 [root 실제 엔진 로그](native.log)에서 새지원127 PASS·팔레트562 PASS 및17suite 합계95,423 PASS를 확인했다. [nav.log](nav.log)는 새 world-occlusion 계약과 기존 길안내 기능을 통과했다. [CPU](cpu.log)는634+15,822=16,456 PASS다. [검증 요약](validation.json)은 고정 소스와 빌드15모듈 원문 일치를 기록한다. 이 수치는 기하/상태/정리·표시 계약 검사이지 미술을 자동 승인하는 점수가 아니다.

공통 캡처는 입자 재방출/동결과 일반 모형을 사용한다. 7a 스틸에서 단독Heal이 약했던 원인은 입자 로드·시점·방향·크기를 분리하지 못했다. 최종 재촬영은 아래에서 별도 판정한다. 초기Protect atlas도 약하지만 fullProtect는 구형으로 구별된다. 때문에 작은 accent 하나를 보고 전체 지원이 재생되지 않는다고 단정하지 않는다.

원소별 팔레트·국소 명중·지원형상 개선은 이번 fixture 범위에서 확인했다. 실제 지역맵/이동 손소켓, 위험 예고/목표와의 겹침, 이동·4인+AI·터치/패드·실기기/GPU·최초 로드·최종 사용자 미술 수용은 남는다. [문맥 캡처 스크립트](support-context-capture.luau)는 실제 TD nun과 stockR15+장비를 사용하지만 합성 stage 및 지역 조명 profile만 적용하므로 이 남은 조건을 완료로 대체하지 않는다.

## 실제 자산 문맥 보완: 0.104.26

[문맥 시트6장](support-context/sheet-01.png)을 직접 열람하고 [진단6행](support-context/state.json)을 확인했다. 실제 TD nun과 Traveler 장비를 적용한 stockR15 사이의 Heal/Protect/Cleanse는 Deepwood·HauntedGraveyard 조명 프로필 양쪽에서 서로 구별됐다. Heal은 작은 생명 줄기/잎, Protect는 수신자 내부가 보이는 금빛 외피/링, Cleanse는 몸 바깥으로 퍼지는 흰 수평 스트로크로 읽혔다. 연결선도 시전자 손에서 수신자로 유지됐다.

6행 모두 weaponApplied/armorApplied와4부위 present가 true이고, preload completed=true·콜백 상태 전부 Success이며 link 양 attachment가 스냅샷 내부다. 일부 초기 로드 경고와 최종 preload 결과를 구분한다. 개별 ParticleEmitter의 IsLoaded는 API로 확인되지 않아 해당 입자의 로드 성공을 추정하지 않는다.

이는 실제 자산/장비와 조명의 부분 증거다. 합성 평면 stage·정지 stockR15·플레이어0명이며 실제 지역맵, 이동/다인, 위험/목표 위계와 기기 수용을 대신하지 않는다. 최종0.104.28의 단독 Heal 보강(첫 크기/투명도 조절, 최대크기·12예약·작은Plus 유지)은127 엔진 검사 및 아래 최종 재촬영에서 확인했다.

## 최종 0.104.28 재촬영 판정

고정 소스 `c1b578d470a26536bd1a22895f265b91d3c16669`의 [지원4장 시트](support-final/sheet-01.png)와 [manifest](support-final/manifest.json)를 직접 봤다. 특히 [7a 단독Heal20](common/020-Heal_Pixel_Accent.png)과 [최종 단독Heal20](support-final/020-Heal_Pixel_Accent.png)을 개별PNG로 나란히 비교했다. 이전에는 거의 보이지 않던 수신자 양옆의 작은 민트색 수직 파편이 최종 첫 스틸에서 읽힌다. 큰 Plus나 몸을 덮는 오라 없이 짧은 생명 흐름이 보강됐다. FullHeal28에서도 기존 작은 줄기/잎과 연결선/결과 문구를 덮지 않는다. Cleanse22의 짧은 외향 조각은 유지됐다. 단독Protect21의 초기 atlas는 여전히 약하지만 실제 fullProtect의 명확한 구형 외피와 구분해 해석한다.

최종 [실제 자산 문맥6장 시트](support-context-final/sheet-01.png), [manifest](support-context-final/manifest.json), [진단6행](support-context-final/state.json)도 직접 확인했다. 실제 TD nun·Traveler 무기/4부위 장비 stockR15와 Deepwood/HauntedGraveyard 조명에서 Heal의 작은 상승 생명 단서, Protect의 내부가 보이는 금빛 구형/바닥링, Cleanse의 외향 흰 스트로크 구별이 유지된다. 모든 행의 장비 적용/슬롯 존재가 true이고 preload completed 및 모든 콜백 상태가 Success이며 연결 양끝이 스냅샷 내부다. 개별 입자 로드상태 API 확인이나 실제 전투 재생을 대신하지 않는다.

**ART-COMMON-05/06은 이 단일 수신자·대표 시점 fixture에서 가시성/형상 구별 개선을 확인했다.** ART-COMMON-08은 실제 TD 자산/장비·2조명 문맥 증거로 일부 보완됐다. 실제6지역맵·위험/목표 겹침·이동/다인4인+AI·터치/패드·실기기/GPU·전체 시간/최초 로드·사용자 수용은 남아 전체 게임 미술 최종 승인을 선언하지 않는다. 추가 소스 변경은 없다.
