# Gloamwood · 일반5종/보스3종 컨셉 v5

2026-10-30 · **TLT-065/gloamwood-venomcoil-king-v5-20261030** · DES/ART · 최신 사용자 구성 반영, 모델 미제작

[현재 갤러리](index.html) · [카탈로그/해시](catalog.json) · [최종 프롬프트](prompts/prompts.json) · [모델링 목표](modeling-targets.json) · [후보 줄거리/목록](../../../docs/production/dark-forest-epic-candidate-2026-10-30.md)

최신 요청에 따라 **일반은5종, 보스는3종**으로 새 컨셉2장을 만들었다. 일반 Hollowbark Ent는 현재 구성에서 제외하고 엔트는 보스 Ancient Hollowbark만 남긴다. 기존 나방/중장갑 호위 제외·에픽1~4 보존/기존5~8 보류는 유지한다.

| 분류 | 현재 이름 · en-US 가칭 |
| --- | --- |
| 일반5종 | Webling / Silkweaver / Barkstalker / Gloambat / Venomcoil Centipede |
| 보스3종 | Widow Queen / Ancient Hollowbark / Venomcoil King |

Gloambat·Ancient Hollowbark는 기존 영문 표기를 유지하고 지네는 요청한 Venomcoil Centipede·Venomcoil King으로 정리했다. 앞선 중간안에서 줄여 쓴 지네 이름을 최신 사용자 지시로 Venomcoil로 바로잡고 보스는 Venomcoil King으로 지정했다. 이전 이름 대응은 catalog에 남긴다. 일반 엔트 및 예전 보드는 이력으로만 남기며 현재 목록/모델링 대상으로 사용하지 않는다. 필수/선택 보스 배치·새 에픽 번호/본편 채택은 확정하지 않는다.

## 현재 이미지

- [일반5종 보드 v5](gloamwood-normals-blocky-v5.png):1536×1024. 윗줄3/아랫줄2. 각 셀에 NORMAL 표기. [프롬프트](prompts/normals-blocky-v5.txt)
- [보스3종 보드 v5](gloamwood-bosses-blocky-v5.png):2048×768. 가로3셀, 각 셀에 BOSS 표기. [프롬프트](prompts/bosses-blocky-v5.txt)
- [기존 지역 전경](gloamwood-environment.png)과 [여왕 둥지](widow-queen-lair.png): 분위기/얼굴 참고로 유지. 실제 몸통/팔다리 제작은 현재 v5 보드가 우선이다.

현재 갤러리는4PNG다.8종은 새 보드2장에 담았으며8개별 이미지/3D모델·리그/AI 완성을 뜻하지 않는다. 셀 크기는 실제 종별 축척이 아니다.

## 제작과 검토

**built-in image_gen**의 참조 편집으로 만들었다. 이번 연속 요청에서 분류 보드2회와 Venomcoil 이름/킹 외형 수정2회,총4회다. view_image로 기존 일반6종/보스3종 블록형 보드를 직접 열람한 뒤 각각 편집 입력으로 제공했다. 기존 얼굴 인상과 색·큰 블록형 몸체/팔다리를 유지하고 일반 엔트 제거/5셀 재배치·등급과 이름표를 수정했다. 후속 보정에서는 일반 지네의 이름만 Venomcoil로 바로잡고,보스 지네를 왕관형3갈래 갑각·큰 목 갑주·금빛 테두리·치켜든 앞몸통의 Venomcoil King으로 강화했다. 여왕/엔트는 보존 방향으로 요청했다. 각 출력의 픽셀을 직접 확인해 일반5셀·보스3셀과 영어 이름/등급,일반 엔트가 없는 구성을 확인했다. 추가 보정 호출은 없었다.

첫 제작부터 총11회이며 이번 연속 작업은4회다. 원본 생성 경로의 결과를 보존하고 v5 파일명으로 프로젝트에 복사했다. 기존 보드와 프롬프트/검증은 이력으로 보존하고 현재 갤러리에서는 숨긴다. [catalog.json](catalog.json)의 images/creatures는 현재 구성, superseded_images는 이전 보드를 가리킨다. v3/v4의 프롬프트/검증도 각 버전 파일에 남겼다. CLI/API 우회나 Python 이미지 편집은 하지 않았다.

얼굴은 눈 배치/색·표정·송곳니/문양을 최대한 이어간다. 픽셀 단위 동일성은 미검증이다. 이미지의 음영/무늬가 실제 폴리곤 분할을 뜻하지 않는다. 정확한 후면·다리/마디 수·관절/접지/리그·실기기 가독성/성능은 미검증이다.

## 2~3k tris 목표와 후속

이전 사용자 요구인 **모델당2,000~3,000 tris**를 유지한다. 머리/얼굴·몸통·팔다리/날개·잎 등 전체 LOD0를 합산하는 제작 목표다. [modeling-targets.json](modeling-targets.json)은 현재8종만 포함하며 제안 배분 합계를 기록하고 실제 삼각형 수/모델 파일은 null로 남긴다. 단순 부위를 불필요하게 세분해 목표를 채우지 않는다.

큰 상자 몸통·각기둥 관절·쐐기 발·단순 지네 마디와 큰 날개 면을 우선하고 잔 나뭇결/갑각 문양은 텍스처로 제안한다. 실제 메시 제작 후 삼각분할 내보내기의 모든 부품을 합산해 측정해야 한다. 이번 그림은 후면 도면/UV/리그나 측정된2~3k 모델을 대신하지 않는다.

[기존 숲 조사](../../../docs/research/2026-10-30-dark-forest-candidate.md)의 방향을 시각 수정한 작업으로 외부 게임/자산을 추가로 차용하지 않았다. 다음 담당은 사용자/DIR의 방향 검토, ART 실제 메시/UV/리그와 tris 측정, DES/ENG/QA의 전투/모바일 수용이다. 게임 소스/기존 보상·통합 줄거리/에픽1~4/VERSION·기존5~8 이미지는 수정하지 않으며 게임 빌드/게시/태그·부모 티켓 완료는 수행하지 않는다.

PNG CRC·크기/바이트/해시/원본 복사,현재8종의5일반/3보스 분류·일반 엔트 제외·이름 대응·제작 목표 합계/실측 null·프롬프트/링크를 정적으로 검증해 [validation.json](validation.json)에 남긴다. 새 PNG2개는 LFS로 선별 저장하고 원격 전송 결과를 확인한다.

실제 정적 검사: `python3 /tmp/tlt-validate-gloamwood-v5.py` 종료0. 현재4/이전6PNG의 CRC·크기/해시/원본 복사,5일반/3보스의 정확한 목록·일반 엔트 제외·Venomcoil 이름,8종 목표 배분/실측 null,프롬프트/패키지 링크36개가 일치했다. 이번 연속 작업의 새4PNG는 총7,912,775바이트다. 범위 밖 기존968파일은 불변이며 병행 작업 문서2개는 보존/집계에서 제외했다. `git diff --check`를 확인한다. 브라우저 렌더/실제 메시/게임·기기 시험은 수행하지 않았다.
