# TLT-033/054/056/057 · 번개·얼음·낙하 VFX 후속 개선

2026-11-13 · 0.104.25 · 로컬 구현·격리 엔진 검사·고정 빌드 완료. G1/G4 전체 수용·티켓 Done·게시·실기기 수용과 구별한다.

## 변경·조사 근거

[후속 Roblox RPG 조사](../../research/2026-11-13-roblox-element-motion.md)를 적용했다. World // Zero 공식 번개 이미지의 연결된 분기·명암 대비, Blox Fruits 공식 미술의 윤곽/여백, Vesteria 공식 설명의 낙뢰·고드름 하강/지면 얼음 방향을 비교했다. Diablo IV의 전투 가독성/시간 정렬과 WoW의 원소/직업 정체성을 유지한다. 홍보 그림·문서 설명·실제 플레이의 관찰 수준은 조사에서 구분했다. 외부 자산을 복사하거나 업로드하지 않았다.

- 번개: 주 경로와 가지가 같은 꺾인 점을 공유한다. 주 링크당3개의2구간 분기,4목표 체인은 링크당1개 분기로 제한한다. 기존 확정 목표 입력을 그대로 연결하고 빈 체인에는 경로를 만들지 않는다. 청색 면과 밝은 중심을 구별하고 기존0.16초 소멸을 유지한다.
- 냉기: 낮은 경계 타일을 높이가 다른8개 결정으로 교체했다. 각 결정은0.18초 동안 성장하고 최대0.024초의 장식 지연을 둔다. 크기가 변해도 밑동은 고정되며 중앙은 비워 둔다. 얼음창에는 얇은 측면 결정2개를 추가했다.
- 낙하: 우박/물리 화살비/자연 마법 화살비의 본체와 잔광이 같은 가속 하강 곡선과0~0.024초 장식 지연을 사용한다. 정지한 파편을 실제 하강하는 형태로 바꾸고 낙하 끝에 소멸한다. 같은 계열의 Ash/Mortar 잔광도 공통 하강식을 사용한다.

생산 변경은 `HeroVFX`, `HeroVFXSurfaces` 두 표시 모듈이다. 기존 서버 확정 펄스 이후의 장식이며 실제 피해/피격·범위·MP·쿨다운·상태·해금을 바꾸지 않는다. TD 운영 코드·저장·재화 변경 없음. 이전 [검기·화염·열린 충격파](../roblox-rpg-vfx-20261113/README.md), 금빛 성속성·전용 바람·물/대지 형상을 보존한다. [미술 정본](../../production/element-vfx.md).

## 전후 캡처

![개선 후9기술](after.png)

[9기술 전후 비교](comparison.png): Lightning Line/Chain Lightning/Storm Arrow/Frost Lance/Frost Ring/Eternal Tempest/Hailfall/Arrow Rain/Spirit Rain 순서다. 각 쌍의 왼쪽0.104.24, 오른쪽0.104.25. 같은 모형·바닥·조명·48도 카메라를 사용하고 넓은 기술은 카메라 거리를 늘려 전체 범위를 보이게 했다.

`tools/capture-rpg-element-motion-review.luau`가 생산 `AdvancedSkillVisual.play`와 지정된 체인 목표 입력을 호출한다. 번개 장식은 생성 후 scheduler yield 없이0.07초를 직접 샘플한다. 실제 대기 중 짧은 체인이 먼저 만료된 시도가 있어 폐기하고 양쪽 모두 이 방법으로 재촬영했다. 다른 장식은0.14초 샘플이다. 생성 인스턴스를 복제/동결하고 입자는 재방출 후 동결해320×240으로 캡처했다. 합성 Tween/입자의 실제 프레임 시각이나 첫 로드 지연을 증명하는 영상이 아니다.

관찰: 번개 가지가 실제 주 경로에 붙으며 얼음창의 겹친 면과 광역의 세로 결정이 읽힌다. 우박/화살비는 정지 파편 대신 하강하는 본체를 가진다. 흑백/실제 영웅/어두운 지역·다인 교전의 최종 식별 수용은 남아 있다. 움직임 자체는 아래 엔진 위치/성장 검사로 확인했고 정지 PNG만으로 동작 완료를 판정하지 않았다.

재현은 앞뒤 격리 Place에서 캡처 도구를 실행한 뒤 `python tools/decode-rpg-vfx-comparison.py <before.log> <after.log> <output> --expected 9`를 사용한다(Pillow 필요). 디코더는 완료 표식·프레임 수·번호·동일 메타데이터·픽셀 바이트 수를 확인한다. [장면/PNG 해시](samples.json), [원시 로그 해시](capture-logs.json), [캡처 스크립트 해시](validation.json).

## 검증 조건·결과

- [CPU 회귀](cpu.log): PixelFX634 + SkillEffects15,938 = **16,572 PASS**. `lua tests/pixelfx.spec.lua`, `lua tests/skill-effects.spec.lua`. [변경 Luau 컴파일](compile.log) PASS. Python 도구2개 AST 파싱 PASS.
- `python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-rpg-pass2-after` 후 출력된 `run-in-roblox` 명령을 실행했다. Client/Shared만 포함한 PlaceId/GameId0·실제 플레이어0 격리 Place. 저장/서버 gameplay·실제 RemoteEvent 전송 수용은 수행하지 않았다.
- [실제 Studio 엔진](native.log): **10,663 PASS / 12 suite**. 새 원소 동작78·이전 움직임190·원소84·WoW231·style58·curated182·PixelFX1690·Hero7566·Wind128·individual297·flourish57·Hit102. [요약](validation.json), [변경 후 입력](inputs.json), [변경 전 입력](before-inputs.json).
- 새 검사는 지정된 체인 목표 끝점·주 경로에 붙은 분기/구간 접속·170ms 후 소멸·빈 체인 무표현, 얼음 높이 증가/밑동 고정/재질/열린 중앙, 낙하 본체와 잔광의 좌표 일치/방향/시간 재샘플, 혼합 포화/전체 예산 반환을 확인한다. 기존128기술·4기본 공격·시전 취소/중복/만료·거리 컬링 회귀 포함.
- 동시12/터치8, 면160/터치80, Beam240/터치144, 파편48, 입자192/터치96 제한 유지. 번개/면/매 프레임 갱신이 늘어 GPU/실기기 성능 향상은 주장하지 않는다. 로그의 PC Lua update는 기기 수용이 아니다.

## 빌드·다음 담당

고정 소스 `796a05bfd1b3c57804d11118d1deb77710841069`를 원격 main에 반영한 뒤 단일 빌드0.104.25를 생성했다. [산출물/명령/SHA256](build.json), [빌드 XML의 두 모듈 및371개 엔진 검사 입력과 고정 커밋 일치](build-checks.log). Roblox 게시·릴리스 태그는 생성하지 않았다.

미검증: 게시 클라이언트·실제 TD 영웅/장비·밝고 어두운 지역·4인+AI·터치/패드·GPU/실기기·첫 로드·사용자 최종 미술 수용. 기존 폭탄 이미지의 Experience 권한도 이번에 해결한 것으로 처리하지 않는다.

다음 ART/QA는 실제 전투에서 원소/방향 식별·위험 바닥/목표 가림과 동일 기기 프레임 시간을 비교한다. 추가 개선 후보는 자연 덩굴의 성장 방향과 물리/마법 화살 명중 구별이다. 이번 작업으로 이 후보나 전체 티켓을 완료 처리하지 않는다.
