# TLT-064 · HG-03 관리 통로 지형

2026-11-15. 맵 구현·환경 아트·환경3D·리서치 역할을 순차 수행한다. 최신 스토리 정본은 campaign-context-review-2026-11-10의 HG-03: Lumi의 관리 통로로 윈치에 접근한다. 옛 지도 명세의 이름 복원 이야기를 재도입하지 않는다.

## 관찰과 적용

- [Diablo IV March 2022 개발 환경 아트](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022): 지역 역사·기후·재질·건축이 장소의 설득력을 만든다는 설명을 본문 재확인했다. 출시 전 미술 방향이며 현행 시즌/밸런스가 아니다.
- [WoW Retail Dragonflight Azure Span](https://news.blizzard.com/en-us/article/23823429/dragonflight-zone-preview-the-azure-span): 고저차와 숲·해안·설원의 변화, 거주민의 생활을 함께 소개한다. 2022 확장팩 소개이며 현재 패치 플레이 측정이 아니다.
- [Roblox Terrain](https://create.roblox.com/docs/reference/engine/classes/Terrain): FillBall의 중심·반경·재질 입력을 확인했다. 기존 Native Terrain 생성 경로를 재사용하며 외부 자산은 가져오지 않는다.

해석: HG-03의 넓은 평탄 바닥과 외곽 반복 바위 대신 중단된 석질 언덕과 낮은 둥근 흙 둔덕을 사용하면 관리 통로와 묘역 사이 공간이 읽히는지 확인한다. 봉분에 새 인물/죽음/복원 상태를 부여하지 않는다. TLT의 자유 카메라와 회피는 참고작과 다르므로 실제 플레이 수용은 별도다.

## 제작표와 최소 실험

| 서사/목적 | 제작 | 보존/위험 |
| --- | --- | --- |
| Lumi의 좁은 관리 접근로 | 외곽 Slate 바탕·Ground 표피의 끊긴 둥근 언덕 | 기존 통행·확장 사건·지역 연결을 전체 반경+8stud로 예약 |
| 관리길 주변 큰 평지 | 최대3개 높이12stud의 흙 둔덕 | 스폰/전투/목표 예약 밖만 배치, 묘역 접지/군집 수 재검사 |
| 기존 미술 언어 | NewNativeTerrain, 기존 Slate/Ground 재질 | TD 원본/메시/텍스처 변경0, Blender 사용 없음 |

대안: 전 구역 재굴착은 기존 바닥·서버 높이 계약과 접지 자산에 영향이 커 보류한다. 이번 추가형 대표 지형은 최대11곳/22회 쓰기/추가 BasePart0. 모든 구역의 지형 생성 뒤 carve·소품 접지·경로 후처리를 그대로 거친다. 전체 성능 개선을 주장하지 않는다.

수용: 실제 최종 지형이 외곽/내부 양쪽 존재하고 연속 지면·노출 석질/흙 재질을 갖는지 검사한다. 기존/Easy HG 경로의 차단/바닥/보정/안내/단차0, 묘역 최소3군집·각3무덤, 동일 카메라 전후를 확인한다. 게시/실기기/다인/스트리밍/전투 카메라·사용자 미술 수용은 후속 QA 담당이다. 기존 퀘스트·보상·저장·TD 운영 계약 충돌 없음. [검증](../evidence/hg03-passage-banks-20261115/README.md).
