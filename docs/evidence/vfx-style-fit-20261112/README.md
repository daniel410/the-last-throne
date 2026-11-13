# 전투 VFX 미술 적합성 개선

2026-11-12 · TLT-033/057 · ENG/DES → QA. 사용자 ‘개선해줘’에 따른 [다른 게임 VFX 조사](../../research/2026-11-12-combat-vfx-game-references.md)의 우선3개 적용.

## 변경

- **Frost Ring:** 원근이 그려진 카메라 지향 Frost Nova 이미지와 넓은 청록 단색 면을 제거했다. 지면의8개 Ice 재질 쐐기 면·8개 작은 상승 파편으로 교체했다. 기존 FrostBloom 경계·별도 범위 기하·타격/슬로/반경은 유지한다. 중심과 바닥이 보이며 카메라를 돌려도 얼음 면의 월드 좌표가 바뀌지 않는다. 퇴역 PNG/업로드 출처는 원천 자산 기록으로 남기되 런타임/프리로드 참조는 제거한다.
- **Bomb Toss:** 해당 기술의3.2stud 구형 외피와1.5stud 흰 코어를 제거했다.0.6stud 접촉광이0.09초 안에 사라지고5개 어두운 케이스 파편이 바깥으로 이동한다. 기존 화염 입자·폭발 PNG·경계와 타격 시점은 유지한다. 다른 폭발/포격의 전용 면을 일괄 변경하지 않았다.
- **Selene Heal:** 십자 입자5→2개, 최대 크기0.65→0.2stud로 줄이고 MINT 발광·세로 파편 크기를 낮췄다. 전체12입자로 기존16개보다 적다. +HP·지원 연결선·시전자 손·실제 지원 확정·대상 추적·Protect/Cleanse는 유지한다.
- **Spirit Rain:** 기존 마법궁수 전용 낙하/4펄스를 유지한다.

변경 범위는 클라이언트 `CuratedVFX`, `PixelFX`, `HeroVFX`, `HeroVFXSurfaces`와 전용 검사·자산 설명이다. 서버 피해/회복·범위·MP·쿨다운·성장·소유/저장·TD 운영 변경은 없다. 기존 동시 효과/입자/면 상한과 거리·취소·수명·사망·스트림 아웃 정리를 사용한다. 파편 이동/접촉광 개별 페이드는 기존 면 갱신 안에서 처리하며 새 프레임 연결은 만들지 않는다.

## 근거와 화면

Diablo IV의 타격 방향·정보 강도 위계, Minecraft Dungeons/Vesteria의 단순한 형상, Last Epoch의 국소 발광·생성/오버드로 비용을 [조사 기록](../../research/2026-11-12-combat-vfx-game-references.md)에 연결했다. 조사 게임의 자산·고유 형상·밸런스를 복제하지 않는다. 이번 수정은 무료 팩을 쌓는 대신 우리 기술의 주 실루엣과 중복 면을 정리한다.

[전후 비교판](comparison.png), [캡처·입력/출력 해시](captures.json), [검증 소스 해시](inputs.json).

이전은0.104.16 격리 캡처다. 작업 시작 시 CuratedVFX/PixelFX/HeroVFX/HeroVFXSurfaces/AdvancedSkillVisual5개 파일이 이전 고정 커밋 `add51d7b`와 동일함을 확인했으므로0.104.18 작업 기준과 VFX 내용이 같다. 이후는 같은 캡처 도구·카메라·회색 모형에서 생산 렌더러를 실행한 스틸이다. 생성물을 복제·고정하고 입자를 다시 방출해 잠깐 진행시킨 뒤 TimeScale0으로 정지했다. 실제 TD 영웅·무기·적·연속 동작·사용자 미술 수용을 증명하는 화면이 아니다.

## 검증

| 조건 | 결과 | 증거/한계 |
| --- | --- | --- |
| 수정 모듈/전용 fixture 컴파일 | PASS |[source-checks.log](source-checks.log) |
| PixelFX/Skill effects CPU |634 +15,938 PASS |실제 엔진/기기 성능과 구분 |
| 새 미술 구조 엔진 |58 PASS |얼음 면8개·중앙 면/이미지 없음·카메라3위치에서 월드 변환 불변·폭발 외피 없음·100ms 섬광 제거/5파편 이동·다른 포격 유지·십자 크기/수/예산 |
| 선별 효과/PixelFX 엔진 |182 +1,690 PASS |확정 이벤트·중복·수명·취소·거리·수신자 스트림 아웃·예약 해제 |
| Hero/Wind/개별/면/명중 엔진 |6,567 +128 +297 +57 +102 PASS |128기술과 기존 연결/형태·예산·정리 회귀 |

실제 인스턴스 검사 합계는 **9,081 PASS**다. [native.log](native.log). 면 갱신 비용 표본은 합성 fixture의 Lua 비용이며 실제 게임/GPU/프레임 시간 수용으로 해석하지 않는다. 신규 이미지 업로드 없이 기존 파편 텍스처와 폭발 이미지로 검사했다.

재현은 `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-vfx-style-fit` 후 실제 로컬 Place에서 `tests/vfx-style-fit-native.luau`, `tests/curated-vfx-native.luau`, `tests/pixelfx-native.luau`와 기존 Hero VFX5종을 실행한다. return이 있는 suite는 개별 함수로 감싸 실행한다. 화면은 기존 `tools/capture-curated-vfx-review.luau`의 그룹1/2를 사용한다. 계정/저장 없는 PlaceId/GameId0 fixture이며 사용자 TD Place는 변경하지 않는다.

## 미검증과 다음 담당

게시 클라이언트·실제 영웅/적과의 연속 동영상·밝고 어두운 지역·4인+AI·모바일/실기기·GPU/메모리·사용자 미술 수용은 미검증이다. 실제 렌더된 모든 카메라 각도의 비교 영상은 없으며 카메라 이동에 대한 엔진 검사는 좌표 불변만 확인했다. 폭발 이미지의 RPG Use 권한 확인은 [기존 대기](../curated-vfx-20261112/README.md)와 별개로 해결됐다고 주장하지 않는다. TLT-033/057의 Done 상태를 변경하지 않는다.

다음 담당 QA/DES는 실제 TD 영웅·무기·몬스터를 사용해 같은 기술의 연속 영상/다인 가림을 비교하고 최종 미술을 수용한다. 구현 수정과 미술 최종 승인을 구분한다.

## 빌드

0.104.19로 고정 소스 빌드를 준비하고 최종 경로·SHA256은 `build.json`에 기록한다. Roblox 게시·릴리스 태그는 만들지 않는다.
