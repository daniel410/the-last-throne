# 영웅별 전투 VFX 리서치

작업 TLT-033/057 · 확인일 2026-11-11 · 역할 researcher/software_engineer. 사용자 요청: 네 영웅 기본공격·모든 스킬의 특성에 맞춘 VFX 개선. 게임 수치·판정·해금 계약은 유지한다.

## 확인한 근거와 적용

| 사례·원천 | 확인한 사실·한계 | 이번 적용 판단 |
| --- | --- | --- |
| [Diablo IV Quarterly Update, 2021-12-20](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 출시 전 개발 자료. 가독성 우선, 강도 위계, 여러 VFX 속성을 개별 조절하는 방향을 설명한다. 현행 패치의 실제 플레이 검증은 아니다. | 기본 공격은 짧고 좁은 잔상, 상위 기술은 추가 리본/파편, 궁극기는 더 긴 수명과 두꺼운 리본. 범위 전체를 불투명하게 덮지 않는다. 실제 피해 증가에 따른 자동 확대는 보류한다. |
| [Lost Ark Aeromancer Academy, 2023-08-08](https://www.playlostark.com/en-us/news/articles/lost-ark-academy-aeromancer) | 공식 직업 안내가 찌르기·내려치기·회전·소용돌이·비 등 동작과 작동 순서를 구분한다. 영상 프레임 분석/직접 플레이는 수행하지 않았다. 인기 순위 근거로 사용하지 않는다. | 동작에 따라 전방 찌르기, 수직 베기, 원호, 낙하, 흡입 나선을 구분한다. 우산/직업 자산·고유 연출·스킬 수치 복제는 하지 않는다. |
| [Roblox Beams](https://create.roblox.com/docs/effects/beams), [Trails](https://create.roblox.com/docs/effects/trails), [Effects](https://create.roblox.com/docs/effects) | Attachment 사이 리본/이동 궤적, 폭·색·투명도·수명 제어와 그래픽 품질별 검토를 안내한다. | 외부 업로드가 필요 없는 절차형 리본과 기존 TD 무기·화살 및 PixelFX를 조합한다. 기본공격/기술의 실제 발사·타격 시점을 유지한다. |

Diablo의 장르 가독성 원리를 우선하고 Lost Ark는 동작/원소 분화의 보완 비교로 사용했다. 위 자료의 표현 원리에서 도출한 아래 설계는 이 프로젝트의 해석이며 타 게임의 실제 구현 코드에 대한 주장이 아니다.

## 영웅별 반영

- Knight: 검 궤적의 폭/소멸 테이퍼, 찌르기 압력선·반달/회전 베기·방패 파동/갈매기 형상. Paladin은 동일 무기 문법에 성광 팔레트를 적용한다.
- Dwarf: 짧고 두터운 기본 타격, 수직 내려찍기·회전 도끼의 공기 고리·암석 파편/지면 균열. Gunner는 가는 탄도와 폭발 전면/불씨로 분리한다.
- Elf: 기본 화살/정밀 사격/속사/다중 사격의 폭·길이·색을 구분한다. 전직 기술은 관통 후류·낙하 깃·마력 나선·뿌리 감기·전기 가지로 분화한다.
- Mage: 비전 나선·물의 확산/물보라·중력의 안쪽 나선·불꽃/불씨·얼음 파편·번개 가지·대지 균열·용암·증기 상승. Wind Lance의 기존 별도 공기 리본은 유지한다.

## MCP 조사와 검증 방법

Studio MCP의 제공 목록에서 `rbx-docs-search`, `rbx-perf-profiling`, `rbx-scene-analysis`, `rbx-debug`를 확인했다. 문서 검색은 API 확인, 성능 분석은 CPU/GPU 프레임 비용, 장면 분석은 인스턴스/메모리, 디버그는 런타임 문제 분석에 적합하다. 이번 화면은 UI 변경이 없어 device simulator 적용을 필수로 삼지 않았다.

`list_roblox_studios`는 실행된 Studio를 반환했으나 `Place is not open` 상태였고, `list_skills`도 같은 오류를 반환했다. 스킬 본문을 실제 적용/실행했다고 보고하지 않는다. MCP 연결을 우회하지 않고 공식 문서 웹 열람과 설치된 `run-in-roblox`의 별도 로컬 Place 엔진 검사로 보완했다. Studio 앱/로컬 파일 열기 명령은 실행했으나 CUA 화면 확인도 timeout으로 실패했다.

최소 실험은 카탈로그128개 기술의 생성·유효 좌표·정리·전투 충돌 없음, 실제 advanced 이벤트 연결, 공통 근접 기술의 서버 속성 연결, 중복/늦은 펄스, 거리/동시 상한이다. 추가 장식층 예산은 PC12/터치8효과·PC240/터치144 Beam·파편48개다. 기존 범위선/PixelFX/Wind Lance 예산은 별도이므로 전체 게임 성능을 이 수치로 주장하지 않는다.

비용/위험: 반복 효과의 과밀·모바일 투명 오버드로·다수 Attachment 갱신 비용. 거리 제한과 동시 상한으로 장식을 생략하며 서버 판정은 그대로 유지한다. 다음 담당 QA/사용자는 실제 게시 클라이언트의 네 영웅·8계열, 저/고 그래픽 품질, 1~4인+AI에서 적 예고 가림과 P95 프레임 시간을 확인한다. 엔진 fixture 통과를 미술/성능 수용으로 간주하지 않는다.
