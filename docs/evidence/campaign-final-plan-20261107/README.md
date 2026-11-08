# 에픽 재미·줄거리·분량 최종 계획 검증

2026-11-07 · TLT-001/027/028/031/041/050/052/057/061~065/084/087 · DIR/PLAN/RES → QA/ENG

상태: 계획 작성·정적 정합성 검증 완료. 게임 구현·플레이 수용·부모 티켓 완료가 아니다.

## 변경과 원천

[최종 통합 계획](../../production/campaign-fun-and-duration-final-plan-2026-11-07.md)에 기존 승인 줄거리·순서, FV7장/다른4지역28장 확장, 사이드12개/Tessa와 최신 보상을 연결했다.35장별 사건·결과·시간, 파일럿/제작량/담당·저장/경제/성장·사용자 수용 조건을 정했다. 기존 확장 문서6개의 첫머리에 최종안과 보상0 전제의 대체 근거를 연결하고 README/plan/backlog/decisions/CHANGELOG를 갱신했다. plan의 본문에 남은 ‘게임은 이전 순서’도0.81.0/0.81.1 증거와 일치시켰다.

검토 소스는 `5fe105cefaff89b49df3d76eeb36e62bb03d5e14`, VERSION `0.83.7`이다. [content-inventory.json](content-inventory.json)은 실제 CampaignContent를 Lua로 로드해47퀘스트의 ID/에픽/side/목표 수/전투목표 수/초회XP·Gold를 집계한 스냅샷이다. 전투목표 수는 enemies 목록이 있는 목표 수이며 웨이브/처치/시간이 아니다. 미커밋 Blender/컨셉 수정·삭제·미추적 증거/로컬 파일은 이번 작업 대상에서 제외했다.

공식 비교는 [리서치](../../research/2026-11-07-campaign-fun-final-review.md)에 문서 열람과 TLT 적용 해석을 분리했다. 실제 비교 게임 플레이나 인기/유지율 검증으로 보고하지 않는다.

## 검증 명령·조건·결과

- 실제 `lua`의 `dofile('src/shared/CampaignContent.luau')` 집계: 본편35/목표157/전투목표64, 사이드12, 현재47퀘스트 완료XP/Gold 양수 확인. 본편 초회합15,025XP·19,170Gold. 프롤로그·처치·반복/난도 보상 제외.
- Python으로 계획의 장별 행 추출: 각 본편 ID 정확히1회, 현재35ID와 동일, 각7장 합계 DW45~60/GW50~70/FV60~90/EC60~90/HG70~100분. 전체285~410분, FV-01~03의22~33분, 선택100~160분·합산385~570분 확인.
- Python 상대 Markdown 링크 존재 검사: 이번 작업 Markdown 문서14개와 인벤토리 JSON1개 대상. 신규/변경 링크 누락0. 기존 README의 로컬 생성 빌드10개 링크는 현재 파일 부재를 확인해 기존 제한으로 남겼다. 외부 URL은 이 검사에서 제외하고 새 리서치의 공식 원천은 웹 도구로 별도 열람했다.
- `lua tests/campaign-reorder.spec.lua`: 종료0·1,871검사 PASS·현재 필수 솔로 경로 산술 최종Lv44. 실제 플레이/장기 성장 수용이 아니다. 새 본편 확장의 Lv80 도달을 주장하지 않는 근거로 사용했다.
- `python3 scripts/simulate_story_progression.py --output /tmp/tlt-campaign-final-progression-check.json`: 종료0. 기존32구간의 baseline 최종Lv39, adjusted 시나리오Lv40 출력. 과거 비교/제안 계산이며 현재35장 경로Lv44와 다른 범위다. 원본 보상 JSON은 덮어쓰지 않았다.
- `git diff --check` 및 `git diff --cached --check`: PASS. 선별 문서만 스테이징하고 런타임·맵 자산·보상 정본·VERSION 변경이 없음을 확인한다.

## 미검증과 다음 담당

실제 기준 플레이 시간/재미·10~15세 이해·신규 활동/좌표·구버전 콘텐츠 유지/이관 구현·실계정/DataStore·스트리밍/기기·멀티플레이·분당 경제·Lv60/80 성장은 미검증이다. 목표시간/표본/수용 수치는 최종 계획의 실험 제안이다. Studio·빌드·Roblox 게시·릴리스 태그는 수행하지 않았다.

다음은 QA/PLAN의 현행5지역 및 FV-01~03 기준 측정과 ENG의 콘텐츠 버전/구원정 계약, 이어 FV3장 파일럿이다. 이번 변경은 문서만 커밋·origin/main으로 푸시하고 원격 커밋 일치 여부로 마감한다. 게임 VERSION을 올리거나 릴리스 태그를 만들지 않는다.
