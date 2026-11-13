# TLT-033/057 · 인기 Roblox RPG 참고 VFX 개선

2026-11-13 · 0.104.24 · DES/ENG 로컬 구현·격리 Studio 검사·고정 빌드 완료. G1/G4 전체 수용·티켓 Done·게시·실기기 수용과 구별한다.

## 변경과 근거

[Roblox RPG/Diablo IV/WoW 조사](../../research/2026-11-13-roblox-rpg-vfx.md)를 적용했다. Blox Fruits 공개 이미지의 넓고 가늘어지는 곡선 띠, World // Zero 공식 이미지의 직업별 형상/색 대비를 우리 게임의 절차적 효과로 변형했다. Deepwoken은 국소 무기 불꽃의 보완 비교만 사용했다. 자료의 시점·인기 선정 근거·관찰과 해석·재열람 제한은 조사에 구분했다. 원본 자산은 복사하지 않았다.

- 검기/내려치기: 고정된 면을 휘두르는 축을 따라 회전시키고 검기의 폭을 보강했다. 진행 시간의 절대 샘플을 사용해 프레임 이력에 따라 방향이 달라지지 않는다.
- 화염: 투사체 끝에 가늘어지는 두 곡면 꼬리를 추가했다. 기존 불꽃·불티·화염 혀를 보존한다.
- 물/중력·대지·화염 광역: 중앙이 막힌 장식 원반을 열린 곡선 띠로 바꾸고 팽창/회전을 적용했다. 지면·영웅이 보이는 빈 영역을 확보한다.
- 폭발: Bomb Toss의 기존 파편 표현은 유지하고 다른 폭발의 오래 남는 큰 구체를 짧은 중심광·열린 팽창 충격파로 바꿨다.
- 명중: 중심광0.08초 → 압력파0.23초 안에 소멸하는 시간 구성을 적용했다. 물/중력/얼음/대지는 기존 원소별 물결/파편을 사용한다. 성속성의 금빛과 상승광·전용 바람·번개의 짧은 분기를 보존했다.

생산 변경은 `HeroVFX`, `HeroVFXSurfaces` 두 표시 모듈이다. `AdvancedSkillVisual`의 확정 스킬 이벤트와 `K0HitEffects`의 명중 경로를 그대로 사용한다. 서버 피해/범위/상태/자원/쿨다운/해금·TD 운영 코드·저장·재화를 변경하지 않는다. 새 자산 업로드나 외부 스크립트 의존성은 없다. [미술 정본](../../production/element-vfx.md).

## 실제 엔진 캡처

![개선 후11장면](after.png)

[11장면 전후 비교](comparison.png): 각 쌍의 왼쪽은0.104.23, 오른쪽은0.104.24다. Fire/Water/Wind/Lightning/Ice/Earth/Holy Gold/Holy Seal/Blade Sweep/Shell Burst/Holy Impact 순서다. 비교에서 바람/번개/얼음은 보존 회귀 장면이다.

`tools/capture-rpg-vfx-review.luau`가 생산 `AdvancedSkillVisual.play`를 호출한다. 기본 Crescent Cut과 명중은 각각 생산 `HeroVFX.skill`/`HeroVFX.contact`를 직접 호출한다. 동일 회색 모형·바닥·조명·48도 카메라를 사용했다. 번개/명중0.1초, 다른 장면0.14초의 생성 인스턴스를 복제·동결해320×240으로 캡처했다. 입자는 복제 후 재방출/동결했으므로 첫 로드 지연이나 실제 타이밍을 입증하는 영상이 아니다. [샘플/PNG 해시](samples.json), [로그 해시](capture-inputs.json), [캡처 스크립트 해시](validation.json).

관찰: 화염은 가는 선에서 면을 가진 꼬리로 바뀌고, 물·대지·폭발 중앙의 지면이 드러난다. 검기는 각도/두께가 달라지고 명중은 작은 구 대신 열린 금빛 압력파로 읽힌다. 회색 모형과 격리 조명의 디자인 관찰이며 실제 영웅/장비·지역/기기·사용자의 최종 미술 수용을 대신하지 않는다.

## 검증 조건과 결과

- [CPU](cpu.log): `lua tests/pixelfx.spec.lua`, `lua tests/skill-effects.spec.lua` **16,572 PASS**. [Luau 컴파일](compile.log) PASS. CPU 검사는 렌더링 검증이 아니다.
- 재현: `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-rpg-vfx-final` 다음 출력된 `run-in-roblox` 명령. Client/Shared만 포함하고 PlaceId/GameId0, 실제 플레이어0·저장/서버 gameplay 없는 격리 Place다. 이제 도구가 관련11 suite와 함수별 스코프를 직접 준비한다.
- [실제 Studio 엔진](native.log): **10,476 PASS / 11 suite**. 새 움직임190·원소84·WoW231·style58·curated182·PixelFX1690·Hero7457·Wind128·individual297·flourish57·Hit102. [기계 판독 결과](validation.json), [최종 입력 SHA256](inputs.json), [변경 전 입력](before-inputs.json).
- 검기/화염/물/대지 면의 실제 위치 변화, 시간 재샘플의 프레임 이력 독립성, 명중광 선소멸·압력파 후소멸·만료, 모든128기술·4기본 공격, 중복/오래된 시전 취소, 거리 컬링·혼합 포화 후 정리·물리/쿼리 권한 없음을 확인했다.
- 기존 동시 효과12/터치8·면160/터치80·Beam240/터치144·입자192/터치96 예산을 유지한다. 면/CFrame 갱신량이 늘었으므로 성능 향상을 주장하지 않는다. PC의 Lua update 측정은 GPU/기기 수용이 아니다.

## 빌드·인계

고정 소스 `ed1c5c5fe2b5caa6c096d7683e6854a31b8d45b4`를 원격 main에 반영한 뒤 단일 빌드0.104.24를 생성했다. [빌드 명령/산출물/SHA256](build.json), [빌드 XML과 두 생산 모듈의 고정 소스 일치](build-checks.log). Roblox 게시·릴리스 태그는 만들지 않았다.

미검증: 게시 클라이언트·실제 TD 영웅/무기/장비·밝고 어두운 전투 지역·4인+AI·터치/패드·GPU/실기기 프레임 시간·첫 로드·최종 사용자 미술 수용. 기존 Bomb Toss 이미지의 Experience 권한 제약도 이번 작업에서 해결한 것으로 보고하지 않는다.

다음 담당 ART/QA: 고정 빌드에서 원소/공격 방향 식별, 실제 위험 바닥·목표 가림, 동시 교전 성능을 같은 기기로 비교한다. 이 수용 증거가 충족될 때 전체 TLT-033/057의 상태를 갱신한다.
