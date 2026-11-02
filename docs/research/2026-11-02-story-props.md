# TLT-031/057/061/062/063/084 · 스토리 소품 개선

2026-11-02 확인. 사용자: 막대·구체 중심의 무의미한 스토리 오브젝트를 실제 용도와 이야기 맥락이 보이는 3D 모델로 교체.

관찰: Roblox [Environmental art curriculum](https://create.roblox.com/docs/tutorials/curriculums/environmental-art)은 환경이 플레이 요구를 지원하면서 세계의 맥락을 전달한다고 설명한다. [모듈 환경 제작](https://create.roblox.com/docs/tutorials/use-case-tutorials/modeling/assemble-modular-environments)은 일관된 피벗과 재사용 가능한 부품 조합을 제시한다. Rare의 [A World in Motion](https://www.seaofthieves.com/news/archive/inn-side-story-7)은 미술 요소를 함께 구성해 살아 있는 세계를 만드는 제작 사례다. 해당 자료는 본 게임의 실기기 성능/사용자 수용 증거가 아니다.

적용 해석: 목표 이름만 달린 구체를 제거하고 플레이어가 형태만 보고 보급대·구조 감옥·귀환길·포탈 봉인·드워프 냉각 장치를 구별하도록 한다. TD 숲 환경 메시/팔레트는 유지하고 그 안에 없는 서사 전용 물건을 신규 제작한다. 원본 TD 데이터는 수정하지 않는다. 과한 사진 실사 대신 기존 TD 영웅과 어울리는 재료/조립 구조를 갖춘 양식화 모델을 사용한다.

최소 실험: 동일 기하 원본에서 native Roblox 모델과 Blender 검토용 GLB를 만든다. 스토리 위치/프롬프트/서버 진행/보상/기존 충돌은 유지한다. 장부는 책상·책등·페이지·잉크, 레버는 드럼·래칫·케이블, 밸브는 배관·플랜지·압력계, 랜턴은 유리·철제 프레임으로 구분한다. 정적 장식에는 물리/접촉/쿼리를 꺼 두고 원자적 스트리밍 모델 단위로 묶는다.

위험/수용: 부품 수 증가를 모델별/전체 배치별 계측하고 충돌과 진행 불변을 엔진 검사한다. [Roblox 최적화 지침](https://create.roblox.com/docs/tutorials/curriculums/environmental-art/optimize-your-experience)에 따라 미세 부품 그림자를 줄인다. 실제 모바일·4인+AI FPS와 최종 미술 수용은 후속이며 Studio 결과로 대체하지 않는다. 현재 구현된 3에픽에만 배치하고 Gloamwood/Haunted Graveyard 완성을 선언하지 않는다.
