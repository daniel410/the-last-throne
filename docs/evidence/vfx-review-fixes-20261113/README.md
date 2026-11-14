# VFX 재리뷰 후속 수정·검증

2026-11-13 · TLT-033/054/055/056/057/084 · ENG/ART → QA. [전체 재리뷰](../vfx-rereview-20261113/README.md)의 “수정해줘” 요청을 반영했다.

**예고 결함2건과11기술의 식별성 개선을 구현했다.** 최종 소스 `02760cdd0e2987d31cb760b9310b40ae77b3d6f1`, 단일 빌드 **0.105.6**. 실제 지역·다인·게시 클라이언트·실기기·사용자 최종 미술 수용은 남아 있다. 서버 스킬/몬스터 판정·피해·보상·소유권·TD 운영은 이번 패치에서 변경하지 않았다.

## 수정 내용

| 재리뷰 항목 | 반영 |
| --- | --- |
| VFX-R01 · 돌진 예고 조기 종료 |11개 돌진의 예고를 서버 충돌 검사와 같은0.45초 활성 구간까지 유지한다. 일반 공격의 펄스 수명은 유지한다. 서버 돌진 시간을 줄이지 않았다.|
| VFX-R02 · 공격 범위 OFF 미적용 |패턴 예고도 `TLTAttackRangesEnabled`를 따른다. 공격 중 토글은20Hz 지형 갱신 제한을 기다리지 않고 다음 렌더에서 적용한다. 준비 마법·비행 투사체·확정 명중은 설정과 독립적으로 유지한다.|
| 궁극기3개 |Siege Barrage는 가까이 모인 큰 금속 포탄3개, Grand Volley는 면이 있는 넓은 활 왕관, Spirit Arrowfall은 굵어진 가지와 수관 잎으로 초점을 강화한다. 긴 포격 레이저나 넓은 중앙 채움은 추가하지 않는다.|
| 검기3개 |Whirlwind는 하나의 수평 궤도, Twin Cyclone은 반대로 움직이는 기울어진 두 궤도, Blade Storm은 높이와 간격을 둔3개 짧은 칼날 호를 사용한다. 선/면이 같은 회전축과 시간 곡선을 따른다.|
| 명궁2개 |Weakpoint Shot은 작은 조준 괄호, Heavy Draw는 굵은 깃 모양 압력선을 더해 Aimed Shot과 구별한다. 피해 지점/목표를 새로 선택하지 않는다.|
| 화염3개 |Cinder Ring은 바깥의 상승 화염, Ember Step은 짧은 가로 잔불 흐름, Searing Ward는 안쪽으로 모이는 높은 화염 왕관으로 분리한다. 출발점/범위는 서버 이벤트의 중심을 유지한다.|
| 합성 중복 |`AdvancedSkillVisual`의 spin `BladeCrescent`와 화염 `ElementalWave`가 새 형상을 다시 원형으로 보이게 하던 중복을 제거했다. 실제 `SkillSector` 범위선은 유지한다.|

변경 생산 모듈은 `EnemyPatternEffects`, `HeroVFX`, `AdvancedSkillVisual`이다. 새 외부 자산·업로드·글로벌 조명 변경 없이 기존 팔레트·절차적 형상을 사용한다. [Diablo/WoW 우선 근거·대안/비용·최소 실험](../../research/2026-11-13-vfx-review-followup.md)을 적용했다. 기존 PC/터치 장식 예산과 취소/만료 정리를 유지하며 GPU 성능 향상은 주장하지 않는다.

## 실제 검증

계정/플레이어0명·PlaceId/GameId0의 격리 Studio에서 게임 BaseScript를 비활성화하고 생산 시각 모듈과 서버 공격 런타임을 호출했다. 폴더 기반 설정 fixture를 사용한다. 실제 Player를 만들던 첫 fixture는 `WritePlayer` capability 오류로 중단되어 교체했으며 그 실행을 제품 실패나 통과 수에 합산하지 않았다.

- **수정 전 재현:** 소스 `2b08e66c`에서 [동일 결함 검사](baseline-final.log)의146공격 OFF 전/중 전환292개와11돌진의 늦은 충돌 예고11개가 실패했다. 테스트 전체는1,127검사 중312개 실패이며 미술 차별화 미반영 검사도 포함한다. 이 로그의 테스트는1차 소스 `1395cbaa`의 테스트 버전이며 이후 합성 회귀를 추가한 최종 테스트와 총수를 직접 비교하지 않는다.
- **수정 후 고정 빌드:** [실제0.105.6 실행](pinned-native.log)의18묶음이 모두 통과했다. 신규 회귀는146공격 설정 전환·준비 마법 보존·취소와11돌진에서 서버 `EnemyPatternRuntime.step`의 실제 충돌 호출 및 같은 시간의 예고 존재를 대조한다. 형상·시간 변화·물리 비관여·예산 반환과 생산 `AdvancedSkillVisual.play` 합성의 중복 제거/범위선 보존도 포함한다.
- 기존 회귀는128기술·원소/팔레트·명중·Wind Lance·Curated/PixelFX·지원, 몬스터50종146공격/40투사체·늦은 준비/종료·예산/정리를 포함한다. 검사 합계와 빌드 내17생산 모듈의 커밋 원문 일치는 [validation.json](validation.json)에서 확인한다.
- `verify.py`는 실제 빌드의 SHA256/원문,18묶음의 실패 없음,51개 전후/막펄스 캡처의 해시를 검사한다. 정적 검증/엔진 검사 수를 사용자 미술·기기 PASS로 승격하지 않는다. Lua update P95는 격리 PC 측정이며 GPU 프레임 시간이 아니다.

## 화면 검토

[대표 전후 비교](comparison.png). 개선11기술과 유지 비교용 Aimed Shot1개를 같은 카메라에서0.10초/0.23초로 촬영했다. [첫 시점](after-first/manifest.json), [뒤 시점](after-later/manifest.json), [개선 전 첫](before-first/manifest.json), [개선 전 뒤](before-later/manifest.json). 최종 고정 소스의 격리 장소에서 궁극기3종의 [막펄스](ultimate-last/manifest.json)도 촬영했다. 유효 표본은 총51장이다.

교차 검기의 회전축·명궁 왕관·정령 가지/잎·포탄 몸체·화염 배치 차이를 직접 확인했다. Blade Storm은 짧은 칼날 호로 나뉘지만 바깥의 정확한 범위선은 계속 원형이다. 원거리 Grand Volley와 Siege Barrage의 최종 궁극기 위계는 실제 카메라/전투 중첩에서 추가 수용해야 한다. 광량/면적을 계속 키우는 방식으로 정지 이미지의 존재감만 최대화하지 않는다.

캡처는 단순 모형의 생산 합성을 샘플 시각에 복제하고 입자를 다시 방출/정지한 화면이다. legacy Tween층은 실제 경과 시간을 완전 재현하지 않으므로0.23초 화면을 실제 연속 영상으로 보고하지 않는다. 실제 전체 빌드에 같은 캡처 스크립트를 실행한 최초 막펄스3장은 회색 바닥만 보여 [rejected-build-capture](rejected-build-capture/manifest.json)에 기각 표본으로 보존하고 유효51장에 포함하지 않았다. 렌더 문맥의 원인은 확정하지 않았다. 이후 커밋 원문이 같은 격리 장소에서 다시 촬영했다. 2시점과 막펄스는 전체 준비→회수 동영상/최초 로드/실제 영웅 장비·지역·터치 수용을 대신하지 않는다. [캡처 출처](captures.json), [최종 후보 입력](candidate-provenance.json), [고정 입력](pinned-provenance.json)을 함께 본다.

## 빌드·보정 이력과 재현

0.105.5/`1395cbaa`는 기능 회귀를 통과했으나 합성 화면에서 이전 원형 장식이 새 실루엣을 덮는 문제가 남아 있었다. [초기 빌드](initial-build.json)와 [초기 고정 검사](initial-pinned-native.log)를 보존하고 덮어쓰지 않았다. 마지막 보정은 `AdvancedSkillVisual`의 중복 장식 제거이며0.105.6에서 검증했다. 초기 왕관/칼날 표본은 [initial-art](initial-art/manifest.json)에 보존한다. 이전 단계의 PASS를 최종 미술 승인으로 해석하지 않는다.

```sh
python3 tools/prepare-vfx-review-followup.py --source 02760cdd --output /tmp/tlt-vfx-review-qa
run-in-roblox --place builds/0.105.6/TheLastThrone-0.105.6.rbxlx --script /tmp/tlt-vfx-review-qa/probe.luau
python3 docs/evidence/vfx-review-fixes-20261113/verify.py
```

새 RGB 캡처는 `capture-first.luau`/`capture-later.luau`/`capture-last.luau`를 위 준비 도구의 고정 소스 `qa.rbxlx`에 실행한 로그를 `tools/decode-skill-vfx-captures.py --allow-partial`로 복원한다(Pillow 필요). 엔진 회귀는 실제 전체 빌드, 유효 시각 캡처는 계정 없는 격리 장소라는 차이를 유지한다. 후보는 `--source 2b08e66c --candidate`로 VFX3모듈과 해당 테스트만 덮는 재현 도구를 사용했다. 다른 작업의 미커밋 난이도/보상/지도/자산 변경은 검증 fixture나 스테이징에 섞지 않았다. 이미 커밋된 별도 작업은 빌드 기준 커밋의 일부다.

최종 산출물은 [build.json](build.json)의 `builds/0.105.6/TheLastThrone-0.105.6.rbxlx` 하나다. 소스 커밋을 먼저 origin/main에 푸시·원격 일치 확인한 뒤 빌드했다. 이미지들은 `.gitattributes`의 LFS 규칙으로 저장한다. Roblox 게시·릴리스 태그 없음. 작업 종료 시 연결 목록에는 처음의 사용자 Studio0.104.25/0.105.1 Edit창만 남았으며 QA 임시 세션은 종료됐다. 기존 창은 편집/Play 전환/종료하지 않았다.

## 남은 수용·다음 담당

ENG 수정과 격리 엔진 회귀는 완료다. QA/ART는 실제 영웅·승인 장비·현재 다섯 지역/밝고 어두운 조명,4인+AI에서 위험/목표 가림·전체 펄스와 회수, 저FPS/지연·자산 최초 로드, PC/터치/패드·실기기 GPU를 확인한다. 실제 게시 클라이언트·실기기·사용자 미술 수용은 **Not Run/Pending**이다. 리뷰의 환경/카메라24효과군은 이번에 새로 실플레이 촬영한 것으로 처리하지 않는다. 상위 TLT 티켓의 전체 수용 게이트는 닫지 않는다.
