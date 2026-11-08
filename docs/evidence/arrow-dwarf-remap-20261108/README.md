# 엘프 직선 발사·드워프 공격 재배치

2026-11-08 · TLT-005/013/014/032/033/054/055/057/084/087 · ENG/ART → QA/DES · 0.86.2 · Studio 적용·미게시

사용자는 기본 공격에서도 화살이 앞에서 옆으로 꺾인다고 확인했다. 드워프는 이전 Overhead Smash 전체를 빠른 기본 공격으로, 새 Overhead Smash는 머리 위 회전 준비 후 공격하는 Mixamo 연속 공격으로 교체하도록 지정했다. 이전 기본기는 접촉 구간을 너무 많이 보존했으므로 이번에 R15/R6의 대각 베기 우회 경로까지 제거했다. 부모 티켓의 실기기/최종 미술 수용은 계속 남는다.

## 변경과 근거

- 엘프: 공격 승인 시 실제 캐릭터와 서버 조준을 같은 표적으로 회전시킨다. 기본 공격 동안 AutoRotate를 잠그고 종료/취소 시 원래 값을 복원한다. 반복 입력이 현재 공격 중 다음 표적으로 몸을 돌리지 않도록 했다. 장전 중 선택 표적이 기존 전방 판정각 밖으로 이동하면 잠긴 방향으로 빗나가며 옆 표적에 유도 피해를 주지 않는다. 기본 공격의 기존 사거리55·각45·단일 피해와 유효 표적 선택은 유지한다.
- 발사 시 확정한 시작점/방향/종점으로 비행하며 발사 후 캐릭터 회전/이동에 따라 방향을 재계산하지 않는다. Multi Shot의 인위적인 사인 곡선 횡변위도 제거했다. 부채꼴은 서버 종점으로 결정되고 화살마다 직선으로 이동한다.
- 드워프 기본기: `basic-overhead-baseline.json`에 동결한 0.86.1의 전체 Downward 기반 Overhead를 R15/R6 모두 재사용한다. 기존 기본기0.42초·접촉0.22초 안에 전체 준비/내려치기/회수를 맞추고 부드러운 시간 변환으로 접촉 속도 튐을 줄였다. 기존 대각 기본기를 섞지 않는다.
- Overhead Smash: 사용자 링크의 실제 `Standing Melee Combo Attack Ver. 1.fbx`를 확보했다. 60fps·원본4.667초, 파일 SHA256은 [manifest](../../../assets/animations/mixamo-dwarf-v1/manifest.json)에 기록했다. 머리 위 회전과 연속 공격의 준비/회수를1.13초에 맞췄다. 기존 단일 서버 판정0.71초에 주 타격을 맞추며 추가 피해/타수를 만들지 않았다. R6는 팔꿈치가 없어 이전 강타를 두 동작으로 재구성한다. 신규 AnimationId 업로드 없이 기존 절대 시각 관절 재생에 연결했다.
- Ground Slam, 투척/회수, 기사, 엘프 장전/화살통은 유지한다. 피해 계수·공격 주기·기술 쿨다운·성장·보상·저장을 변경하지 않았다. 표적 이탈 시 빗나가는 엘프 수정은 명시한 예외다.

[기존 조사](../../research/2026-11-08-mixamo-melee-and-archer.md)의 Diablo IV 무기/방향 가독성 원리와 Roblox 기존 소켓/접촉 원칙을 재사용했다. 이번 결함은 실제 핸들러로 원인을 확인했다. 원본은 [사용자 지정 Mixamo 카탈로그](https://www.mixamo.com/#/?genres=&page=1&query=axe+standing+melee+combo)에서 확인·다운로드했으며 원본 FBX는 로컬 보존, 파생 데이터만 Git에 저장한다.

Blender 저작/평가: **View Transform=Standard, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off**. Blender 채널 Action과 독립 평가를 다시 생성했다. 최종 스킨의 Blender 색 비교/Roblox 조명 수용 결과로 간주하지 않는다.

## 검증

[results.json](results.json)·[입력 해시](test-inputs.json)·[통합 원시 로그](native-final.log)·[엘프 원시 로그](elf-straight-native.log).

통합108,557 + 새 엘프554 = **109,111검사 통과**. 새 드워프124검사는 현재 생성 golden만 비교하지 않고 동결한 이전 Overhead의 모든 관절과 다섯 의미 시점을 R15/R6에서 비교한다. 실제 접촉·도끼날·팜 고정·연격/취소 연속성·2배 공속·사망·기사/활/화살통 회귀를 포함한다. 기본기 동작 교체에 따라 옛 대각/가로 경로 기대를 제거하고 전체 내려찍기의 넓은 궤적과 현재 load 시점을 검사한다. 기존0.42초 창의 더 넓은 전체 동작은 최대 공간 이동 한계를 조정하되 접촉 속도/곡선 경계 연속성 검사는 유지했다.

엘프554검사는 실제 `startAttack/applyArrowShot/clearAction`과 실제 `emitArrow/advanceArrows`를 최종 return만 치환한 복제 모듈로 호출한다. 표적 선택 시작 회전, 장전 중 옆으로 이동한 표적의 빗나감/피해 없음, 중복 발사 방지, 원래 AutoRotate=true/false 복구,30/60/144Hz·발사 후 이동/회전·여러 직선 종점을 검사한다. 피해 함수는 spy이며 실플레이어/RemoteEvent 수송을 검사한 결과가 아니다.

```sh
python3 tools/prepare-mixamo-dwarf-tests.py /tmp/tlt-remap-native
run-in-roblox --place /tmp/tlt-remap-native/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-remap-native/source-probe.luau
rojo build default.project.json -o /tmp/tlt-remap-full.rbxlx
run-in-roblox --place /tmp/tlt-remap-full.rbxlx --script tests/elf-straight-shot-native.luau
```

Studio의 실제 TLT Place70829337938054는 Edit 모드에서 기존 소스 서명을 검사한 뒤8개 모듈 적용·정확한 원문 읽기·새 복제 모듈 require를 확인했다. [Studio 기록](studio-source-readback.json). 사용자 진행/다른 소스는 변경하지 않았다. 기존203785492 자산 유형 경고와 assertion 결과를 구분한다.

실제 입력/모바일/패드·카메라 조작·여러 체형/최종 드워프 스킨·관전자 지연·실전 미술 수용은 미검증이다. 다음 담당 QA/DES가 실제 기본기/강타를 플레이하며 확인한다. 이전 동작으로 되돌릴 때 이 작업의 런타임/자산 변경만 역적용하고 다른 작업 파일을 보존한다.

## 고정 빌드·마감

`0.86.2` 소스 커밋은 `917741170d7666915b89f356a19905b5191646b7`다. `python3 tools/build-game.py --source 91774117 --record docs/evidence/arrow-dwarf-remap-20261108/build.json`으로 단일 빌드 `builds/0.86.2/TheLastThrone-0.86.2.rbxlx` 생성에 성공했다. SHA256은 `776d573b84c4565a26d9f422f0a5a8180419fc60f4c2b5a8820f82ec648f7c6c`다. [빌드/LFS 입력 기록](build.json).

동일 산출물을 `run-in-roblox --place builds/0.86.2/TheLastThrone-0.86.2.rbxlx --script /tmp/tlt-remap-pinned.luau`로 다시 열어14개 결과 보고·**109,111검사 전부 통과**했다. 실제 게임 모듈 치환 없이 검증했으며 private 함수 노출은 테스트 전용 복제 모듈만 사용한다. [원시 로그](pinned-native.log)·[정본 결과](pinned-results.json). 소스 커밋/LFS의 origin/main 푸시 성공을 확인했다. Roblox 게시/릴리스 태그는 수행하지 않았다.
