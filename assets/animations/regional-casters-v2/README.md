# MR-01 Roblox Importer 호환본 v2

[기존 리깅 후보](../regional-casters-v1/README.md)의 형상·UV·텍스처·스킨 가중치와 회전 애니메이션을 보존한 가져오기용 파생본이다. **미업로드·게임 미연결**. [실제 Importer 확인/검증](../../../docs/evidence/regional-casters-import-20261103/README.md).

Studio Importer가 v1의 scale 애니메이션 채널을 지원하지 않는다고 경고했다. 종별9뼈×10클립=90개의 상수 단위 스케일 채널을 제거했다. 모든 표본이1에서1e-5 이내인지 먼저 검사하고, 의미 있는 스케일이나 morph 애니메이션은 자동 폐기하지 않고 실패시킨다. 바이너리 청크는 그대로라 형상·텍스처·스킨 가중치 바이트가 v1과 같다. 원본 v1은 변경하지 않는다.

```bash
python3 tools/prepare-regional-caster-import.py
python3 tests/regional-caster-import.spec.py --output /tmp/tlt-mr01-import-results.json
```

`manifest.json`은 입력/출력 SHA256와 제거한 채널 수를 기록한다. Importer의 `Creator: Me`, `Rig Type: Custom`, `Keep Zero Influence Bones: ON`, `Add to Workspace: ON`, `Import as Package: OFF`로 준비했다. 실제 업로드는 별도 명시적 승인 응답 후 수행한다. 새 메시·텍스처·스킨 자산ID/권한은 아직 없으며, 실제 로컬 스킨 재생·런타임 어댑터·최종 미술 수용을 통과한 상태가 아니다.
