# 에픽 환경 재구성 리서치

2026-11-03 확인 · TLT-031/057/061/062/063/064/065/084. 관찰/적용/수용을 구분한다.

- Roblox [Terrain API](https://create.roblox.com/docs/reference/engine/classes/Terrain): FillCylinder/FillBlock 등 voxel 조형 API를 확인했다. 기존 발판을 전부 덮는 대신 선택 구간을 조형하고 보호 영역의 Terrain을 비운다.4stud voxel 경계 때문에 여유6stud와 수직8stud clearance를 실험/엔진 검증했다.
- Roblox [Atmosphere](https://create.roblox.com/docs/environment/atmosphere): 환경 밀도·색·haze를 지역별 시야/거리감에 적용하고 거점/훈련 퇴장 시 복원한다. 어두운 두 맵도 근거리 식별을 위해 Ambient/Exposure를 조정했다. 화면 확인과 실기기 수용은 별개다.
- Sucker Punch [Crafting the world of Tsushima](https://blog.playstation.com/2020/07/09/crafting-the-world-of-tsushima/): 자연과 인공 구조물의 배치, 지역별 자연 정체성/식생 구성 설명을 참고했다. 본 프로젝트 적용은 세 겹 수관·저층 식생·각 스테이지 고유 랜드마크와 시선축이다. 동일 제작 규모/품질을 달성했다는 의미가 아니다.

기존 [1차 조사](2026-11-03-epic-world-art.md)의 TD 재사용/스트리밍 조사와 원본 manifest를 재사용했다. TD ForestLandmark에는 잎이 없음을 실제 원본에서 확인해 ForestTree foliage_geom을 조합했다. BankVegetation/ContinuousTerrain/DeepCliff/SanctuaryTerrace/WaterfallGorge/PortalGate 원본의 material-merged 메시를 사용한다. 원본 해시와 컨셉 경로는 증거 문서에 기록한다.

비용: 장식 수/인스턴스 증가·공유 메시 렌더/스트리밍 부담. 최소 실험:5지역 실제 카메라 비교와44구역 Terrain raycast/기존 콜라이더 계약. 후속 수용: 실제 플레이/4인+AI·모바일 FPS/메모리·게시 자산 접근·사용자 미술 리뷰. 엔진 숫자 검증을 미술/성능 완료로 바꾸지 않는다.
