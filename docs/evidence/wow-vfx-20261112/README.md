# TLT-033/057 · WoW 비교 기반 계열 VFX 개선

2026-11-12 · 0.104.20 · ENG 구현/격리 QA 완료. TLT-033/057 전체 티켓과 사용자 미술 수용은 미완료다.

## 변경과 근거

[WoW 공식 자료 조사·현재 효과 비교](../../research/2026-11-12-wow-vfx.md)를 근거로 `HeroVFX`만 변경했다. 성기사 Dawn Burst/Dawn Spiral/Oath of Dawn은 채운 원반과3~4개 고리 대신 고리1개·분리된 인장6개·상승 광선6개를 사용한다. Arcane Ward는 전사와 공유하던 전방 방패 대신 주변6방향 결정 면과 궤도2개를 사용한다. 기존 전사의 Guard, 서버 피해/범위/타이밍/보호막, 기본 범위선과3초 PersonalWard는 유지한다. 새 이미지/자산 업로드·외부 자산 도입은 없다. TD 운영 Place/코드·데이터·재화는 변경하지 않았다.

## 전후 비교

![동일 조건 전후](comparison.png)

왼쪽은0.104.19 런타임과 동일한 변경 전 소스, 오른쪽은 개선 소스다. 위 Dawn Burst, 아래 Arcane Ward. `tools/capture-wow-vfx-review.luau`로 실제 `AdvancedSkillVisual.play`→HeroVFX/PixelFX를 호출했다. 범위선/기존 보호막 등 합성된 전체 클라이언트 표현을 포함한다. PlaceId/GameId0·플레이어0의 격리 Place, 회색 모형·동일 바닥·고정48도 카메라, 호출 후0.14초에 생성한 인스턴스를 복제·동결한320×240 정지 화면이다. 캡처 확인 후 영상 데이터는 삭제하고 정지 PNG·[메타데이터/로그 해시](captures.json)만 보존했다. 실제 입력 지연·동작 타이밍·지속효과 끝까지의 화면 수용은 증명하지 않는다.

관찰: 성기사 중앙의 넓은 금색 면이 사라져 지면이 드러나고 방사형 표식이 구별된다. 비전 방어는 전방 판에서 주변의 분리된 결정 형태로 바뀐다. 시인성의 최종 우열과 캐릭터 미술 적합성은 사용자 수용 전이다.

## 검증 조건과 결과

- [정적/CPU 검사](source-checks.log): Luau 컴파일, PixelFX634 + SkillEffects15,938 = **16,572 PASS**. 엔진 렌더링/실기기 검사가 아니다.
- [실제 엔진](native.log): `run-in-roblox`와 `tools/prepare-hero-vfx-native.py --output /tmp/tlt-wow-after`의 별도 Place 사용. 계정/저장/경제/서버 gameplay 모듈 없이 Client/Shared 소스만 포함한다. [입력 SHA256](inputs.json).
- 새 `wow-vfx-native`231, 기존 style-fit58, curated182, PixelFX1690, HeroVFX6440, WindLance128, individual297, flourish57, K0Hit102 = **9,185 PASS**. 128기술·기본 공격·고유한4기술 형상·카메라 독립·만료/혼합 부하·전역 예산·기존 냉기/폭탄/치유·전사 방패 보존을 확인했다. HeroVFX 검사 수 감소는 겹친 고리/Attachment 감소 때문이다.
- 여러 suite는 각각 `local function test() ... end; test()` 범위로 감싸 실행해 중간 `return`이 다음 검사를 생략하지 않게 했다. 원시 로그의 각9개 요약 모두 `pass=true`/`PASS`다.
- 표면160/터치80, Beam240/터치144 등의 전역 예산을 그대로 사용한다. 새 표면은 최대24개, 장식 고리 Beam은24개 이하. 단일 PC 엔진 검사에서 확인한 수이며 모바일/GPU 성능 합격을 뜻하지 않는다.

## 빌드·남은 검증·인계

0.104.20 소스 `bc466b46e1b8f68abeb71b042d76cbb062d807e7` 고정 단일 빌드를 완료했다. [빌드 기록](build.json), [XML 소스/파일 SHA256 대조](build-checks.log). 4개 관련 생산 모듈이 고정 커밋과 일치한다. Roblox 게시·릴리스 태그 생성은 하지 않았다.

미검증: 게시 RPG 클라이언트, 실제 TD 영웅/장비를 사용한 미술 수용, 밝고 어두운 지역/카메라 전 범위, 4인+AI 동시 효과, 모바일·GPU 프레임 시간, 사용자 최종 수용. 기존 무료 폭탄 이미지의 Experience 사용권 최종 확인은 [이전 증거](../curated-vfx-20261112/README.md)에 남아 있으며 이번 절차로 해결됐다고 주장하지 않는다.

다음 담당 ART/QA: 실제 영웅에서 기술 식별·바닥 위험/목표 가림·보호막 지속 판독을 비교하고, 같은 기기에서 성능을 측정한다. ENG는 원반 제거/결정 배치를 쉽게 되돌릴 수 있도록 변경을 단일 렌더러에 한정했다.
