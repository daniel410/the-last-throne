# 독립 아트 리뷰 후 스킬 VFX 재개선

TLT-033/057/059 · 2026-11-15 · ART/ENG · 구현·격리 검증. 게시/실기기/사용자 미술 수용과 전체 G4는 미완료.

사용자는 아트 에이전트가 새 스킬 아이콘을 참고해 VFX를 독립 리뷰하고 다시 개선하도록 요청했다. 별도 ART 에이전트가 원본 아이콘과 기존128종 화면/기술 정의를 대조했다. ENG가 구현하고 같은 ART 에이전트가 중간·최종 화면을 재판정했다. 원본 아이콘, TD 무기 자산, 서버 수치·판정·성장·저장·TD Experience는 변경하지 않았다.

## 리뷰 → 변경

[초기 리뷰](art-review-initial.md)·[128종 개별 관측/아이콘·화면 해시](art-review-initial.json)는 개선68·정지 형상 유지 후보39·연속 시점 확인21로 분류한다. 이는 초기 판정이며 이 수만큼의 결함을 모두 닫았다는 뜻이 아니다. [중간 리뷰](art-review-interim.md)에서 형상을 추가하는 것만으로는 긴 광선/원형 장식과 야간 대비 문제가 해결되지 않았음을 확인하고 다시 수정했다. [최종 ART 판정](art-review-final.md)·[판정/최종 입력 해시](art-review-final.json)를 함께 읽는다.

| 아트 지적 | 실제 수정 |
| --- | --- |
| 도끼가 삼각 화살촉으로 읽힘 | Advanced 투척은 장착 TD 도끼의 외형만 복제한다. 코드·관절은 제거하고 원본 자세/소유는 보존한다. 원본 미준비 시 금속 날·나무 손잡이·날 모서리를 가진 대체 도끼를 사용한다. 귀환 축·교차18도·확정 펄스를 유지하고 결정적으로 회전한다. 기본 throw의 기존 실제 무기 복제 경로는 중복하지 않는다. |
| 얼음4종·불3종·비전/바위의 같은 긴 쐐기 | 짧고 넓은 Ice Shard, 가는 Frost Lance, 작은 Shatter Dart, 두껍고 측면 결정이 있는 Glacial Spike로 구분한다. Flame Dart는 짧게, Magma Spear는 어두운 외피/용융심, Mana/Stone은 실제 결정 면으로 표현한다. |
| Molten Line이 공중 불창, 번개3종이 동일 | Molten Line은 현무암 띠/연속 용융심/밝은3구간으로 바꾸고 공중 FlameWake와 중복 광선을 제거했다. Thunder Spear는 곧은 축, Lightning Line은 낮은 직선 통로다. Chain은 확정 노드 간 연결과 빈 대상 처리 그대로다. 해당 지면 기술의 PixelFX도 낮고 작게 맞췄다. |
| Water Ball이 도넛·야간 소실 | 둥근 Glass 구체와 얇은 발광 표면, 닫히지 않은 짧은 포말 호2개를 사용한다. Tidal Ring의 지면 물결과 구별한다. |
| 중력·증기의 공통 원/구체 | 중력은 조밀한 어두운 핵/안쪽으로 움직이는 파편, 증기는 반사되는 검은 구 대신 옅은 비반사 상승 덩어리/기존 wisp로 구분한다. |
| 보호/폭풍/지형 상승이 같은 외곽 결정 | Ice Ward는 몸 둘레의3보호판·밝은 모서리/보석, Froststorm은3층 기류/하강 결정이다. Iron Shoulder는 연 방패 대신 금속 어깨 가드, Searing Ward는 화염 왕관 안쪽 보호층, Earth Rise는 높이가 다른3기둥이다. |
| 자연 마법의 가는 잎 윤곽·긴 방사형 줄기 | 실제 잎 면과 밝은 중심맥, Bloom5잎의 틈, 구속 고리, Burst3잎을 추가했다. Trap/Burst의 장식 뿌리는 실제 판정 경계를 바꾸지 않고 중심에 집중했다. |
| 궁극기·단발·도발의 위계 | 가까운 활 왕관/정령 가지·하강 잎, 어두운 분화구, 열린 폭풍 눈의3층 띠를 보강했다. 총탄 잔광은 짧게, 조준/관통 단서는 국소적으로 만들었다. 피해0 Provoke는 머리 높이의 목소리 호를 쓰고 명중 폭발광을 제거했다. |
| 모서리/손잡이가 작은 점으로 읽힘 | 공통 `HeroVFXSurfaces.bar`가 구형 Part였던 것을 길이/폭이 실제 선형으로 읽히는 Block으로 고쳤다. 각 부품의 크기·수명·공유 예산은 유지한다. 이전 버전의 비교용 helper는 별도 동결했다. |

주 형상을 `HeroVFXArt`로 분리하고 `HeroVFX`의 기존 예산·정리 경로를 공유한다. `AdvancedSkillVisual`은 주 효과가 생성됐을 때 중복 긴 광선/단순 쐐기만 생략하며 실제 범위선과 주 효과가 cull될 때의 기존 fallback을 보존한다. 기존 금빛 성속성·청색 번개·영어 ID와 서버 권위는 그대로다. 새 PNG/외부3D 업로드는 없다. [원본 아이콘/보조 cue 출처](../../../assets/effects/skill-icon-vfx-v1/manifest.json)·[기존 Diablo IV/WoW/Roblox 조사 재사용](../../research/2026-11-15-skill-icon-vfx.md).

## 검증 조건과 결과

- 정적: 변경 런타임6개 모듈/검증 도구·테스트만 수정했으며 서버/기술 정의는 바꾸지 않았다. 별도 무기 원본은 수정하지 않는다.
- Studio 격리 엔진 **PASS**: [16묶음·30,528검사](native.json)·[소스/검사/fixture SHA256](native-provenance.json). 현행128종·확정199구간, ART 핵심43조건, 기존14개 관련 회귀와 기존 아이콘 전수 검사를 실행했다. 피해/범위/시점 보존, 빈 연쇄 대상, 원본 무기 자세·소유/실행 자식 제거, 프레임 이력 독립성·회수, cull 시 legacy fallback과 공유 예산을 확인했다.
- 개별 Beam48 및 일부 마법24, 전역 Beam240/터치144·면160/터치80·입자192/터치96·동시12/터치8 상한을 유지한다. 상한 검사는 GPU/실기기 성능 수용이 아니다.
- 초기 캡처에서 짧은 효과를 만든 뒤 실제 시간 대기하면 편집기/캡처 지연 때문에 모델이 소멸해 빈 화면이 되는 경우가 있었다. 해당 로그는 화면 수용 증거로 쓰지 않고, FX의 상대 시점을 표본화한 뒤 yield 전에 도형을 복제하도록 고쳤다. 초기 바닥 검사도 의도한 미술 레이어 높이0.315stud를0.3으로 가정해 실패했으며 바닥 장식 허용층0.35 이내로 검사 조건을 명확히 했다. 실패를 최종 PASS 수에 더하지 않았다.

재현:

```bash
python3 tools/prepare-skill-icon-vfx-review.py --source 2aa4ffb7 --output /tmp/tlt-art-review
run-in-roblox --place /tmp/tlt-art-review/qa.rbxlx --script /tmp/tlt-art-review/probe.luau
```

`2aa4ffb7`의 소스를 추출하고 이 작업의 VFX9모듈 후보를 명시적으로 덮는다(실제 변경은6모듈). 테스트는 현재 검증 파일을 사용한다. 다른 미커밋 파일·계정·저장·외부 서버는 포함하지 않는다. 실제 빌드 검사는 별도 기록한다.

## 화면과 아트 수용 범위

원본 아이콘 / Before0.111.2 / After를 함께 배치했다. 비교의 두 화면은 같은 월드 좌표·카메라·조명이며 원본 PNG를 전투 VFX처럼 붙인 것이 아니다. 회색 모형에서 실제 절차형 도형을 캡처했다.

| 단계 | 자료 | 해석 |
| --- | --- | --- |
| 첫 개선28종×2시점 | [56쌍](comparisons/manifest.json)·[소스](comparison-provenance.json) | 0.06초 낮/0.18초 밤. 이후 보완 전 화면도 포함한다. |
| 지면 선/물/번개 보완 | [3종6쌍](refinements/manifest.json)·[소스](refinement-provenance.json) | 공중 잔광·물 야간 명도 수정. |
| 증기/보호/덩굴 보완 | [4종8쌍](contrast/manifest.json)·[소스](contrast-provenance.json) | 줄기/모서리를 실제 Block으로 바꾸기 전이다. |
| 귀환/교차/연속2펄스 | [도끼3종6쌍](return/manifest.json)·[소스](return-provenance.json) | 2번째 확정 펄스0.10/0.25초, 축/위치 비교. 이후 공통 bar 수정과 함께 해석한다. |
| 최종 공통 선형 도형 보완 | [9종18쌍](final/manifest.json)·[소스](final-comparison-provenance.json) | 해당9종은 이 최신 화면이 판정 기준이다. [보호/증기/도끼/구속](final/sheet-01.png)·[구속/궁극기/마그마](final/sheet-02.png)·[용암선/물](final/sheet-03.png). |

FX의 도형/소멸은 상대 시점으로 표본화했고, 복제한 입자는 다시 방출했다. legacy Tween과 입자의 연속 재생 전체를 정확히 같은 나이로 재현한 영상은 아니다. 실제 Player·원본 장착 무기·일반 지역·다인 전투·기기의 화면 수용을 대신하지 않는다. 중간/최종 캡처의 입력 해시를 섞어 하나의 고정 소스라고 보고하지 않는다.

최신 공통 선형 부품 소스로 [전체128종 개별 화면/해시](skills/manifest.json)를 다시 생성했다. [기사1](skills/knight-1.png)/[2](skills/knight-2.png)·[드워프1](skills/dwarf-1.png)/[2](skills/dwarf-2.png)·[엘프1](skills/elf-1.png)/[2](skills/elf-2.png)·[마법사1](skills/mage-1.png)/[2](skills/mage-2.png)·[정확한 소스](all-capture-provenance.json). 모두 첫 확정 펄스0.10초·합성 모형 조건이다. ART는 중간판128장과 최신판128장을 구분해 마지막 판을 재확인한다.

## 고정 빌드와 실제 빌드 문서 검사

**0.111.3 PASS**. 원격 반영한 입력 커밋 `dddfcc38b4697eb6bed657864a2bf2a71a7b9d12`에서 `python3 tools/build-game.py --source dddfcc38 --record docs/evidence/skill-icon-vfx-art-20261115/build.json`으로 단일 `builds/0.111.3/TheLastThrone-0.111.3.rbxlx`를 생성했다. [빌드 기록](build.json)·[무결성/해시](build-integrity.json): 19,830,374bytes. 후보9모듈의 실제 빌드 Source가 최종 엔진·최신128장·마지막18쌍의 소스 SHA256과 모두 일치한다.

이 실제 게임 빌드를 별도 Studio 문서에서 열어 BaseScript를 비활성화하고 저장/계정 없는 조건으로 **ART43 + 128기술199구간14,292 + Wind128**, [추가3묶음·14,463검사 PASS](build-native.json)를 확인했다. 별도 fixture 통과만으로 실제 빌드 연결을 추정하지 않았다. Edit 도형/수명 검사이며 실제 Player/서버/입력·게시 클라이언트 수용은 아니다. 일반 개선 빌드이므로 MICRO만 증가했고 게시/릴리스 태그는 없다.

## 미검증·다음 담당

ART/QA는 실제 영웅/승인 장비와 낮/밤 지역에서 시전→발사→명중→귀환/회수, 원본 도끼 복제의 미술 품질,4인+AI·위험 바닥/HP바/피해 숫자 합성, 저/고 그래픽·터치/패드·모바일 GPU/프레임 시간을 검증한다. 일부 자연 구속의 중앙 잡광, 궁극기 상대 위계와 초기21개 연속 동작 항목은 정지/엔진 검사만으로 수용 완료 처리하지 않는다. 전체 초기68개 지적 해결이나 사용자 최종 미술 수용을 선언하지 않는다.

롤백: 이 작업의 클라이언트6모듈 변경을 되돌린다. 데이터 이관은 없고 Place 게시·릴리스 태그는 수행하지 않는다. 작업 파일만 커밋/푸시하며 기존 사용자 변경은 보존한다.
