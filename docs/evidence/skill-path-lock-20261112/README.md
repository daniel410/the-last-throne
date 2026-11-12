# 전직 후 다른 계열의 잠금 표시

2026-11-12 · TLT-052 · ENG/DES → QA · 소스 구현·격리 Studio 검증, 미게시

변경: 첫 전직 이후 다른 계열의 탭은 회색 `LOCKED · PREVIEW`, 기술 노드·아이콘·연결선은 회색과 `PATH LOCKED`로 표시한다. 상세에는 선택한 계열 때문에 해당 기술의 학습·강화·편성이 불가능함을 안내한다. 다른 계열 미리보기는 유지하며 공통 기술과 선택 계열의 향후 레벨/단계 잠금을 구분한다. 서버 성장/저장 규칙과 승인 TD 프레임·버튼·초상은 유지한다. [관련 사양](../../class-advancement-and-skill-trees.md), [Diablo II·Roblox 공식 근거와 적용 판단](../../research/2026-11-12-skill-path-lock.md).

검증: `lua tests/advanced-skills.spec.lua` 1,435개, `lua tests/hero-progression.spec.lua` 3,711개 통과. `git diff --check` 통과. `python3 tools/prepare-skill-path-lock-native.py /tmp/tlt-path-lock-20261112`로 HEAD 소스에 작업 모듈3개만 덮어쓴 별도 검증 Place를 생성했다. 이는 제품 게임 빌드/릴리스가 아닌 검증 fixture다. 버전 증가·태그·Roblox 게시 없음. 입력과 SHA-256은 [inputs.json](inputs.json)을 따른다.

Studio Edit에서 `PlaceId=0`, 작업 변경 소스를 확인한 격리 `qa.rbxlx`에 `tests/skill-advancement-native.luau`를 실행하여 **5,560개 통과**했다. [실제 결과](native.json). 4클래스×2계열×4단계×3화면(1160×650, 702×193, 390×650)에서 다른 계열의 상태/회색 노드·모든 기술 표시·탭과 전직 안내 TextFits·강화/편성 비활성·전직 요청 미발행·공통 기술 강화/편성 유지·선택 계열 미래 기술의 일반 잠금을 확인했다. 기존 최초 전직 검토/확인·레벨/저장/스냅샷 차단 검사를 유지하고 반대 계열의 서버 규칙 거부도 확인했다. UI 크기 검사는 실기기 검사가 아니다.

자동 runner는 다른 작업이 점유한 50312 포트 충돌로 사용할 수 없어 임시 Place를 별도 Studio로 열고 Studio MCP로 실행했다. 첫 확대 검사의 공통 기술 실패는 시험 입력의 `canInvest=false` 때문이어서 투자 가능 스냅샷을 명시한 뒤 전체를 재검증했다. 제품 권한 조건은 변경하지 않았다. Edit 화면 캡처는 CoreGui가 포함되지 않아 최종 시각 수용 증거로 사용하지 않았다. 시험 GUI는 제거했다. TD 및 다른 기존 Studio의 내용은 변경하지 않았다.

미검증: 게시된 클라이언트, 실제 계정 저장/재접속, 실기기 터치·패드 조작, 사용자 최종 시각 수용. 다음 담당 QA가 게시 테스트에서 전직 전후 계열 비교와 입력/시각 수용을 확인한다. 상위 TLT-052/출시 게이트 전체는 완료 처리하지 않는다. 기존 사용자 미커밋 변경은 보존한다.
