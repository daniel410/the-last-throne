# TLT-064 · HG-05 벽측 도관 실험

2026-11-18 UTC. MAP/ART/환경 모델링 순차 수행. **생산 미채택, G5 미완료.**

## 제작표와 판단

HG-05는 서/동 장치를 끊어 Veyr의 왕릉 방어를 해제하는 장이다. 기존 확장 구간의 눈높이 중앙 광선을 벽측 저상 금속 슬리브·돌 받침·결속 링으로 바꿔 동력 전달 구조를 읽히게 하는 후보를 구현했다. 기존 EpicEnvironmentKit의 Metal/Slate 파생이며 외부 자산·TD 변경 없음. 각 구간 하우징10파트, 총20파트 추가. 기존 Active/Broken 상태와 동일한 HG-05:west/east 이벤트, 하우징0~3단계 유지. 피해·보상·저장 코드 변경 없음.

같은 근접 Edit 카메라 before/after.png 비교에서 낮아진 광선과 슬리브는 보이지만 주변 경사면에 가려 받침·결속 구조가 충분히 식별되지 않는다. 높은 품질의 완성품으로 채택할 근거가 부족하다. candidate.patch만 보존하고 생산 소스 수정은 되돌렸다. 중앙 광선 전체가 사라져 보이는 before 화면은 카메라 위치의 결과이며, 전체 동선 가독성 개선으로 해석하지 않는다.

## 검증 조건·결과

- 기준 원격20ddb793. 기존 고정 빌드0.113.9를 /tmp/TLT-HG05-Conduit-QA.rbxlx로 복사해 독립 Studio5d648f96/PID86006에서 사용. 새 빌드는 아님.
- PlaceId0, BaseScript 비활성, Baseplate 제거, CampaignWorld.create(5) 한 번. 사용자 Studio는 변경하지 않음.
- CampaignIncidentScenes 복제 모듈에 후보 소스 주입. HG-05_exp_1/2 장면의 자식만 제거하고 원래 c/g/area로 create 재실행. 따라서 비교는 **사건 장면만 재구성한 Edit 실험**이며 정상 전체 플레이 장면이 아니다. 입구 아치/게시판 등 다른 생성기의 자식은 두 비교 모두 제외됨.
- 후보 하우징 양쪽 각각10파트, 전부 Anchored/CanCollide=false/CanQuery=false/CanTouch=false assertion 통과. ExpansionEvent 서/동 및 Min0/Max3 확인. 실제 클라이언트 상태 전환 검사는 아님.
- 카메라 위치(-270,197,-17330), 목표(-285,190,-17359), 두 이미지 동일. 전체 HG 조명 적용 전 Edit 기준. baseline은 원래 모듈로 동일한 두 사건 장면을 재구성함.
- 후보가 경사면에 가려 보이는 원인은 확정하지 않음. Terrain만 raycast한 표본은 대부분 y182 이하로 바닥188보다 낮았다. 이를 지형 충돌 결함으로 단정하거나 지형을 절삭하지 않았다.

## 근거·후속

2026-11-18 아래 공식 본문 재확인. 직접 플레이나 최신 패치 평가가 아닌 환경 제작 원리 비교다.

- [Diablo IV 2022 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 재료·건축·지역 역사로 설득력을 구성한다. TLT 해석은 공중 광선을 지지 구조에 연결하는 것.
- [WoW Dragonflight 알파 Azure Span 소개](https://news.blizzard.com/en-us/article/23823432/world-of-warcraft-news-and-development-updates): 지역의 높이 변화. TLT에서는 카메라 높이와 저상 구조의 관계만 참고.
- [Lost Ark 글로벌 Voldis 제작기 2024-02-02](https://www.playlostark.com/en-us/news/articles/creating-voldis): 탑의 높이로 인간의 의지를 표현한다는 설명. TLT 해석은 방어 장치의 기능을 구조로 읽히게 하는 것.

실제 R15 보행·장치 조작/귀환·회피·전투 카메라·진행 복원·게시 클라이언트·실기기·다인 성능·사용자 미술 수용 미검증. 새 버전/게시/태그 없음. 다음 MAP/ENG/QA는 정상 장치 조작 화면과 전체 장면에서 가림 물체를 먼저 식별하고, 그 결과로 도관 연결 위치를 결정한다. 저상 도관이나 석재 증량 후보를 반복하지 않는다.
