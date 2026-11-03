# MR-01 주술사 3종 독립 팔·지팡이 리깅 후보

2026-11-03 · TLT-005/032/033/055/057/084 / MR-01 · ART/ENG 자체 제작·검증. **로컬 후보3종 제작, 게임 연결/최종 수용 미완료**.

[전후 비교 갤러리](index.html) · [후보 manifest](../../../assets/animations/regional-casters-v1/manifest.json) · [조사·적용 판단](../../research/2026-11-03-regional-caster-rigging.md).

## 변경과 원천

QueenIceElf·VolcanoShaman·KingVolcanoShaman의 팔을 몸통 축에 고정하던 기존 리그를 교체하기 위한 새 스키닝 원본을 만들었다. 종별 TD 분할 전 원본GLB를 현재 원본 SHA256와 대조해 `inputs/`에 보존했다. 기존 TD/RPG 메시·텍스처ID·런타임 소스·Place는 변경하지 않았다.

- 모델당 `Root → Torso → UpperR/ForearmR/HandR → Staff`, 반대 팔 `UpperL/ForearmL/HandL`의9뼈다. 상완·팔꿈치·손목이 독립 회전하며 지팡이 머리·자루·장식을 별도 Staff 메시의 한 가중치 소유자로 모았다.
- 분할 전 연속 표면을 사용해 어깨/팔꿈치에 기존 강체 캡이 벌어지는 문제를 피한다. 융합된 지팡이–옷 접점은 삼각형을 평면 교차로 잘라 표면적·UV를 보존하고 경계를 닫았다. 손과 지팡이의 공유 접합만 같은 손목 행렬을 따른다.
- 원본 컬러 텍스처의 내장 JPEG 바이트가 입력→분리→리깅 GLB에서 동일함을 확인했다. 새 컬러 그림을 생성하지 않았다. 원본 normal/roughness 지도는 파생본에서 연결하지 않았으며, 기존 런타임 컬러 중심 외형을 기준으로 검토했다.
- `Idle/Walk/Attack/AttackAlt/Heavy/HeavyAlt/Stunned/Exposed/Return/Interrupted`10클립이다. 공격 준비40%·접촉62%·회수78%와0/100% 복귀 표본을 제공한다. 보행은 상체 동작 후보이며 독립 다리/경사IK를 추가한 것이 아니다. Return/Interrupted는 기본 공격 준비 자세에서 시작하는 후보로, 임의 공격/시점의 부드러운 중단은 런타임 블렌딩 후속이다.

| 종 | 원본 삼각형 | 파생 최종 삼각형 | 공유 손 접합 표본 | 최대 접합 차이(정규화 높이1) |
| --- | ---: | ---: | ---: | ---: |
| QueenIceElf | 3,140 | 4,864 | 135 | 0.00000190 |
| VolcanoShaman | 3,194 | 4,472 | 53 | 0.000000194 |
| KingVolcanoShaman | 3,178 | 4,403 | 27 | 0.000000112 |

추가 삼각형은 정확한 분리 경계·접합 캡의 비용이다. 절단 전 원래 표면적 오차는3종 모두0(부동소수점 계산 기준)이며 최종 캡 면적과 구분한다. LOD/기기 성능을 통과한 예산으로 보고하지 않는다.

## 실패를 먼저 수정한 이력

초기 면 중심 분리는 로브의 큰 삼각형을 무기에 가져와 옷이 끌렸다. 정확한 삼각형 절단으로 수정했고 QueenIceElf의 기울어진 지팡이 축과 두 화산 종의 축을 따로 계측했다. 첫 내보내기는 라이브 Blender의 다른 영웅 Action까지 포함했으나, 전용 NLA 트랙으로 내보내도록 수정해 최종 GLB에는 종별 의도한10클립만 남겼다. 최종 [Blender 로그](authoring.log)에 잘못된 메시 경고나 다른 리그 Action 누락 경고는 없다.

첫 Roblox Bone 비교는 glTF의 작은 scale 반올림을 강체 CFrame에 그대로 넣어 회전 비교에서 실패했다([실패 로그](bones-first.log),646검사 시점). CFrame 입력 기저를 직교 정규화해 스케일과 강체 변환을 구분했고 수정 후1,902검사 통과했다. 모델/기대 자세를 임의 변경해 검사만 통과시키지 않았다.

## 검증과 재현

1. `python3 tools/prepare-regional-caster-meshes.py`: 입력 해시·원본 좌표 정규화·분리 전후 표면적,3종 통과. [분리 데이터](../../../assets/animations/regional-casters-v1/partition.json).
2. `tools/author-regional-casters-blender.py`를 Blender MCP에서 실행:3종×10클립·후보120PNG 생성. GLB와 재현 스크립트가 편집 원본 패키지다. 다른 사용자 씬을 포함하는 `.blend`를 저장하지 않았다.
3. `python3 tests/regional-caster-rigs.spec.py --output /tmp/mr01-results.json --native-fixture /tmp/mr01-bones.json`: **41,774 PASS**. 내보낸 GLB를 Blender와 별개로 읽어 계층·두 메시/10클립·가중치·독립 팔꿈치/손목·30/60/144개의 정규화 위상 간격에서 손 접합/무기 길이/발 고정을 검사했다. 이 숫자는 실제 기기의 FPS 측정이 아니다. [결과/GLB 해시](results.json).
4. `python3 tools/assemble-regional-caster-bone-suite.py --output /tmp/tlt-mr01-bones.luau`, `run-in-roblox --place builds/0.62.7/TheLastThrone-Battle-0.62.7.rbxlx --script /tmp/tlt-mr01-bones.luau`: **실제 Roblox Bone 계층1,902 PASS**. 후보 GLB에서 추출한90키자세를 임시 MeshPart 아래 실제 Bone에 적용해 위치·회전·손목/Staff 공통 변환·루트 불변을 검사했다. **MeshPart에 후보 메시를 로드하지 않았으므로 실제 스킨 변형/가져오기 검증은 아니다.** [엔진 결과](bones-results.json) · [원시 로그](bones-native.log).
5. `tools/render-regional-caster-baseline-blender.py`에0.62.7 `after.json`의 해당 종 캡처와 원래 분할GLB를 전달해 기준72PNG를 재현했다. 후보와 같은 정면/측면 카메라 비율에 맞추고 native 기준 방향을 보정했다. 전체192PNG·전후6비교판. `tools/assemble-regional-caster-review.py`는 Pillow가 있는 번들 Python으로 실행한다.

기존0.62.7 Battle 산출물의 SHA256는 `810bceb3d7e952886eaaa70377ffa3982406505cd20ea6487fdeaf2d321097ad`, 소스는 `bcc5e0492c0f866245a4dc8641cd9813f0654f49`다. 새 게임 빌드를 하지 않았으며 VERSION·게시·태그를 갱신하지 않았다. 저장/보상/피해/AI 경로는 이번 변경에 포함하지 않는다. 임시 Studio 실행은 종료코드0과 프로세스 종료를 확인했고 기존 TD Studio는 보존했다. Blender는 원래 활성 씬을 복원했다.

## 남은 수용과 다음 담당

MR-01은 **In Progress**다. 소매/등 망토의 가까운 변형, 분리 캡의 색/외형, 무기/몸체 관통과 최종 미술 판단은 보류한다. 실제 후보 가져오기·생성된 Mesh/Image/Skin 자산의 소유/비공개/Experience 권한·현재 적 모션의 Bone 구동 어댑터·서버 접촉 시점/스턴/노출/임의 시점 취소·무기 끝 소켓·스트리밍을 연결한 뒤 실제 로컬 메시 리그 검증을 해야 한다. 현재 실게임의3종 팔 고정은 그대로다.

다음 ART/ENG는 위3종 후보를 종별로 검토·가져오기하고 기존 모델과 전환 가능한 어댑터를 연결한다. 그때 새 게임 빌드 버전을 사용한다. 독립 QA는 실제 메시의4공격/중단/복귀·경사·게시 클라이언트·모바일/게임패드·4인+AI1을 검증한다. 업로드·게임 연결·최종 미술 수용을 완료로 기록하지 않는다.
