# 적 전투 패턴·3D 파생 v1

2026-11-06 · TLT-005/027/050/057/061~065/084 · 0.78.0 시험 구현.

- `pattern-manifest.json`: 실제49kind·142개 공격. `tools/author-enemy-pattern-data.py`가 같은 정의를 `src/shared/EnemyPatterns.luau`로 생성한다. 일반27종×2·보스22종×4. 런타임은 Lua 모듈을 사용한다.
- `native-model-capture.json`: 격리 Studio의 원래/개선 Gloamwood8종 및 개선 Warlord/KingOgre/Shaman/KingShaman4종, 총20개 모델 상태·385개 파트의 실제 형상/크기/CFrame/색. 원본 기준 커밋은 `manifest.json`에 고정했다.
- `model-comparison.glb`: 위 캡처 중 네 대표 체형의 전후 기하를 Blender에서 복원한 검토/편집용 파생본. 게임의 실제 기하는 `GloamwoodAppearance`/`EnemyModelDetails`에서 생성한다. GLB를 새 Roblox 메시로 업로드한 것이 아니다.
- `manifest.json`: 기존 TD5개 입력의 현재 SHA 검증, 파생 소스/산출물 SHA, 권한/검토 구분. 기존 메시·텍스처·사용 권한은 기존 채택을 유지하며 새 외부 자산이나 업로드는 없다.

Blender5.2 MCP에서 실제 native 기하를 복원해 전후 이미지를 렌더/검토했다. 연결된 사용자의 미저장 드워프 장면을 저장하거나 덮어쓰지 않고 별도 장면·GLB로 출력한 뒤 원래 장면을 복원했다. 런타임 전용 메시 최종 교체·모든 애니메이션 신규 저작·실기기·사용자 미술 수용 완료를 뜻하지 않는다. [검증·동작·후속 범위](../../../docs/evidence/enemy-patterns-20261106/README.md).
