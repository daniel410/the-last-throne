# SKILLS·전직 통합

2026-11-01 · TLT-028/031/050/052/084 · ENG/DES → QA · 0.58.35 로컬 시험판

사용자 승인에 따라 ADVANCE 탭을 제거하고 STATS / SKILLS 두 탭으로 줄였다. SKILLS의 기존 계열 미리보기 선택이 전직 카드와 기술 트리에 공통 적용된다. 계열 특징·미리보기/저장 계열 구분·다음 전직 레벨/단계·현재 레벨/처치 수·해당 단계 기술명과 학습 레벨·전직 버튼을 같은 스크롤 화면에 제공한다. 기술 이름과 단계/레벨은 AdvancedSkills 정본에서 읽으며 생성 이미지의 글자를 사용하지 않는다. 기존 Training trial 문구는 실제 기록된 처치 수 안내로 바꿨다. 영어 문구는 AdvancementText로 관리한다.

첫 클릭은 선택 계열/단계를 검토하고 두 번째 CONFIRM에서 기존 Advance 명령을 보낸다. 다른 계열을 살펴보거나 스냅샷 revision이 바뀌면 이전 확인은 무효다. 최초 전직으로 저장된 계열은 이후 변경할 수 없고, 다른 계열의 기술은 계속 미리보기만 가능하다. 원래 서버의20/40/60/80·누적 처치3/6/9/12·거점 조건·권한·저장·동일 requestId 재시도는 유지한다. 조건을 완화하거나 훈련 시스템/저장 데이터를 제거하지 않았다. 기존 open('Advance') 호출은 SKILLS로 연결한다. 모바일 가로 탭44px·TD 프레임/버튼/초상을 유지한다.

검증: 독립 임시 SkillsAdvancementQA.rbxlx에서 native888개(8계열×4단계·차단 조건·확인/변경·서버 규칙·실제 글자/위치) 통과. 기존 skill-stat UI3200·모바일 상세972·모바일 상태920 통과. Lua advanced-skills1435·hero-progression656·skill-stat-preview1368 통과. 실제 Play Client 전체 컨트롤러는 원격만 BindableEvent로 대체해 계정 저장 없이 실제 클릭/확인으로 Paladin1차 전직 → 기존 HeroProgression.apply 결과 회신 → OATHBLADE 학습 표시·Lv40 다음 전직 잠금을 확인했다. 미리보기/검토에서는 Advance를 보내지 않고 CONFIRM에서1회 전송했다. 단순 화면 생성 검사와 실제 계정 저장 검증을 구분한다.

Device Simulator 스킬로 iPhone17 Pro 프리셋/가로를 적용했으며 실제 보고 viewport는750×381,패널726×307이었다. CoreUISafeInsets/ClipToDeviceSafeArea=true. 두 탭227×44·텍스트 적합·전직 버튼/편성 끝 스크롤·STATS 왕복·구 Advance 진입의 SKILLS 연결을 확인했다. 첫 모바일 검사는 패널 전체가 초기 스크롤 위치에서 들어와야 한다는 잘못된 가정으로 실패했으며 버튼으로 스크롤해 실제 도달을 재확인했다. 테스트 후 기본 viewport 복원·Play 중지·격리 세션 종료, 사용자의 별도0.58.34 Studio는 유지한다.

[공식 사례 조사](../../research/2026-11-01-skills-advancement-integration.md). [데스크톱 실제 GUI](desktop.jpg). 상세 수치와 한계는 native.json을 따른다. 미검증: 실기기 터치·실제 계정 저장/재접속·게시 클라이언트·독립 QA/사용자 최종 시각 수용. 다음 QA가 게시/실기기 수용을 진행하며 상위 티켓은 닫지 않는다. 다른 미커밋 작업은 보존하고 빌드 입력에서 제외한다. Roblox 미게시·릴리스 태그 없음. 고정 소스 빌드와 해시는 build.json을 따른다.
