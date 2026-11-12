# 면 중심 전투 VFX 강화

TLT-033/057 · 2026-11-11 · 사용자 요청: 더 화려하게, 면이 보이는 시각 효과 중심. [전후 비교판](comparison.png) · [리서치/MCP 확인](../../research/2026-11-11-filled-combat-vfx.md).

## 반영

- 검기는 채워진 초승달·수직 베기·교차 면·찌르기 쐐기, 방패는 반투명 방어 면으로 보강했다. 선은 밝은 가장자리/방향 보조로 유지한다.
- 물/서리/중력/성광은 반투명 바닥 면, 불은 장판과 솟는 체적, 폭탄/포격은 팽창하는 폭발 코어, 바위는 입체 쐐기, 마법탄은 원소 체적을 추가했다. 화살/도끼/번개에는 짧고 채워진 쐐기 잔상을 넣었다.
- Wind Lance에도 반투명 바람 면을 넣었다. 기존71개 리본·발사/명중 시점은 유지한다. 귀환 도끼는 채워진 잔상까지 귀환 방향을 따른다.
- 부드러운 외곽광·짧은 섬광·일회성 입자를 추가했다. 발사구 또는 전방/지면에서 방출해 몸 내부에 가려지는 것을 줄였다. 카메라 전체 Bloom이나 화면 흔들림은 추가하지 않았다.
- 모든 면/체적은 클라이언트의 비충돌·비접촉·비쿼리 형상이며 그림자를 만들지 않는다. 피해·범위·MP·쿨다운·소유·저장·TD 운영을 변경하지 않았다.

기존 글로벌 코어240/터치144 Beam과 파편48개는 유지한다. 추가 면 PC160/터치80개(Hero/Wind 공유), 외곽광 PC96/터치48개, 예약 입자 PC192/터치96개를 따로 제한한다. 추가 장식은 상한에서 생략되며 기존 판정/범위 표현은 유지한다. 기술당 장식 면이 많아지는 비용을 인정하며 전체 게임 성능 수용과 구분한다.

## 화면 검토

대표12개 기술을 같은 기본 카메라/구도로 비교했다. [목록·PNG 해시](captures.json). 각 폴더에 원본320×240 PNG가 있다. 이전은0.104.1 개별 검토의 최종 이미지, 이후는 이번 생산 렌더러의 실제 네이티브 캡처다. 삼각형 면 이음새의 각진 외곽광은 수정 후 다시 확인했다.

| 종류 | 대표 이후 |
| --- | --- |
| 검기 면 | [Crescent Cut](after/knight_crescent_cut.png), [Sunward Cross](after/knight.paladin.sunward_cross.png) |
| 도끼·폭발 | [Overhead Smash](after/dwarf.common.overhead.png), [Bomb Toss](after/dwarf.gunner.bomb_toss.png) |
| 화살·뿌리 | [Grand Volley](after/elf.marksman.grand_volley.png), [Vine Burst](after/elf.magic_archer.vine_burst.png) |
| 원소 면·체적 | [Cinder Ring](after/mage.pyro.cinder_ring.png), [Frost Lance](after/mage.cryo.frost_lance.png), [Tidal Ring](after/mage_tidal_ring.png) |
| 비전·번개·바람 | [Arcane Ward](after/mage_arcane_ward.png), [Chain Lightning](after/mage.cryo.chain_lightning.png), [Wind Lance](after/mage_wind_lance.png) |

캡처는 합성 회색 캐릭터 옆의 고정 효과 장면이며 실제 영웅 무기/모션 전체가 아니다. 생산 효과를 복제해 고정하고 입자는 다시 방출해 일반 엔진 시간으로 진행시켰다. `FastForward`는 현재 권한에서 지원되지 않아 사용하지 않는다. 스틸 이미지가 입자의 실제 클라이언트 동영상 품질을 증명하지는 않는다.

## 검증

[엔진 로그](native.log):128기술/기존 연결·정리6,556검사, Wind128검사, 개별 의미297검사, 면·장식/상한57검사, 명중102검사로 **7,140검사 통과**. [입력 해시](inputs.json)로 소스를 특정한다. 검기 면의 실제 투영 면적이4stud²보다 크고 비충돌임을 확인했으며, 모든 면·입자·외곽광 예약이 정리되는지 확인했다.

혼잡 fixture Lua 갱신60회에서 P50 약0.42ms/P95 약0.43ms였다. 이는 합성 시계·별도 Studio의 스크립트 갱신 비용이며 렌더링/GPU/실제 게임 프레임 시간으로 해석하지 않는다. MCP LibMP 스냅샷은 유효 프레임0개였으므로 GPU 검증은 미실행이다. [정적/CPU 회귀](source-checks.log)는 별도 기록한다.

재현은 `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-vfx-check` 후 출력 명령을 실행한다. 캡처는 기존 `--review-mode frames`와 `tools/capture-skill-vfx-review.luau`를 사용한다. 별도 PlaceId0 fixture에서만 Run을 시작하며 실제 계정/저장 서비스를 실행하지 않는다. 테스트 도구가 만든 QA Studio 세션은 종료했다.

## 빌드·남은 수용

게임 빌드는 마감 시 커밋 입력으로 생성하고 `build.json`에 기록한다. Roblox 게시·릴리스 태그는 이번 범위에 포함하지 않는다.

실제 영웅 모션 접점, 전 기술의 새 동영상 전수,1~4인+AI 중첩/적 예고 가림, 저/고 그래픽 품질, 터치 실기기·GPU/P95·게시 클라이언트 수용은 미검증이다. 다음 담당 QA/사용자는 실제 플레이로 확인한다. 다른 작업의 미커밋 변경과 기존 자산 수정/삭제는 보존했다.
