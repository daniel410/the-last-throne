# TLT-063 · EC-01 화물 권양기 랜드마크

2026-11-16 UTC. 제작 스킬의 맵 구현·환경 아트·환경3D·리서치 역할을 순차 수행했다. 신규 스토리나 진행 조건을 추가하지 않는다.

## 공식 근거와 적용 판단

- [Diablo IV March 2022 환경 개발기](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 건축·재료로 장소의 역사를 설명하고, 어촌의 부두·생활 소품처럼 지역 생업에 필요한 구조를 배치한다. 게임 카메라의 판독을 위해 디테일을 더하거나 줄인다. 출시 전 환경 제작 원리이며 현행 시즌 수치나 직접 플레이 근거가 아니다. 이번 실행에서 본문 재확인.
- [WoW Retail Dragonflight Waking Shores 2022](https://news.blizzard.com/en-us/article/23822253/dragonflight-zone-preview-the-waking-shores): 화산 고도에 따른 거친 환경과 그 안의 거대한 요새를 설명한다. Classic과 혼합하지 않는다. 이번 실행에서 본문 재확인.

TLT 해석: EC의 산업 시설은 임의의 불빛·용암 증량보다 운송 구조의 인과가 보여야 한다. 이전 설산→화산 연결면 반복 개선 대신 EC-01 실제 승강기를 대표 실험으로 선택했다. 기존 지지 기둥 위 트러스·드럼·케이블을 연결하면 운반대가 목적 시설로 읽힐 것이라는 가설이다. 참고작의 고유 자산·문구는 사용하지 않는다. 기존 TD 룩과 승인된 원고/보행·저장 계약과 충돌하지 않는다.

| epic/story | 원천 | 사건·감정 | 공간·형상 | 상태 | 플레이 목적·검증 |
| --- | --- | --- | --- | --- | --- |
| EmberCaldera / EC-01 | CampaignStoryText EC-01, CampaignExpansionContent EC-01, CampaignQuestSetpieces.ember | 잃은 기어 회수→노동자 귀환·도시 길 복구 | 실제 FreightLiftDeck 뒤 기존 기둥2개를 연결하는45stud 트러스, 권양 드럼·브레이스·상부 케이블 | 정적 지지구조. 기어·도착등·운반대는 기존 개인 저장 태그와 pose0/3 유지 | 접근 시 화물 설비 인지, 승강장/회피 공간 유지. 동일 두 Edit 카메라·접지·경로 검사 |

환경3D 판정은 Derived다. 기존 TLT EpicEnvironmentKit.part/beam과 EmberCalderaWorld.FreightLiftGuide를 재사용하며 기존 steel/brass 색과 Metal을 유지한다. 외부 메시·텍스처·Blender 제작은 없다. 원본 Git blob 해시는 증거 source-preservation.json에 둔다. 원본 기둥/바닥/TD 자산은 변경하지 않는다.

대안: 새 대형 건물은 지역 확장/스토리 연결을 가릴 위험이 커 보류했다. 작은 잔석 추가는 최근 실험과 중복되어 제외했다. 이번 구조28파트는 실제 비용 증가이며 성능 개선 주장은 없다. 상부 구조가 가까운 카메라에서 크게 보이고 드럼이 트러스와 겹치는 한계가 있어 실제 접근·orbit·전투/기기 수용이 필요하다. 작은 권양기 개선으로 전체 에픽의 평탄한 대공간 문제가 해결되지는 않는다.

[검증·전후 화면·후속](../evidence/ec01-freight-headframe-20261116/README.md). G5/TLT-063 전체 완료 아님.
