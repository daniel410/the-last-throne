# 기사 첫 공격 동작 후보 — 2026-10-31

Blender MCP 1.8 / Blender 5.2.0에서 기존 리그의 Knight Forehand 어깨·몸통 회전 곡선을 조정했다. 원본을 보존하고 `assets/animations/melee-blender-v1/melee-attacks-candidate-v2.blend`에 후보를 저장했다. 접촉 시각과 WeaponSocket 키는 유지했다. 후보의 Dwarf HeavyCut은 과거 5키 원본을 기반으로 하므로 현재 7키 드워프 런타임에 적용하지 않았다. 최신 드워프 원본은 `dwarf-refinement.blend`다.

Blender MCP 출력으로 추출한 raw 및 평가 샘플을 `node tools/export-melee-candidate-v2.mjs`로 변환해 기사 첫 공격만 `K0MeleeClips.luau`에 반영했다. raw는 후보 파일을 다시 연 추출이 아니라 원본 액션 복제에 동일 변환을 재적용한 결과다. 코드 변환은 두 채널 외 데이터와 접선·시각을 확인하며 서버 판정은 건드리지 않는다.

Engineer 엔진 검사 `/private/tmp/tlt-knight-candidate-v2/native.log`: 기사 무기 기하 3,204·Blender 곡선 2,544·드워프 1,642·활 4,844·마법사 17,087 통과. 생성기의 누락된 ShieldBash 두 모듈은 임시 테스트 입력에만 추가했다. 기존 203785492 에셋 유형 경고가 있어 해당 로드 성공은 입증되지 않는다. 독립 QA는 임시 복제본에서 변환 결과와 실제 파일의 바이트 일치, 샘플 변조 거부, 나머지 클립·서버 코드 보존을 확인했다. Blender 재샘플은 하지 않았다.

현재 개선은 기사 첫 공격에 한정되며 차이는 미묘하다. 실제 Player 입력·PBR/손·무기 결합·모바일·관전자·실제 미술 수용은 미검증. 드워프·엘프·마법사 추가 개선은 미완료. Roblox 업로드·게시 없음.
