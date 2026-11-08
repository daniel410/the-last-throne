# 드워프 공격 종료 손·손목·도끼 복귀 수정

2026-11-08 · TLT-005/013/014/032/033/054/055/057/084/087 · ENG/ART → QA/DES · 0.86.3 · Studio 적용·미게시

사용자가 기본 공격과 스킬 종료 자세의 손·손목·무기 위치가 이상하다고 보고했다. 기존 검사에서 손잡이가 팜 소켓에 붙어 있는 것은 확인했지만, 종료 자세가 자연스러운 대기 자세와 일치하는 조건이 빠져 있었다. 실제 Studio/FK에서 종료 후 과하게 굽힌 팔과 가로로 돌아간 도끼를 확인했다. 부모 티켓의 최종 미술/실기기 수용은 계속 남는다.

## 원인·수정

이전 클립은 팔42도·팔꿈치28도·손목-3도·무기-94도의 옛 guard로 끝났다. 별도 도끼 yaw-110도는 동작 종료 후에도 유지하다0.1초 뒤부터 따로 풀었다. 손/손목/소켓의 회복과 도끼 회전 복원이 서로 다른 시각에 끝났다.

- 기본기와 Overhead/Ground Slam·파생 Backhand/Sweep/Grounded의 마지막 회복 구간에서 옛 guard 보정과 그 미분을 함께 제거했다. 끝에는 기존 idle의 팔·손목·무기 소켓으로 돌아온다.
- 별도 axe yaw도 같은 회복 구간에서0으로 복귀한다. 종료 후의 guard0.1초 유지와 추가0.32초 비틀림은 제거했다. 끝 프레임과 첫 Idle 프레임이 같은 자세다.
- 기존 투척도 공격/방출 경로를 복제 보존하고 회복만 같은 계약으로 내보냈다. 실제 투사체·반환/재표시 경로는 유지한다. 고급32스킬은 기존 재생기/회복을 통해 같은 종료 자세에 도달한다. Gunner/방어 동작의 기존 idle 복귀도 함께 검사했다.
- 희소 R6 곡선에는 회복 시작의 기존 값/미분을 정확히 삽입했다. 이후 끝점 보정이 타격 구간으로 새지 않는다. [이전 소스 비교](pre-recovery.json): 기존6클립의 준비~active43,632표본에서 최대 차이0.000000436도. 서버 판정·피해·공속·쿨다운·이동·성장/저장 변경 없음.
- 기본 공격의 빠른 Downward와 오버헤드의 머리 위 회전/Combo Ver.1, Ground Slam 점프는 유지했다. 새 소스 확보/게임성 변경이 아닌 원인이 확인된 복귀 결함 수정이다. [이전 원본 조사](../../research/2026-11-08-mixamo-melee-and-archer.md)를 재사용한다.

저작 Blender Action/독립 평가를 다시 생성했다. **View Transform=Standard, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off**. 원본 FBX는 로컬 보존하며 새 업로드는 없다. [manifest/파일 해시](../../../assets/animations/mixamo-dwarf-v1/manifest.json).

## 실제 Studio 비교

동일한 기본 R15와 실제 TD 도끼 메시로 찍은 Edit/FK 사진이다. 화면 오른쪽부터 Idle, Basic end, Overhead end, Ground Slam end 순서다. 기본 리그 프록시이며 실제 최종 드워프 스킨/실플레이어 입력 화면이 아니다. 위치에 따른 카메라 원근을 감안해야 하며 정량 비교는 루트 기준 FK로 수행했다.

수정 전:

![수정 전: 공격 끝에 팔을 굽히고 도끼가 옆으로 돌아간 자세](before.jpg)

수정 후:

![수정 후: 모든 공격 끝에 팔과 손목·도끼가 idle로 복귀](after.jpg)

TLT Place70829337938054의4개 모듈을 기존 소스 서명 검사 후 적용하고 정확한 Source 읽기/새 복제 모듈 require/종료 값0을 확인했다. [Studio 기록](studio-source-readback.json). 임시 갤러리는 제거했다. 실제 Place 게시와 Roblox 조명/최종 스킨 미술 수용은 별도다.

## 검증·재현

[정본 결과](results.json)·[통합 로그](native-final.log)·[런타임 입력 해시](test-inputs.json). **15묶음·114,477검사 통과**. 이 수는 원시 로그의 JSON 검사 수와 별도 문자열로 보고하는 투척460검사를 합산했다.

새 `dwarf-recovery-native.luau`는 기본 공격+32스킬 × R6/R15 ×30/144Hz ×기본/2배 공속264경우를 실제 재생기·팜 소켓·FK로 검사한다. 종료 손/무기의 idle 대비 최대 위치 오차0.000000009stud, 회전 오차0도. 종료 직전과 마지막 프레임, 서버가 SkillId/StartedAt를 지우는 첫 Idle과0.05/0.2/0.43/0.7초 뒤까지3432검사했다. 고급스킬은 실제처럼 기본 공속 배율을 사용하지 않는다.

기존 Blender 독립 평가, 도끼날 선행/팜 고정, 연속 입력/회복 취소·2배 공속, 투척/회수/사망, 기사·엘프·화살통 회귀도 통과했다. 기본 공격의 준비/접촉/팔로스루는 이전 Overhead와 계속 비교하고 최종점만 새 idle 계약으로 바꿨다. 기존 스윙 범위/접촉 속도 검사를 유지했다. 기존 자산 유형/격리 Place의 일부 rbxassethash 로드 경고를 최종 스킨 수용으로 간주하지 않는다.

```sh
python3 tools/export-mixamo-dwarf.py
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/bake-mixamo-dwarf-blender.py
python3 tools/refresh-mixamo-golden-fixtures.py dwarf
python3 tools/prepare-mixamo-dwarf-tests.py /tmp/tlt-recovery-all
run-in-roblox --place /tmp/tlt-recovery-all/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-recovery-all/source-probe.luau
```

이전 종료 검사는 팜 고정만 만족해도 통과했으며 새 회귀 조건을 대신하지 못했다. 이번 검증도 실제 PC/터치/패드 조작·관전자/네트워크·최종 드워프 스킨/체형·사용자의 동작 수용까지 확인한 결과는 아니다. 다음 담당 QA/DES가 실제 영웅으로 확인한다. 복구가 필요하면 이 작업의 런타임/파생 데이터만 이전0.86.2로 되돌리고 다른 사용자 파일을 보존한다.

고정 빌드/동일 파일 재검사는 마감 시 아래에 기록한다. Roblox 게시/릴리스 태그는 수행하지 않는다.
