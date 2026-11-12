# 무료 Roblox VFX 개별 검토와 적용 후보

2026-11-12 · TLT-033/057 · Researcher/ART 검토 → DES/ENG/QA. 사용자 요청: 앞서 소개한 네 후보를 하나씩 검토하고 적용할 VFX 선정. **선정안이며 게임 적용·미술 수용 완료가 아니다.**

변경 범위는 이 조사와 [증거 폴더](../evidence/free-vfx-review-20261112/)다. 게임 소스·TD·VERSION·게시 상태는 변경하지 않았다. 기존 미커밋 파일을 보존한다.

## 판단 기준과 기존 상태

기존 [면 중심 VFX](../evidence/hero-vfx-flourish-20261111/README.md)와 [PixelFX 연결](../evidence/pixelfx-20261104/README.md)이 있으므로 전체 팩 추가보다 특정 표현의 대체를 검토한다. `HeroVFX`/`SkillVFXProfiles`의 3D 방향·범위, `PixelFX`의 국소 명중, `SelenePresentation`의 지원 확정 이벤트를 유지한다. 소스에서 Selene Heal은 MINT, Protect는 GOLD임을 확인했다. 과거 문서의 일괄 금빛 설명보다 현재 소스를 따른다.

디아블로 주 기준은 [Diablo IV 2021-12 개발자 VFX 설명](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)이다. 출시 전 제작 철학이며 현행 패치 관찰이 아니다. 전투 정보의 우선순위와 다인 가독성을 참고한다. 우리 게임은 회전 카메라·터치·4인+AI가 있어 화면을 크게 덮는 섬광과 장시간 연기를 줄이는 변형이 필요하다. 전투 수치·성장 계약과 충돌하는 변경은 제안하지 않는다. [기존 근거](2026-11-11-filled-combat-vfx.md)를 재사용했다.

Roblox [공식 ParticleEmitter 문서](https://create.roblox.com/docs/effects/particle-emitters)를 확인했다. 입자는 2D 이미지이며 화면 점유 면적과 겹침이 GPU 비용에 영향을 준다. 한 입자로 재생한다고 저비용이 증명되지는 않는다. 원근이 그려진 바닥 PNG는 실제 평면 범위의 대체로 쓰지 않는다.

## 1. Yuruzuu — 치유 우선, 마법궁수 다음

[제작자 원문](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021)에서 게임 사용·수정 가능, 크레딧 선택, 본인 제작 주장 금지를 확인했다. 원본 Discord 링크 소실에 대비해 [댓글27](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021/27), [댓글31](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021/31)의 첨부를 확인하고 아래 세 파일을 실제 다운로드했다. 댓글 첨부는 제3자 미러이므로 제작자 원본과 바이트 동일성을 주장하지 않는다.

| 효과 | 확인·판단 | 적용안 |
| --- | --- | --- |
| Healing Effect | 48,889바이트 Place. ParticleEmitter4개, Script/LocalScript/ModuleScript0개. 제작자 썸네일에서 십자·세로 반짝임 확인 | **1순위. Selene Heal**의 기존 일반 반짝임 일부를 교체. MINT 유지, 실제 회복 확정 시 짧게 방출 |
| Arrow Rain | 47,618바이트 Place. ParticleEmitter34개, 스크립트0개. 썸네일에 금색/청색 두 구성이 보임 | **2순위. `elf.magic_archer.spirit_rain`**. 마법형 낙하만 추출하고 기존4펄스·0.4초 간격 유지. 일반 궁수의 물리 화살에는 보류 |
| Lightning Strike | 124,906바이트 Place. ParticleEmitter19개, 스크립트21개. 소스에서 CameraShaker와 LightningBolt 의존 확인. 썸네일의 큰 섬광·연기 확인 | 기본기 교체 보류. 향후 큰 번개 기술용으로 축소·모듈 추출 검토 |
| Lightning Blade | 이름·제작자 공개 항목 확인, 파일 내부·동작 미검증 | 상시 무기 오라보다 단발 스킬에 한정해 후속 검토 |
| Thunder Spear | 공개 항목·첨부 링크 확인, 파일 내부 미검증 | 현행 동명 마법사 스킬의 후속 비교 후보 |
| Pyronado | 공개 항목 확인, 원본/내부 미검증 | 화염 계열 범위기 후보로 보류 |
| Galaxy Orb | 공개 항목·보관 링크 안내 확인, 파일 미확보 | 기본 마법탄보다 큰 연출이므로 보류 |
| Hollow Purple | 공개 항목 확인, 파일 미검증 | 특정 작품 연상 이름·표현 대신 기존 비전 연출 유지 |
| Scorched Earth | 제작자 후속 공개 확인, 만료 매개변수 포함 다운로드는 미확보 | 원본 확보 전 제외 |

치유의 emitter 이름은 `Shards`, `Plus`, `ShardsBigger`, `Specs`다. Texture는 `8030734851`(두 emitter), `9937082969`, `9997556038`이다. 재사용 가능한 Texture 참조를 찾았다는 의미이며 RPG Experience에서 이용·로드가 허용됐다는 뜻은 아니다. Place 전체의 조명·캐릭터·서비스를 가져오지 않고 필요한 emitter만 추출한다.

화살비34개는 **예제 Place 전체 개수**이며 한 시전의 실제 동시 방출 수가 아니다. 스크립트0개인 두 파일도 모든 종류의 악성 동작·권리 문제가 없다고 인증한 것은 아니다. 세 파일 모두 게임에 열거나 실행하지 않았고 바이너리 INST/PROP의 클래스·문자열만 정적으로 확인했다. [요약](../evidence/free-vfx-review-20261112/yuruzuu-summary.json) · [다운로드 해시](../evidence/free-vfx-review-20261112/downloads.json).

## 2. ParticleFX — 24개 실제 PNG 검토

[무료 팩](https://www.particlefx.studio/roblox/free-vfx-pack)을 브라우저에서 실제 다운로드했다. ZIP 내부 README의 상업 게임 사용·크레딧 불필요·팩 자체 재판매/재업로드 금지 조건을 확인했다. ZIP은 로컬 Downloads에 두고 저장소에는 팩을 재배포하지 않는다.

24 PNG 모두1024×1024다. Katana Combo는4×4(셀256px), 나머지는8×8(셀128px)이다. [24종 대표 프레임](../evidence/free-vfx-review-20261112/particlefx-24-review.png)과 [6종 시간순 프레임](../evidence/free-vfx-review-20261112/particlefx-sequence-review.png)을 실제 이미지로 검토했다. 대표 프레임은 알파 총량 최대 셀이라 폭발의 가장 밝은 순간과 다를 수 있다. 시간순 판도 함께 판단했다. [개별 해시·격자](../evidence/free-vfx-review-20261112/particlefx-manifest.json).

| 효과 | 판정·이유 |
| --- | --- |
| Frost Nova | **3순위 시험**. `mage.cryo.frost_ring`의 중심 냉기 파편 보조. 바닥 원근이 고정돼 있어 실제 범위 원은 기존3D 유지 |
| Rolling Fireball Explosion | **4순위 시험**. `dwarf.gunner.bomb_toss`의 국소 폭발 대체. 원본2.4초의 검은 연기 꼬리를 줄여 반복 타격 가림 비교 |
| Ground Slam Crater | 조건부. `dwarf.common.ground`의 명중 먼지 보조. 이미지 속 고정 원근·가짜 바위/바닥은 회전 시 지면과 어긋날 수 있음 |
| Regeneration | 치유 대안. 초록 기둥이 몸을 감싸며 원본2.4초. 카메라 독립 구성이 가능한 Yuruzuu 치유를 우선 |
| Katana Combo | 보류. 한 시퀀스에 다른 방향의 검기가 있어 기존 한 번 베기·무기 궤적과 맞추기 어려움 |
| Counter Hit Flash | 보류. 분홍/빨강 섬광이 현행 적대색 피격과 혼동 가능 |
| Anime Impact Frame | 제외. 검은 배경과 화면형 선이 국소 전투 연출에 부적합 |
| Blazing Combo | 보류. 화염 검격은 클래스 의미에 맞는 기술에만 제한 |
| Frost Edge | 보류. 냉기 검격보다 Frost Ring이 기존 기술 의미와 가까움 |
| Lightning Charge Aura | 보류. 상시 오라는 몸·바닥 위험 신호를 가릴 수 있음 |
| Energy Aura | 보류. 상시 초록 화염이 지원·자연 계열 색과 겹침 |
| Plasma Detonation | 보류. 큰 흰 섬광으로 국소 폭발 식별력 비교가 먼저 |
| Comic Kaboom | 제외. 만화 글자형 폭발이 현재 미술과 어긋남 |
| Rebirth Burst | 보류. 부활/레벨업 시각 의미를 따로 결정해야 함 |
| Pet Egg Hatch | 제외. 현재 요청의 전투 적용 대상 없음 |
| Gem Shower | 보류. 실제 보상 확정과 무관한 보석 표현 금지 |
| Tower Upgrade | 제외. RPG에는 타워 업그레이드 적용 지점 없음 |
| Enemy Defeat Coin Drop | 보류. 현재 보상 표시·드롭 의미와 일치 확인 필요 |
| Win Pad | 제외. Obby 승리 패드 표현 |
| Checkpoint Activated | 보류. 기존 이동/저장 완료 의미와 정합성 확인 필요 |
| Speed Boost Pad | 제외. 이동 버프 신규 규칙을 만들 이유 없음 |
| Achievement Unlocked | 보류. 이미지 내 글자와 기존 승인 UI가 중복 |
| Quest Complete | 보류. 이미지 내 글자와 기존 완료 UI가 중복 |
| Cooldown Ready | 제외. READY 글자 포함, 기존 스킬 버튼과 중복 |

## 3. saythrt’s Mega Pack — 이번 적용 대상 보류

[Creator Store](https://create.roblox.com/store/asset/83841806206726)에서 제작자 설명·무료 Get Model·구성 예고를 직접 확인했다. 설명은 텍스처7천 이상/메시180 이상/스크립트14개/완성형5개와 수정·재구성 시 크레딧 조건을 제시한다. **이는 제작자 설명이며 파일을 내려받아 센 수가 아니다.**

현재 필요한 네 표현이 더 작은 원천으로 특정됐으므로 거대 재료 라이브러리에서 새 효과를 조립할 이점이 작다. 원본 모델·개별 텍스처의 제작자/권리·성능·내부 스크립트는 미검증이다. 향후 특정 파형/연기 텍스처가 부족할 때만 필요한 한 자산을 추적한다. 팩 전체를 게임에 추가하지 않는다.

## 4. CIX Library — 제작 도구로만 보류

[스토어](https://create.roblox.com/store/asset/16592166013/CIX-Library)에서 Plugin 유형과2026-01-02 갱신을 확인했다. [제작자 설명](https://devforum.roblox.com/t/over-600-free-particle-with-cix-library-a-particle-library-plugin/2864815)은600개 이상과 무료 유지를 안내하지만, 본문에서 개별 텍스처별 권리 목록은 확인하지 못했다.

설치·실행·개별 자산 검증은 하지 않았다. 완성 스킬보다 재료 탐색 도구라 이번 적용 후보의 대안이 되지 않는다. 런타임 의존성으로 도입하지 않으며, 향후 부족한 재료를 찾을 때 원저작자와 허용 범위를 추적해 사용한다.

## 최소 적용 실험과 인계

추천 순서는 Healing Effect → Arrow Rain → Frost Nova → Rolling Fireball Explosion이다. [선정 비교판](../evidence/free-vfx-review-20261112/shortlist.png)은 위쪽 제작자 홍보 이미지, 아래쪽 다운로드 PNG의 프레임이다. 실제 게임 캡처가 아니다.

DES/ENG는 한 효과씩 기존 표현과 A/B 비교한다. 치유는 `SelenePresentation`의 실제 Heal 이벤트, 화살비/냉기/폭발은 `AdvancedSkillVisual`·`HeroVFX`·`PixelFX` 중 기존 재생 경로 한 곳에만 연결한다. 같은 위치의 기존 부가 효과를 교체하며 중복 레이어를 늘리지 않는다. 서버 피해·회복·펄스·범위·쿨다운은 유지하고 기존 시각 예산/취소/정리 정책에 포함한다. 외부 예제의 카메라 흔들림이나 루프 스크립트는 도입하지 않는다.

QA 수용은 (1) 실제 RPG 테스트 Experience의 텍스처 로드, (2) 밝은/어두운 지역에서 치유·적대/보호 구분, (3) 카메라 상하/회전 시 2D 지면 어긋남, (4) 네 명+AI 동시 사용에서 위험 예고·목표 유지, (5) 취소·사망·스트림 아웃 시 잔존 없음, (6) 같은 기기/장면/설정의 기존 대비 GPU·프레임 시간·메모리 비교다. 성능 수용 기준은 QA와 확정하고 숫자를 임의 PASS로 만들지 않는다.

검증 완료 범위는 공개 페이지·권리 안내 열람, ZIP/세 Place 확보, PNG 프레임 검토, Place 정적 구성 확인, 기존 기술 매핑이다. **Studio 재생·게시 클라이언트·실기기·성능·사용자 미술 수용은 전부 미검증**이다. TLT-033/057의 Done 상태를 변경하지 않는다. 다음 담당 DES/ENG는 치유 emitter4개만 추출한 격리 원형부터 시작하고 QA가 기존 효과와 비교한다.
