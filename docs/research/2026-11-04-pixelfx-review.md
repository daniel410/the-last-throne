# PixelFX 도입 검토와 효과 미리보기

2026-11-04 · TLT-005/032/033/055/057/084 · 리서치·디자인·엔지니어링 검토

상태: 검토/효과 샘플 작성. 게임 적용·게시·최종 미술 수용은 미완료다. 기존 부모 티켓 상태와 게임 VERSION을 변경하지 않는다.

## 판단

**부분 도입을 추천한다.** PixelFX는 효과 제작/시안 도구로 적합하다. 우리 게임의 3D 무기 궤적·투사체·바닥 판정을 보완하는 짧은 접촉 섬광, 파편, 치유 입자를 우선한다. 전체 전투를 픽셀 아트로 바꾸는 제안은 아니다.

사용자가 지칭한 스킬은 [patch-gg/pixelfx의 SKILL.md](https://github.com/patch-gg/pixelfx/blob/a84159688af3ca37a4be05a0d422b94451b2e24e/skills/pixelfx/SKILL.md)로 식별했다. 설치된 로컬 스킬 목록에서는 찾지 못했으며 공식 저장소를 임시 체크아웃해 읽고 실행했다. 개인 전역 스킬 설치는 하지 않았다.

## 확인한 사실과 출처

확인일은 모두 2026-11-04다. 웹 문서와 고정 체크아웃을 확인했으며 다른 게임을 직접 플레이한 결과는 아니다.

- [공식 저장소](https://github.com/patch-gg/pixelfx): 검토 커밋 `a84159688af3ca37a4be05a0d422b94451b2e24e`, package 버전0.3.0. README는244효과를 설명한다. JavaScript로 색상/빛 버퍼를 그리고 PNG 시트와 Aseprite 형식 JSON을 생성한다. Node18 이상, 기본 렌더 도구는 별도 npm 설치 없이 실행됐다.
- [공식 라이선스](https://github.com/patch-gg/pixelfx/blob/a84159688af3ca37a4be05a0d422b94451b2e24e/LICENSE): MIT, Patch/Hugo Duprez 저작권 고지를 보존해야 한다. 배포 샘플 폴더에 원문을 동봉했다.
- [Roblox 파티클 공식 문서](https://create.roblox.com/docs/effects/particle-emitters): 2D 텍스처를 월드 파티클로 표시할 수 있고 플립북은2×2/4×4/8×8 및 Custom 격자를 지원한다. 프레임 간 여백이 필요하며, 텍스처 수/해상도에 따른 메모리 비용과 저메모리 기기의 플립북 비활성화를 설명한다.
- [Roblox ImageLabel 공식 문서](https://create.roblox.com/docs/reference/engine/classes/ImageLabel): ImageRectOffset/Size로 프레임을 선택하고 Pixelated ResampleMode로 픽셀 경계를 유지할 수 있다. 이는 GUI 경로의 기능이며 ParticleEmitter가 같은 샘플링 제어를 보장한다는 뜻은 아니다.

비교 목적상 PixelFX의 브라우저/2D 엔진 경로와 Roblox의 공식3D 파티클 경로를 대조했다. 다른 인기 RPG의 효과 품질·성과와의 인과관계나 비공개 지표는 주장하지 않는다.

## 현재 코드와의 접점

- `src/client/AdvancedSkillVisual.luau`: 서버 확정 결과에 따른 연출이며 클라이언트가 판정/피해를 정하지 않는다. 네온 Part, 호/번개/접촉 표현과 활성 Part128개 제한이 있다.
- `src/client/K0HitEffects.luau`: 실제 접촉 피드백 경로다. 최초 실험의 연결 지점 후보로 적합하다.
- `src/client/SkillEffectGeometry.luau`:3D 지면/방향에 따른 기존 형태 계산을 유지한다.
- `src/client/WindLanceVisual.luau`: 전용 바람 연출을 유지하고 필요할 때 끝점 입자만 보완한다.

PixelFX의 JavaScript를 Roblox Luau에서 그대로 실행하거나 Aseprite JSON을 자동으로 읽는 기본 기능은 확인되지 않았다. PNG 업로드와 별도 재생 연결이 필요하다. 기존 Part 제한은 새 파티클/GUI 자원까지 제한하지 않으므로 추가 예산·정리가 필요하다.

## 만든 예시와 적용 범위

[애니메이션 보드](../../assets/concepts/2026-11-04-pixelfx-preview/preview.gif) · [로컬 갤러리](../../assets/concepts/2026-11-04-pixelfx-preview/index.html) · [원천/옵션/프레임](../../assets/concepts/2026-11-04-pixelfx-preview/manifest.json)

| 대상 | PixelFX 후보 | 기대 효과/판단 | 이번 샘플 |
| --- | --- | --- | --- |
| 기사 | melee/sword-slash | 접촉 순간의 타격감 보완. 검의 실제3D 궤적 대체는 보류 | 금빛 팔레트,24프레임 |
| 드워프 | impacts/crit-hit | 도끼 접촉 위치의 짧은 강타 섬광. 일반 공격마다 큰 치명타 효과 반복 금지 | 원본 팔레트,28프레임 |
| 엘프 | nature/leaf-storm | 자연 마법의 주변 입자/색감 참고. 기존 기술 정의에 맞는 경우에만 선택 | 원본 팔레트,72프레임 루프 |
| Mage 화염 | fire/fireball | 열기·불꽃·연기 제작 참고. 측면 고정 스프라이트이므로 모든 카메라 각도용 본체로는 보류 | 원본 팔레트,36프레임 루프 |
| Mage 냉기 | ice/frost-nova | 얼음 파편/시간 변화 참고. 고정 원근의 고리는3D 바닥/파편으로 재구성 권장 | 원본 팔레트,103프레임 |
| Selene | holy/heal-aoe | 금빛 치유 입자와 회복 의미 보완. 지면 링은3D 유지 | 금빛 팔레트,88프레임 |

전부 `light:0.35`, 캐릭터 제외, 원본 시간/프레임 수 유지다. 샘플명은 기능 대응 설명이며 신규 기술명·해금/MP/피해/쿨다운 변경이 아니다. 특히 Selene는 NPC 지원으로 유지한다. 효과만 렌더링한 자료로 실제 Roblox 화면·현재 대비 개선 확정 증거가 아니다.

## 도입 대안과 비용

1. **추천: 짧은 타격/치유 보조 플립북.** 효과를 줄여 정사각 셀과 여백을 갖는4×4 또는8×8로 다시 패킹하고 실제 기기에 맞는 해상도를 정한다. 저비용 후보지만 자산 업로드·방향/가림·서버 이벤트 동기화·정리가 필요하다.
2. **복잡한 기술: 외형/타이밍만 참조해3D로 재작성.** 바닥 링·검 궤적·다방향 화염/냉기에 적합하다. 제작 비용은 더 높고 이식 결과의 별도 시각 검증이 필요하다.
3. **GUI 강조:** 획득/학습/강화 성공의 작은 입자에 쓸 수 있다. 승인 TD 프레임·버튼·아이콘·영웅 초상과 기본 배치를 유지해야 한다. 이번에는 게임 UI 미리보기를 만들지 않았다.

현재 출력 PNG는 PixelFX 일반 격자 원본이며 Roblox 업로드 준비본이 아니다. 특히 냉기103프레임·치유88프레임은8×8의64칸을 넘으며, 프레임 생략/시간 재표본화 또는 별도 Custom 레이아웃 검토가 필요하다. 단순 정사각 강제 축소는 형태를 왜곡한다. 원본 내보내기는 별도 additive 빛 패스가 합쳐져 있어 밝은 배경에서의 가독성도 실험해야 한다.

스킬의 전역 hit-stop/전체 정지 권고는 협동 서버에 그대로 적용하지 않는다. 기존 서버 시간·판정·다른 플레이어를 정지시키지 않고, 필요하다면 사용자 로컬의 짧은 시각 반응만 별도 검토한다. PixelFX 기본 캐릭터/무기/상태효과의 몸체 이미지는 TD 영웅 외형을 대체하지 않는다.

## 검증과 남은 수용

실행 환경: Node v26.4.0, 임시 Python venv의 Pillow13.0.0. 프로젝트 패키지/개인 전역 환경은 변경하지 않았다.

```bash
python3 -m venv /tmp/tlt-pixelfx-venv
/tmp/tlt-pixelfx-venv/bin/pip install Pillow==13.0.0
git clone https://github.com/patch-gg/pixelfx.git /tmp/tlt-pixelfx-review
git -C /tmp/tlt-pixelfx-review checkout a84159688af3ca37a4be05a0d422b94451b2e24e
/tmp/tlt-pixelfx-venv/bin/python tools/render-pixelfx-review.py /tmp/tlt-pixelfx-review
```

- 공식 `check.mjs`의 선택6개 기본 효과:6 PASS/0 FAIL/0 warning. 이는 원본 기본 옵션 검사이며 금빛 변형의 Roblox 수용 검사가 아니다.
- 여섯 효과의 기본 컨택트 시트와 금빛 변형 최종 요약 이미지를 직접 열어 확인했다. 금빛 검/치유, 원소 색상·형태와 파편 소멸을 프레임 시퀀스로 확인했다.
- 최종 산출물: 투명 PNG+JSON6쌍, 개별 GIF6개, 애니메이션 보드, 요약 PNG, 배경/재생 제어가 있는 로컬 HTML, 라이선스, 매니페스트·SHA256.
- 별도 정적 검증 PASS: PNG6개 RGBA/프레임 경계·메타데이터 일치, GIF6개 다중 프레임, 보드60프레임/30종 이상 서로 다른 프레임, 생성 파일 SHA256·HTML 참조 파일 존재. `node --check /tmp/tlt-pixelfx-gallery-check.js`, `python3 -m py_compile tools/render-pixelfx-review.py`, `git diff --check`도 PASS. GIF는 표시용 시간 양자화가 있으며 게임 타이밍 정본이 아니다.
- 브라우저 시각/버튼 조작 검증은 Work 설정의 `Local browser use is disabled`로 수행하지 못했다. GIF/PNG는 브라우저 없이 열 수 있다.
- Studio/게시 클라이언트/실기기/4인+AI 성능·카메라 각도·최종 TD 미술 적합성은 미검증이다. 게임 빌드·자산 업로드·Place 게시를 하지 않았다.

다음 담당: ART/ENG가 접촉 섬광1종과 Selene 치유 입자1종을 임시 토글로 연결하고 QA가 동일 장면 A/B를 확인한다. 모바일 가로·낮은 그래픽/밝은 Deepwood·어두운 지역·회전 카메라·4인+AI 동시 시전을 비교한다. 가설 수용 조건은 위험 예고/목표 가림 없음, 취소/사망/스트리밍 후 잔류0, 타격 시점 정렬, 목표 기기 프레임 예산 충족이다. 이번 검토로 효과 품질 향상이나 성능 통과를 확정하지 않는다.
