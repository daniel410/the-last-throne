# Mixamo 도끼·검/방패·화살 장전 적용 조사

2026-11-08 · TLT-005/013/014/032/033/054/055/057/084/087 · ART/ENG → QA/DES

사용자가 지정한 axe, sword and shield, archer draw arrow 검색 결과를 로그인된 Chrome에서 확인했다. 드워프5개 FBX, Pro Sword and Shield Pack, Standing Draw Arrow를 실제로 내려받아 Blender5.2에서 평가했다. 원본은 로컬 Downloads에 보존하며 원본 FBX/팩을 Git으로 재배포하지 않는다. 선택 파일·FPS·길이·SHA256은 각 `assets/animations/mixamo-{dwarf,knight,elf}-v1/manifest.json`에 기록한다. 카탈로그의 같은 표시명만으로 파일의 세부 동작명을 추측하지 않는다.

## 근거와 적용 판단

- [Adobe FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html): 인간형 리깅·동작 라이브러리와 게임 프로젝트 사용 범위를 확인했다. 짧은 팔다리와 큰 장비의 적합성을 자동 보장하는 근거로 사용하지 않았다.
- [Mixamo axe](https://www.mixamo.com/#/?page=1&query=axe): Horizontal/Downward/Backhand/360 Low를 확보했다. 사용자가 추가 지정한 [Standing Melee Run Jump Attack](https://www.mixamo.com/#/?page=1&query=axe+jump+attack)은 달리며 도약하는 공격이다. Ground Slam에는 달리기 변위를 제거하고 도약·착지만 시각 루트에 옮겼다.
- [Mixamo sword and shield](https://www.mixamo.com/#/?page=1&query=sword+and+shield): 실제 팩을 확보했다. 기본3연격·넓은 베기·강한 베기·브레이싱을 구분했다. 검/방패 관통과 빠른 Euler 회전 문제가 확인되어 기본기의 접촉 구간·소켓·회복 끝 자세를 제약으로 두고 준비/회수 동작을 접합했다.
- [Standing Draw Arrow](https://www.mixamo.com/#/?page=1&query=archer+draw+arrow)의 실제 설명은 `Reloading Bow`다. 기본 공격 앞부분의 화살 장전에 적용하고 기존 발사 시각·앵커·반동·스킬 연사 이벤트를 유지한다. 장전 중에는 손 IK가 어깨 뒤 동작을 덮지 않게 하고 노크 후 다시 시위 타깃으로 넘긴다.
- [Diablo IV 2021년12월 개발 설명](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021)의 무기·효과·피격 방향 가독성 원리를 참고했다. 출시 전 설명이며 현재 시즌 수치의 근거가 아니다. Roblox의 짧은 기본 공격에는 원본 길이를 그대로 쓰지 않고 서버 접촉 시각에 맞춰 동작을 압축한다. 자원·피해·보상 규칙은 변경하지 않는다.
- [Roblox 애니메이션 사용 문서](https://create.roblox.com/docs/animation/using): 외부 애니메이션 자산/AnimationTrack의 재생 경로와 기존 관절 곡선 재생을 구분했다. 이번 구현은 기존 절대 서버 시각 기반 곡선 경로를 사용하며 신규 AnimationId/업로드 권한에 의존하지 않는다.

## 실험·선택·한계

원본 동작을 그대로 크게 적용하는 안은 짧은 체형의 무기 경로와 빠른 연격에서 관통·순간 회전을 만들었다. 최종안은 실제 원본 회전을 T-pose→R15 기준으로 옮긴 뒤 접촉·손잡이·방패 선행 조건과 함께 적용한다. R6는 기존 관절/접촉 경로를 보존한다. 기본 공격의 새 재사용 동작과 고유 신규 동작 수를 구분하며, 기술 수를 고유 Mixamo 클립 수로 보고하지 않는다.

최소 검사는 독립 Blender 평가, 실제 R6/R15 FK, 검/방패 분리, 날 선행, 노크/시위 일치, 연속 입력·취소·발사 이벤트 순서다. 원본 재배생과 정적 엔진 검사를 실제 사용자 입력·실기기 성능·최종 미술 수용으로 간주하지 않는다. 다음 담당은 QA/DES이며 실전 거리·여러 장비/체형·PC/터치/패드·관전자/지연·4인+AI 성능을 비교한다.
