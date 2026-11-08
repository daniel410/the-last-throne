# 드워프·나이트·엘프 Mixamo 액션 개선

2026-11-08 · TLT-005/013/014/032/033/054/055/057/084/087 · ART/ENG → QA/DES · 0.86.1 · Studio 소스 적용, 미게시

사용자가 차례로 지정한 도끼, 점프 공격, 검·방패, Standing Draw Arrow를 실제 다운로드하고 기존 런타임에 연결했다. [조사와 적용 판단](../../research/2026-11-08-mixamo-melee-and-archer.md). 부모 티켓은 실기기/최종 미술 수용 전이므로 In Progress다.

## 변경

| 대상 | 최종 동작과 보존 조건 |
| --- | --- |
| 드워프 기본기 | 기존 대각 베기의 접촉·그립을 보존하고 Mixamo 준비/회수·상체 움직임을 접합한다. 빠른 기본기에서 Euler 회전 튐을 막도록 보정량의 변화를 제한했다. |
| Overhead Smash·강타 | Downward 원본의 몸통/어깨/팔꿈치를 보정했다. 과한 상체 숙임을 줄일 때 팔의 월드 방향도 함께 보정한다. |
| Ground Slam | Standing Melee Run Jump Attack의 달리기 변위 제거, 무릎을 접는 제자리 도약·착지. R15 시각 루트 최대1.4stud, 기존 서버 접촉0.41초에 높이0. 다른 지상 강타는 별도 grounded 클립을 사용한다. |
| 드워프 파생기 | Backhand·낮은 sweep·grounded를 구분하고 기존 pulse 시각으로 재생한다. 전용 axe throw 후보를 찾지 못한 투척/회수와 Gunner는 기존 경로를 유지한다. |
| 나이트 기본3연격 | 서로 다른 팩 동작의 준비·무게 이동·회수를 접합한다. 실제 검/방패 형상의 접촉 구간·팜 소켓·끝 guard 자세를 제약으로 유지한다. |
| 나이트 스킬 | 넓은 베기·강한 내려베기·브레이싱을 구분한다. Whirlwind는 전체 시각 루트를 회전시키고, 방패 강타는 준비/회수에 bracing을 더하되 검보다 방패가 앞서는 실제 접촉 경로를 유지한다. |
| 엘프 기본기 | Standing Draw Arrow의 화살 장전→노크→시위 당김→앵커→발사. 장전 중 오른손 IK를 내리고 노크 후 복구한다. 화살은 노크 뒤에 표시하고 R15 대기 중에는 빈 활을 유지한다. 스킬 연사/다중 사격과 R6는 기존 경로를 사용한다. |
| 엘프 기본 화살통 | TD Archer의 열린 화살통·테두리·가슴끈을14개 비충돌/비쿼리 파트로 R15/R6 몸통에 연결한다. 같은 원본 화살3개를 담으며 기본 클래스 외형으로 활 해제 중에도 유지한다. R15 장전은 실제 `QuiverDrawSocket`을 IK 타깃으로 사용하고 한 화살을 화살통→오른손→노크로 이동 표시한다. 늦은 관찰·취소·사망·재장착·손상 복구와 중복 표시를 검증했다. |

피해·사거리·서버 이동·쿨다운·공속·성장·보상·저장·장비 소유권을 변경하지 않았다. 실제 게임 코드/애니메이션 자산 업로드·Place 게시·릴리스 태그는 별도다.

## 원본·재현

- `assets/animations/mixamo-dwarf-v1/`: 원본5개 측정·6클립·그립 보정·R15 기준 관절·편집 가능한 Blender 채널 Action·독립 평가.
- `assets/animations/mixamo-knight-v1/`: 실제 팩에서 선택한 파일 측정·6클립·현재 나이트 baseline·Blender Action·독립 평가.
- `assets/animations/mixamo-elf-v1/`: Standing Draw Arrow 측정·기본 장전 클립·Blender Action·독립 평가.
- 각 manifest는 원본 SHA256·설정·파일 해시를 기록한다. 원본 FBX/팩은 로컬에 보존하고 파생 결과만 저장한다. 기존 사용자 `.blend`와 삭제/미추적 파일은 보존한다.
- 모든 Blender 저작/렌더: **View Transform=Standard, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off**. AgX 색 판정이나 임의 채도 보상을 하지 않았다.

```sh
# 최초 source 측정: --profile dwarf/knight/elf, 해당 로컬 원본 디렉터리 지정
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python tools/retarget-mixamo-dwarf.py -- --source-dir <source-directory> --profile <profile>
python3 tools/export-mixamo-dwarf.py
python3 tools/export-mixamo-knight.py
python3 tools/export-mixamo-elf.py
# 세 profile 각각 실행. 기본 profile은 dwarf.
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python tools/bake-mixamo-dwarf-blender.py -- <profile>
python3 tools/refresh-mixamo-golden-fixtures.py
python3 tools/refresh-mixamo-golden-fixtures.py knight
python3 tools/prepare-mixamo-dwarf-tests.py /tmp/tlt-mixamo-combined
run-in-roblox --place /tmp/tlt-mixamo-combined/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-mixamo-combined/source-probe.luau
```

도구 이름의 dwarf는 작업 시작 시점의 이름이며 profile/통합 검사는 세 영웅을 지원한다. 그립을 다시 저작하면 `tools/calibrate-mixamo-dwarf-grip.luau`의 실제 FK 결과로 `grip-calibration.json`을 갱신하고 재내보내기/재검증한다.

## 증거와 한계

최종 원시 결과는 [native-final.log](native-final.log), 입력 해시는 [test-inputs.json](test-inputs.json), Studio 원문 일치/새 모듈 require는 [studio-source-readback.json](studio-source-readback.json)에 기록한다. 세부 검사 수·빌드 소스/해시는 최종 `results.json`과 `build.json`이 정본이다.

통합 **108,895검사 통과**. 화살통/전달179검사와 기존 활4,890검사를 포함한다. [엘프 소스 확인](studio-elf-readback.json)·[화살통 소스 확인](studio-quiver-readback.json). 원본 재사용/해시는 [화살통 manifest](../../../assets/shared/td-elf-quiver-v1/manifest.json)에 있다. SourceCount/규모 검사는 실기기 성능 검사가 아니다.

![Studio의 기본 R15와 실제 TD 활/화살 메시를 사용한 화살통 앞뒤 검토](elf-quiver-studio-front-rear.jpg)

이 사진은 실제 Studio Edit/FK의 기본 R15 검토 모델이며 사용자 아바타/최종 영웅 스킨·실제 플레이 입력/IK 솔버 수용 화면이 아니다. 검토용 임시 월드/모듈은 촬영 뒤 제거했다. Roblox 조명 검토는 Blender Standard 비교와 별도다.

드워프/나이트 각32기술×R6/R15, Blender 독립 평가, 실제 검·방패/도끼날·팜 소켓, 연격·2배 공속·취소·사망, 화살/시위·IK·스킬 pulse 순서·지연/중복 이벤트를 검사한다. 초기 파일럿의 R6 fixture/가로 베기 기대/회전 문제와 수정은 후보 로그로 남기며 최종 통과와 구분한다. Studio의 200,000바이트 소스 제한에 맞춰 클립을 분할했다.

`native-poses.json`과 PNG는 **기본 R15 관절의 접지 분기를 직접 평가한 프록시**다. PNG의 몸체/무기 박스는 최종 드워프 스킨이나 실제 Roblox 조명/Play 화면이 아니다. 실제 게임 모델의 시각 수용은 QA/DES 후속이다. 기존 Roblox203785492 자산 유형 경고는 격리 fixture에서도 관찰되며 모든 assertion 통과와 구분한다.

실제 사용자 조작·다양한 체형/갑옷·관전자·기기 성능/P95·네트워크·최종 미술 수용은 미검증이다. 원래 모듈을 기준 커밋 `3c59958749da2d4306f64c1f983dbd39f72ef9b3`로 복구하면 이전 경로로 돌아갈 수 있으며 새 클립 모듈은 참조되지 않는다.
