# 로스트아크 비교 후 전투 VFX 격차 개선

TLT-033/057/059 · 2026-11-16 · ART/ENG · 로컬 구현/엔진/화면 검증. 상용 RPG와 동급이라는 인증이나 전체 G4 완료가 아니다.

사용자는 이전에 확인한 품질 격차를 개선하고 로스트아크의 VFX와 비교·리뷰해 수정하도록 요청했다. [로스트아크의 검격/마법 공식 시연과 적용 판단](../../research/2026-11-16-rpg-vfx-gap.md), [앞선 비교에서 찾은 격차](../../research/2026-11-15-rpg-vfx-quality-comparison.md)를 입력으로 사용했다. 독립 ART가 중간 시안에서 밤의 검날 소실·작은 흰 촛불 같은 분출·가려지는 연속 검흔을 지적했고 ENG가 재수정했다.

## 변경과 관측

| 격차 | 실제 변경 |
| --- | --- |
| 균일한 검격 판/밤의 날 소실 | 좁고 연속된 주날은 유지하고 gradient 질감은 기존 soft glow에만 적용한다. 넓은 회전 검기 면은 옅게 남긴다. Tidal의 물마루도 넓은 면보다 유색 흐름이 먼저 읽히도록 조정했다. |
| 궁극기의 작은/판형 초점 | Caldera는 큰 주황 면을 보이지 않게 하고 암석 분출구·지면에서 이어지는 맥·승인 fire atlas4개를 조합한다. atlas의 프레임 간격128px 안에서 중심96px를 표시해 빈 여백을 줄였다. Tempest는 높이/반경을 가진3개 연속 기류와 옅은 증기 층, Spirit은 잎/맥 있는 수관과 가는 하강 축·아래 방향 촉으로 재구성했다. |
| 어두운 물/얼음 본체 | Water의 내부/표면 발광을 조절하고 Frost Lance 계열의 한 면/좁은 축을 유색 발광으로 구분했다. 적 냉기는 Glass 본체를 유지하며 좁은 발광맥을 추가했다. 큰 백색 블룸을 추가하지 않았다. |
| 성기사 세 검격의 유사성 | Radiant의 넓은 단일 전방 검호, Guardian의 두 보호표식/날개, Oathbound의 확정 펄스별1짧은 전진 검흔으로 나눈다. Oathbound의 Hero 접촉광은0.55 크기, Pixel 장식은0.75 크기/0.14초로 줄여 검흔을 가리지 않게 했다. |
| Froststorm 띠/Spirit 낙하 판 | Froststorm은3층 연속 흐름이 주 표현이 되게 하고 기존 판을 옅게 남긴다. Spirit 낙하 축은 폭0.75→0.13으로 줄이고6개 하향 촉을 추가했다. |

클라이언트6모듈(`HeroVFX`, `HeroVFXArt`, `HeroVFXSurfaces`, 새 `HeroVFXPolish`, `EnemySpellVFX`, `PixelFX`)을 변경했다. 피해·범위·서버 펄스·보호/서약·소유권·성장·저장·TD Experience는 바꾸지 않았다. 기존 정확한 범위선도 유지한다. 원본 아이콘·무기·Holy 금빛/Lightning 청색을 보존했다.

재료는 기존 [Yuruzuu gradient/ParticleFX fire atlas](../../../assets/effects/curated-vfx-v1/README.md)와 엔진 텍스처다. 신규 외부 모델·스크립트·플러그인·PNG/메시 다운로드/설치/업로드는 없다. 원작 로스트아크의 자산을 복제하지 않았다. 공유 레코드·Beam·Part·입자 상한과 기존 수명/회수 경로를 사용한다. Caldera의 최대4plume과 Tempest의3증기층은 추가 Billboard/투명 픽셀 비용이 있으므로 인스턴스 상한 유지가 GPU 합격을 뜻하지 않는다.

## 화면과 독립 ART

[최종 ART](art-review.md)·[구조화 판정](art-review.json). 불꽃/하강 방향·야간 본체·성기사 구별의 개선과 검격/물결 재질·Tempest 코일 인상·실전 분출감의 잔여를 분리한다. 이전 지적을 새 P0 없음이라는 말만으로 닫지 않는다.

| 최종 자료 | 조건 |
| --- | --- |
| [release24쌍](release/manifest.json) |12대표×0.06초 낮/0.18초 밤. 원본 아이콘/Before0.111.4/After. 같은 카메라·월드 좌표·상대 시점이다. |
| [Oath pulse2](oath-pulse2/manifest.json)·[pulse3](oath-pulse3/manifest.json) |각2쌍. pulse1과 함께 각 확정 펄스의 다른 위치/기울기1검흔을 비교한다. 실제3연속 재생/무기 동기 전체 통과가 아니다. |
| [IceElf 야간](ice-matched/manifest.json) |ClockTime0·0.12초 비행. Glass 본체와 전진 방향 발광맥을 비교한다. |
| [최신128종](catalog/manifest.json) |각1정지 프레임·8contact sheet. 새로운 주 형상 누락/뚜렷한 뒤틀림 여부를 ART가 전수 검토했다. 모든128종이 개별적으로 개선됐다는 뜻이 아니다. |

최종 유효 전후는29쌍이다. 기하는 지정 시점으로 step한 뒤 yield 전에 동결하며 입자는 재방출하므로 정확한 입자 연속 운동 수용 근거가 아니다. 낮/밤과 상대 시점이 결합된 표본이므로 감쇠 시간의 단독 근거는 엔진 검사다. `comparisons`, `first-refinement`, `reviewed`, `final`, `caldera-final`, `ice-night`는 지적/재수정 경위를 보존한 중간 자료로, 최종 수용에서 제외한다. 비교 PNG를 다시 그리거나 효과의 픽셀을 보정하지 않았다.

`*-provenance.json`은 baseline `e039714d`와 후보 덮기·capture/fixture/입력 SHA를 기록한다. 최종 release·추가 펄스·ice-matched·catalog는13입력 모듈이 최종 native/빌드와 같다. 중간 시안의 해시는 최종과 다르다.

## 검증·빌드

- [격리 엔진23묶음117,733검사](native.json): 영웅128종199펄스/4기본 접촉, 적50종146공격/40투사체·링 안전 반경, 지원3종, 중복·취소·회수·포화·유한 좌표·시간 이력 독립성 및 이번 격차 검사 통과. [입력](native-provenance.json).
- `0.111.6`, 소스 `8d4d2d20f4b5e228684e043537566852f8f1364d`. [빌드 기록](build.json)·[실제 ModuleScript13개 정합](build-integrity.json)·[동일 rbxlx 재검사](build-native.json). 소스를 먼저 고정·푸시하고 단일 산출물을 만들었다. 별도 Studio 문서에서 gameplay scripts를 끄고 검사했다. 게시/실제 플레이 수용은 별도다.
- 공유 작업 폴더의 월드 작업과 버전0.111.5를 보존하려 격리 작업 트리에서 다음 버전0.111.6을 만들었다. 다른 미커밋 자산을 포함하지 않았다. 산출물의 지속 사본은 작업 폴더 `builds/0.111.6/TheLastThrone-0.111.6.rbxlx`다. 릴리스 태그/Roblox 게시는 하지 않았다.
- 정적 검사는 지정 파일의 whitespace/Python 컴파일, manifest 개수·PNG SHA·최종 모듈 해시·로컬 링크·LFS 포인터와 원격 커밋 일치로 구분한다.

재현은 `tools/prepare-roblox-vfx-polish.py --source e039714d --candidate --output <fixture>`와 출력된 `run-in-roblox` 명령이다. 최종 소스 검사에는 `--source 8d4d2d20`과 후보 덮기 생략을 사용한다. 캡처는 `--capture`, 복원은 `tools/decode-skill-vfx-art-review.py`의 Before0.111.4/After Lost Ark Review 라벨을 사용한다.

미검증은 게시 클라이언트·실제 입력/전투·4인/AI 혼전·정확한 무기/입자 연속 동기·그래픽 품질 양끝·터치/패드·저사양 GPU/메모리·사용자 최종 미술 수용이다. 다음 담당은 ART/QA와 사용자이며 실제 영웅·지역에서 잔여 재질/분출감과 위험 가독성을 확인한다. 이번 수정으로 상용 RPG와의 격차가 모두 사라졌다고 보고하지 않는다.
