# 드워프 기본 베기·연격 손잡이 안정화

2026-11-05 · TLT-005/032/033/055/057/084 · ART/ENG → QA/DES · 0.75.4 로컬 후보

[영상 조사·적용 판단](../../research/2026-11-05-dwarf-natural-axe-swing.md)을 바탕으로 R15 기본 베기를 새 Blender Action으로 교체했다. 준비 뒤0.11~0.29초의 도끼 소켓을 고정하고 어깨·팔꿈치·제한된 손목 회전으로 타격 궤적을 만든다. R6는 기존 단일 팔 접촉 동작과 도끼 소켓을 보존하며 준비 자세만 더 일찍 들어 올린다. 두 리그의 연격/기술→기본기는 별도 -110도 yaw를 이어받아 손 안에서 갑자기 뒤집히지 않게 한다. 전환의 자세·속도·가속도를 이어받고2배 공속의 진입 속도와 Idle 해제 시간을 실제 재생률에 맞춘다.

도끼 메시·UV/PBR·장착 C0·대기 방향·공격0.42초/접촉0.22초·피해·쿨다운·판정·보상은 변경하지 않았다. 상위128개 기술 전체를 다시 저작한 작업과 구분한다. 기존 미커밋 `dwarf-refinement.blend`와 관련 미추적 산출물은 보존하고 스테이징하지 않는다.

## 원본과 재현

- `assets/animations/dwarf-natural-v2/poses.json`: 네이티브 FK로 구한 R15 관절과 준비/guard 자세.
- `dwarf-natural-v2.blend`, `clip.json`: 실제 Blender MCP로 만든 Action/F-curve와43시점 독립 평가. 원본은 관절 채널 저작용 프록시이며 완성된 드워프 스킨/시각 수용 증거가 아니다. Blender safe mode의 외부 datablock 읽기 제한을 지켜 새 채널 리그를 만들었으며 기존 Blender 파일을 덮어쓰지 않았다.
- `tools/solve-dwarf-natural-grip.luau`: 고정 손잡이의 네이티브 FK 풀이. `solve-stable-grip-native.log`의 준비 자세와 `solve-baseline-refined-native.log`의 접촉 부근 해를 `tools/prepare-dwarf-natural-poses.py`로 조합한다. 초기 후보·실패/재시도 로그를 보존했다.
- `tools/author-dwarf-natural-blender.py`: `POSE_SOURCE`에 poses.json의 데이터를 공급해 Blender MCP에서 실행. 파일 접근 우회/권한 변경은 하지 않는다. `tools/export-dwarf-natural.mjs`는 런타임 클립·R6 준비 교정·독립 golden fixture를 내보낸다.

검증용 입력 생성/실행:

```sh
node tools/prepare-dwarf-swing-review.mjs /tmp/tlt-dwarf-natural-qa tests/axe-cutting-edge-native.luau tests/k0-dwarf-motion-native.luau tests/k0-melee-curves-native.luau tests/k0-melee-blender-native.luau tests/dwarf-natural-grip-native.luau tools/capture-dwarf-cut-dive.luau
run-in-roblox --place /tmp/tlt-dwarf-natural-qa/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-dwarf-natural-qa/source-probe.luau
```

풀이에 이전 클립이 필요하면 `TLT_SWING_BASELINE=<이전 소스 커밋>`으로 fixture를 생성한다. fixture는 원본 TD 모델 해시를 확인하고 실행 코드가 없는 모델을 사용한다. 원본 모델·서버 저장/상품/Place는 변경하지 않는다.

## 검증 결과

`continuous-native.log`: 비게시/플레이어 없는 격리 fixture, 합성 서버 시각과 실제 Roblox R6/R15·무기 FK. 총8,348검사 PASS.

| 검사 | 수 | 결과 |
| --- | ---: | --- |
| 날 방향·손 소켓·전방 대각 궤적 / 기본·내려찍기·지면 강타 /30·144Hz | 156 | PASS |
| 기존 드워프3기술 선택·관절·루트·취소/연결 | 1,642 | PASS |
| 기사/드워프 기하·바닥·속도·연격 회귀 | 3,204 | PASS |
| Blender43시점 및 기존 클립의 독립 평가 | 2,664 | PASS, 최대 오차0.00003777도 |
| 전체 소켓 회전·별도 yaw 연결, 기본/3기술→기본,1·2배 공속, R6/R15·30·144Hz, 고정 소켓/손목 제한 | 682 | PASS |

초기 `candidate-native.log`의 날 옆면 정렬 실패를 고쳤다. 이후 `refined-native.log`/`final-native.log`에서 드러난 R6 준비 높이와 연격 가속도 문제를 고쳤으며 기존 기하/연속성 임계치를 완화하지 않았다. 큰 runner Source 길이는 XML 모듈 fixture로 해결했다. 두 번의 별도 Studio runner 시작 timeout은 실행 실패이며 PASS로 세지 않는다.

`native-poses.json`은 실제 관절 FK 위치/크기를 기록한 데이터이며 GPU 화면이 아니다. 열린 로컬 Studio에서 검토 모듈을 생성했지만 MCP의 Network capability 때문에 기존 렌더러 require가 거부되어 직접 화면 비교는 미완료다. 권한을 바꾸거나 Play로 우회하지 않았고 임시 모듈/폴더는 제거했다. 따라서 정상 플레이의 자연스러움·이동 중 관통/연격·게시 클라이언트·실기기·4인+AI·사용자 미술 수용은 미검증이다. QA/DES가 다음 단계에서 확인하며 부모 티켓은 In Progress다.

빌드는 VERSION과 소스 커밋을 고정한 뒤 `build.json`, 고정 소스 재검증은 `pinned-native.log`에 남긴다. 게시·릴리스 태그는 만들지 않는다.

고정 소스 `98add9b0bc20a73702c724a20199a89ecbe6ef10`의0.75.4 단일 빌드 성공. `pinned-inputs.json`의 모든 입력 해시가 커밋과 일치하며, 최종 `pinned-native.log`/`results.json`에서8,348검사 재통과했다. 열린 TheLastThrone-0.75.3 로컬 Studio의 두 모듈을 baseline과 대조한 뒤 공식 multi_edit로 갱신하고 전체 소스를 다시 읽어 고정 소스와 일치함을 확인했다(`studio-source-readback.json`). Studio 파일 저장·Play/게시 화면 수용과는 구분하며, 전체0.75.4는 `builds/0.75.4/TheLastThrone-0.75.4.rbxlx`에 있다.
