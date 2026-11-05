# 스탯 투자 실제 증가량·기본 공격 피해 미리보기

2026-11-05 · TLT-027/028/050/052/084 · ENG → QA · 로컬 소스/격리 엔진 검증·미게시

사용자는 투자 미리보기의 실제 증가량과 공격력100/실제 피해의 혼동 해소를 요청했다. [공식 사례/적용 근거](../../research/2026-11-05-damage-display-and-investment-preview.md)와 [자동 회피 조사](../../research/2026-11-05-passive-evasion.md)를 분리한다. 프로젝트 제작 스킬에 따라 현재316P·MP해금·속도상한·TD 공통 룩앤필을 유지한다.

## 변경

- `SkillStatPreview`: 장비 보너스를 적용한 기본 공격 각타격을 서버와 같은 최종반올림으로 계산한다. 기사콤보1/2/3과Mage의INT참조를 구분한다. 기본공격과 투자후비교는 순수projection이며 저장/피해확정을 하지 않는다.
- `StatInvestmentPreview`: TD원본프레임/영어텍스트로 포인트화면 안에 현재→확정후(+증가량)를 제공한다. STR/INT장비배율·VITHP/방어경계·MP미해금·DEX상한의+0·소수속도증가를 반영한다. 빈초안은+버튼 안내와 현재기본공격피해를 표시한다.
- PC/협폭/모바일세로대응경로와 모바일가로 POINTS에서 같은 계산/설명을 사용한다. 데스크톱의 패널/리소스/확정버튼·스크롤 높이는 실제텍스트에 맞춰 늘린다. 모바일가로 네스탯44px버튼은 처음 보이는 위치를 유지하고 아래미리보기는 내부스크롤로 읽는다.
- 전투요약은 기본공격피해를Power보다 먼저 표시한다. 물리/마법공격력의 표시명은Physical Power/Magic Power로 바꾸고 계산기준값임을 설명한다. 기존 스킬별1타/다단총합/숙련미리보기는 유지한다.
- 힘방어·자동회피·서버피해/성장계수·저장/리셋권·전직·장비·TD원본을 변경하지 않는다. 기존 사용자Blender변경과 미추적첨부는 보존한다.

## 검증

| 명령/환경 | 결과 |
| --- | --- |
| `lua tests/stat-investment-preview.spec.lua` |40 PASS. 네클래스·기어배율·저장/초안보존·MP해금·VIT경계·DEX200/300경계·기본75/90/120/70·최종반올림·Mage INT참조 |
| `lua tests/skill-stat-preview.spec.lua` |1,392 PASS |
| `lua tests/equipment-impact.spec.lua` |44 PASS |
| `lua tests/hero-stat-effects.spec.lua` |576 PASS |
| `/private/tmp/td233-luau/luau-compile` 런타임6개 |PASS |
| 기존0.75.3 로컬Place에 후보6모듈만 메모리주입 후 `run-in-roblox --place builds/0.75.3/TheLastThrone-0.75.3.rbxlx --script /tmp/tlt-stat-investment-native.luau` |4,932 PASS: skill-stat-ui3,832 / mobile-landscape-details1,068 / inventory-impact32. [원시로그](native.log), [후보소스해시](source-hashes.json) |

엔진은 빈 로컬PlaceId0·플레이어0에서 실제 GUI생성자/TextService로 텍스트높이·각타격/초안값·패널/버튼/스크롤구조를 검증한다.1160/740/390/280폭·네클래스8계열 및702×193/702×260/796×260모바일가로를 포함한다. 기존TD자산203785492의asset type경고는 로그에 남아있고 이번변경의 자산수용으로 처리하지 않는다. 자동회피15%의 `0.85^5`와 장기유효HP산술은 별도계산으로 확인한다.

게임빌드/버전변경/태그/게시를 하지 않았다. 테스트는 기존빌드에 후보모듈을 주입한 소스fixture이며 확정빌드산출물의 수용이 아니다. 실제화면렌더·터치/패드·10~15세사용자이해·게시클라이언트/실계정저장은 미검증이다. 다음QA는실기기에서투자/취소/확정/재시도와일반무효과대상의피해를대조한다. 부모티켓은완료처리하지않는다.
