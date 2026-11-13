# 선별 무료 VFX 게임 적용

2026-11-12 · TLT-033/057 · ENG/ART → QA. 사용자 ‘게임에 적용해줘’에 따른 구현. [선정 근거](../../research/2026-11-12-free-roblox-vfx-review.md), [원천·권리·해시·업로드ID](../../../assets/effects/curated-vfx-v1/source-manifest.json).

## 변경

- Selene의 실제 Heal 확인 이벤트에 Yuruzuu 치유4 emitter/16입자를 연결하고 대상의 기존 일반 반짝임32개와 치유 PixelFX를 대체했다. MINT·HP 표시·지원 연결선·시전자 손 연출·Protect/Cleanse는 유지한다.
- `elf.magic_archer.spirit_rain`의 기존 확정4펄스마다 원본 Arrow Rain의3디자인을5접촉 지점에 축소 배치한다. 자연색·낙하 높이4stud·15입자를 사용한다. 원본의 거대한 구체/바닥 오라·예제 스크립트는 가져오지 않는다.
- `mage.cryo.frost_ring`과 `dwarf.gunner.bomb_toss`의 기존 PixelFX 부가 층을 각각 Frost Nova/ Rolling Fireball Explosion의64셀 PNG로 대체한다. 크기4.5/3.2stud·0.6/0.85초이며 기존3D 방향·범위·타격/위험 표현은 보존한다.
- 네 효과는 기존 PixelFX 전역24개·80stud 거리·사망/행동 취소/수명/스트림 아웃 정리 경로를 공유한다. 추가 입자/스프라이트 예약은 PC192/터치96개다. 상한/로드 실패 시 기존 PixelFX 또는3D 정보가 남는다. 새 프레임 루프·서버 판정·피해/회복·MP·쿨다운·소유/저장·TD 변경은 없다.

`CuratedVFX`는 외부 스크립트를 실행하지 않는다. 서버 확정 행동을 기존 `PixelFX.skill`/`support` 경로에서 받아 재생한다. 같은 확정 펄스의 중복·오래된 이벤트 억제는 기존 경로를 따른다. 선택한 PNG는 LFS, emitter 원천은 JSON으로 보존한다.

## 구현 중 확인한 렌더 제약

두 새 이미지의 기본 프리로드가 Success여도 ParticleEmitter Grid8x8 재생에서는 다음 오류가 나와 원본 그림이 표시되지 않았다.

```text
No asset content representation found while do_not_fallback_to_baseline is set to true.
```

이를 이미지 권한 승인 성공으로 해석하지 않았다. 기존 PixelFX와 같은 BillboardGui atlas 방식으로 바꾸되 ImageLabel은 Default 보간·128px 셀/8×8을 사용한다. AlwaysOnTop=false와 실제 지면 기준 높이를 유지해 바닥 아래로 이미지가 잘리는 문제를 줄였다. 그림 속 고정 원근은 실제 판정 범위를 표현하지 않는다. 최초 디코드 지연을 줄이기 위해 실제 ImageLabel/ParticleEmitter 인스턴스를 비동기 사전 로드한다.

## 검증과 범위

| 조건 | 결과 | 증거/한계 |
| --- | --- | --- |
| 수정 모듈/전용 fixture 컴파일 | PASS | [정적·CPU 로그](source-checks.log) |
| 기존 PixelFX CPU |634 PASS |128기술·4기본·185펄스. 새 emitter는 별도 실제 엔진 검사 |
| 기존 Skill effects CPU |15,938 PASS |기존116추가 기술·취소·기하·예산 |
| 선별 효과 실제 엔진 |148 PASS |[native.log](native.log), 치유4 emitter·화살비15·64셀 재생·중복·취소·사망·수신자 스트림 아웃·거리·예약 해제 |
| 전체 PixelFX 실제 엔진 |1,690 PASS |[native.log](native.log), 기존20프로필/128기술·4기본·지원/피격·수명 |
| 기존 Hero/Wind/개별/면/명중 엔진 회귀 |7,140 PASS |[regression-native.log](regression-native.log). 이후 변경은 선별 효과의 사전 로드·스프라이트 표시 위치이며 최종 선별/PixelFX 검사를 다시 실행함 |
| Studio 화면/이미지 로드 |격리 장면 확인 |[비교판](studio-review.png), [캡처·6텍스처 프리로드·2스프라이트 IsLoaded](captures.json). 회색 모형/격리 장면이며 실제 게임·모션 수용 아님 |

캡처는 생산 렌더러의 생성물을 복제·고정하고 필요한 입자를 다시 방출한 스틸이다. 이미지 디코드를 기다려 캡처할 수 있으며 최초 사용 지연·동영상 타이밍·GPU 성능 증거로 삼지 않는다. `IsLoaded=false` 또는 프리로드 Failure가 기록된 샘플을 로드 성공으로 보고하지 않는다. 검증 입력은 [해시 목록](inputs.json)으로 특정한다. 초기 Run 전 프리로드에서 Failure가 발생했고, Run 후 실제 인스턴스를 프리로드하는 경로로 재확인했다.

재현: `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-curated-vfx-native`로 저장/계정 없는 PlaceId/GameId0 fixture를 만들고 `tests/curated-vfx-native.luau`, `tests/pixelfx-native.luau`를 실행한다. 스틸은 `tools/capture-curated-vfx-review.luau`의 `_G.CuratedCaptureGroup=1/2`로 나눈다. 이 환경의 다른 네이티브 작업과 충돌하지 않도록 기존50314/50316 포트 runner를 사용했다. 사용자 TD Place는 편집하지 않았다.

## 권한 대기·미검증·다음 담당

이미지 업로드는 `72083342328059`/`125374985892345`를 반환했다. 공개 메타데이터의 생성자ID는9156786071이다. 비인증 Asset Delivery는403이며, 이것만으로 RPG의 이용 권한 보유 여부를 확정하지 않는다. RPG Universe `10773575153`에 두 이미지의 Use 권한을 명시하려는 최소 Open Cloud 범위 검사에서 **`asset-permissions:write` 미부여** 응답을 받았다. 사용자에게 해당 토글만 요청했으며, [조회한 지침·정확한 오류](rbx-permissions/SKILL.md)를 보존한다. 다른 API/컨텍스트로 권한 변경을 우회하지 않았다.

사용자가 권한을 켜면 동일 범위를 재검사하고 두 이미지에 RPG Universe Use만 추가한다. 새 계정/전체 공개/TD 권한/라이브 Place 게시를 변경하지 않는다. 제3자 Yuruzuu 텍스처의 RPG 게시 클라이언트 이용 가능 여부도 별도 검증한다.

게시 테스트 클라이언트·모바일/실기기·4인+AI 동시 사용·GPU/메모리·카메라 회전/밝고 어두운 지역의 가림·사용자 미술 수용은 미검증이다. TLT-033/057을 Done으로 바꾸지 않는다. 다음 담당은 권한 응답 후 ENG의 두 이미지 Use 설정/재확인, 이후 QA의 실제 RPG 클라이언트 비교다.

## 빌드

0.104.16을 예약한다. 고정 소스 빌드의 최종 경로/해시는 `build.json`에 기록한다. Roblox 게시·릴리스 태그는 만들지 않는다.
