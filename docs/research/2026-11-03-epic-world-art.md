# 다섯 에픽 월드 미술 개선 조사

2026-11-03 · TLT-031/057/061/062/063/064/065/084 · DES/ART/ENG/QA.

질문: 각 에픽을 사각 전투 플랫폼에서 컨셉을 알아볼 수 있는 장소로 바꾸면서 조작·예고·스트리밍을 유지하려면 무엇을 바꿔야 하는가. PC/터치/패드·1~4인+AI가 대상이며 이번 실측은 로컬 Studio뿐이다.

## 확인한 원천과 관찰

- [Roblox 환경 미술 최적화](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience), [성능 개선](https://create.roblox.com/docs/performance-optimization/improve), [스트리밍](https://create.roblox.com/docs/workspace/streaming): 같은 ID의 반복 사용, 적절한 그림자 제한, 스트리밍 단위와 인스턴스 비용을 설명한다. 확인일2026-11-03. 직접 모바일 플레이/특정 게임의 FPS를 측정한 자료로 해석하지 않는다.
- [Ghost of Tsushima 제작진의 세계 구성](https://blog.playstation.com/2020/07/09/crafting-the-world-of-tsushima/), [공식 입문 가이드](https://www.playstation.com/en-us/editorial/ghost-of-tsushima-beginners-guide/): 자연과 사람이 만든 질서의 대비, 세계 안의 길 안내를 설명한다. 2020년 자료·현재 접근 가능 확인2026-11-03. 비교 목적이며 인기 수치·유지율·직접 플레이를 주장하지 않는다.
- 저장소의 디자인/월드 계획, 승인5에픽 줄거리, 지역별 layout/SVG와 실제 TD 환경 원본을 읽었다. Deepwood·TD 설원/화산/묘지·Gloamwood 컨셉5장의 픽셀을 직접 비교했고 경로/현재SHA는 [리뷰 JSON](../evidence/epic-world-art-20261103/reviews.json)에 기록했다. 오래된 시나리오의 심오한 줄거리보다 최신5에픽 승인을 우선한다.

## 해석과 채택

아트 문제는 소품 개수보다 사각 실루엣·반복 형태·원경 부재·동일한 빈 바닥이다. 스토리 재배치/보상 변경 없이 기존 발판 밖의 계곡·암벽을 조성하고, 지역마다 식생/건축 실루엣과 등불·길의 대비를 부여한다. TD MeshId는 재사용하며 부적합한 잔디색 TextureID는 파생 인스턴스에서만 제거/지역 재질로 바꾼다. 원본은 보존하고 업로드하지 않는다.

채택:44구역의 지역별 랜드마크·고도 배경/지형 가장자리, 전투/목표 반경·연결길 예약, 비충돌/비쿼리 소품, 작은 Atomic 모듈, 최대900stud 원경 가시성. 클라이언트 장식 예산이 원경을340stud에서 없애던 문제도 제한된 속성으로 조정한다. 조작 가능한 바닥은 서버 Part, 외곽 smooth Terrain은 기존 footprint 위에서 잘라낸다.

보류: 전체 퀘스트 좌표/게이트 재작성, 한 번에 새 고유 메시44세트, 대량 개별 조명/입자. 기존 파티/성장/경제 결정과 충돌하지 않는다. 비용은 생성 시간·인스턴스·Terrain 메모리 증가다. 44구역 native 생성과 기존 물리/바닥 표본을 검사하며 실기기 FPS/메모리/4인 수용은 후속으로 분리한다. 아트 최종 수용은 사용자 관찰이 필요하다.
