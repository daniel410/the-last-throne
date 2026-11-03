# Haunted Graveyard 모델별 동작 개선 근거

2026-11-03 · TLT-032/033/055/057/064/084 · ART/ENG/QA.

기존 [Deepwood 개별 동작 조사](2026-11-02-deepwood-individual-motion.md)와 [Frozen Vale/Ember Caldera 리뷰](2026-11-03-regional-monster-motion.md)의 검토 방식을 재사용했다. 2026-11-03에 공식 [Roblox Task Scheduler](https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler)와 [PlayStation 개발자 전투 분석](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/)을 다시 열람했다. 전자는 Motor6D.Transform의 PreSimulation 적용 순서, 후자는 읽을 수 있는 예고·체중에 맞는 궤적/회수를 판단하는 참고 근거다. 직접 플레이·인기 순위·우리 게임 사용자 수용의 증거로 쓰지 않는다.

관찰: 실제 TD10모델과 Veyr의11개 런타임 종류를 각각 native 행렬로 캡처하고 원본 GLB를 Blender에서 비교했다. Skeleton/Skeleton Knight는 실제 검 ArmL과 주공격 채널이 달라 방패를 들었다. Lich/Lich Sovereign의 지팡이·옷은 독립 팔 메시로 오인하면 조각이 벌어진다. Ghoul/Mummy/Death Knight/Dread Commander는 원본의 일부 또는 전신이 일체형이어서 기존 다른 종의 곡선을 복사하는 것만으로 팔다리가 생기지 않는다.

적용: 모델별7클립/11프로필을 Blender에서385 Action·1617개 수치 F-curve로 평가했다. 검 팔/끝점과 실제 어깨 축, 네발의 실제 피벗/지지 보폭, 일체형의 전신 준비/접촉/회수, 지팡이 조각 공통 앵커/시전 초점과 실제 하단 표면 표본의 접지를 채택했다. 다른 지역에서 HG 표본 테이블을 미리 모두 생성하지 않도록 모델을 처음 사용할 때 로드한다. AI·HP·피해·보상·서버 windup/접촉0.62를 보존한다.

대안인 강제 큰 팔 회전은 갑옷/로브·지팡이 이음새를 더 벌리므로 기각했다. 새 완전 스킨 리그는 독립 관절에는 유리하지만 새로운 메시/권한/성능 검증이 필요하다. 이번에는 기존 TD3D를 쓰라는 사용자 지시와 동작 리뷰 범위에서 기존 메시·텍스처ID를 보존한다. 여전히 분리되지 않은 팔/턱/꼬리/무릎과 캡의 미술 수용은 후속이다.

수용 실험: 각 모델의 전후7자세·평지6stud/s 지지 발 미끄러짐·공격/스턴/노출 시 보행 잔류 제거·4공격×30/60/144Hz·실제 검 끝 전방 이동·초점/흔적 정리·루트/HP 불변·기존3지역 회귀. 실기기/경사/게시된 클라이언트의 실제 조작·다인·사용자 자연스러움 수용은 별도로 남긴다. 다음 담당 ART는 일체형 메시의 완전 관절 리그, QA/DES는 실제 조작과 미술/기기 수용을 진행한다.
