# 좀비·구울 공격과 움직임 개별 개선

2026-11-15 · TLT-033/064/084 · ART/ENG → QA · **두 종 로컬 개선·고정 빌드 검증 완료**, 게시/기기/사용자 미술 수용 후속.

새 TD 모델을 연결한0.110.12에서 시작해 실제 Roblox MeshPart/Motor6D의 포즈를 캡처했다. 모델·텍스처·피벗·서버 AI/피해/보상은 유지하고 두 종의 클라이언트 표본 모션만 개선했다. [범위·불변 해시](scope-check.json)와 [Diablo/WoW 참고·적용 판단](../../research/2026-11-15-undead-motion.md)을 따른다.

## 발견과 반영

| 발견 | 반영 |
| --- | --- |
| 새 Ghoul은5파트인데 팔 고정 프로필을 유지해 공격이 상체 기울기만으로 보였다 | 두 팔의 작은 교차 보행과 좌우 할퀴기, 양팔을 당기는 강공격 준비를 개별 제작했다. |
| Zombie 팔을 단순 clamp해 각도가 상한에 오래 머물고 준비/접촉 변화가 약했다 | 상한 안에서 부드럽게 당기기→뻗기→회수하는 새 곡선을 만들었다. 일반 공격은 한쪽을 앞세우고 강공격은 양팔·상체 전진을 강조한다. |
| 두 종이 같은16° 다리 표본을 사용했다 | Zombie14°의 무거운 보행, Ghoul18°의 낮고 빠른 보행으로 나누고 각 체형의 다리 축으로 stride를 다시 계산했다. 호흡3.2초/2초, 상체 흔들림·팔 반동도 분리했다. |
| 낮은 Ghoul 손이 일부 기존 강공격 준비 자세에서 평지 바닥을 약0.050stud 침범했다 | 새 후보의 과한 전방 숙임도 기각하고, 준비 때 뒤로 당긴 뒤 중립에 가까운 상체로 전진하도록 보정했다. 최종7클립×201시점의 실제 표면 검사에서 침범을 해소했다. |
| 원본 재동기화 도구가 개별 검토 모션을 다시 단순화할 수 있었다 | 개별 revision과 피벗 일치를 확인해 새 모션을 보존하도록 했다. |

Zombie 팔0.1rad/Ghoul 팔0.08rad 이내의 전체 각도 벡터를 검사한다. 크게 팔을 휘두르기 위해 원본 메시/관절을 무리하게 벌리지 않는다. 일반 공격의 좌우 변형은 몸통 회전과 앞서는 팔을 바꾸고, 강공격은 직선 준비/전진으로 구분했다. 기존 서버 접촉 위상.62·windup/active/recovery를 그대로 사용한다.

## 전후 포즈 검토

![교체 직후](before-contact.png)

![개선 후](after-contact.png)

각 행은 Zombie/Ghoul, 열은 Walk0/0.25, 일반 공격 준비0.4/접촉0.62, 강공격 준비0.4/접촉0.62다. 종별 폴더에는 보행4시점과 일반/강공격의 준비·접촉·회수 비교20장이 있다. 총40원시 포즈 렌더와 전후 비교판2장이다.

이는 **실제 엔진 행렬을 TD 원본 GLB에 적용한 Blender 재현**이다. Blender5.2 Workbench·Standard/sRGB/LookNone/Exposure0/Gamma1/CurvesOff, 같은 카메라·원본 텍스처로 검토했다. 게임 클라이언트 스크린샷·정상 입력 전투 영상으로 보고하지 않는다. 검토한 각도에서 새로 크게 벌어진 관절은 발견하지 않았지만, 강체 분할의 캡/이음새와 작은 팔 동작이라는 원본 한계는 남는다. 팔꿈치·손목·발가락 스킨 리그를 새로 만든 것은 아니다.

[교체 직후 엔진 행렬](before.json) · [최종 엔진 행렬](after.json) · [전 표면 최소 높이 전](before-surface-support.json) / [후](after-surface-support.json).

## 고정 빌드 검증

소스 `05f1a380eb10f47994f1a919a692b9ed4f571411`의 **0.110.13** 단일 빌드를 생성했다. [빌드/LFS/해시](build.json), [최종 결과](final-native.json), [전체 로그](final-native.log), [실행한 fixture](final-suite.luau).

- 정적 자산·모션 검사2개 PASS:10템플릿/11종·385표본 채널·루프·유한값·각 manifest 해시. 두 종 이외9개 모션 프로필·공유 runtime·서버 전투/패턴 파일은 변경 전과 동일하다.
- 기존 두 종 네이티브59,911검사 PASS: 실제 모델/관절 연결,4공격의30/60/144Hz 접촉 위상, 보행 접지, root/HP 불변. 평지6stud/s 지지 발 미끄러짐은 체고 대비 Ghoul1.95%→0.49%, Zombie1.06%→1.15%다. 둘 다 기존 시험 한도3% 이내이며 모든 지표가 개선됐다고 주장하지 않는다.
- 새 네이티브135,426검사 PASS:7클립×201시점의 모든 주입 표면 정점, 팔 회전 한도, 일반/강공격의 양팔 참여·전방 도달, 스턴 중단/Idle 복귀.8방향×2속도(6/14stud/s)×3주사율(30/60/144Hz), 종별48조건에서 관절 유한성과 서버 이동 불변도 확인했다. 최저 표면 높이는 부동소수 오차 약±0.0000001stud이며 허용 오차0.002stud 이내다.
- 기존 방향/공격 시각 회귀357,341검사 PASS:1,752시전,339개 고유 방향 곡선,30/60/144Hz. 새 모션 테스트의96방향 조건과 별도 집계다.

대부분 표본 수치/행렬 검사로, 실제 플레이 수용 횟수가 아니다. 최종 로그의 `rbxassethash` 다운로드는 로컬 Place ID0에서 실패 경고를 남겼다. 메시 구조 시험과 원본 GLB 렌더가 통과해도 Roblox 이미지 다운로드·Experience 사용권한·실제 표시 성공을 증명하지 않는다. 기존 HG 전체 LichSovereign 이펙트 실패는 [앞선 교체 기록](../haunted-td-refresh-20261115/README.md)에 남아 있으며 이번 두 종 검사로 해결했다고 처리하지 않는다.

## 재현·마감·다음 담당

```sh
python3 tools/prepare-undead-motion.py
/Applications/Blender.app/Contents/MacOS/Blender -b --python /tmp/tlt-undead-author-blender.py
python3 tools/apply-undead-motion.py
python3 tests/haunted-graveyard-assets.spec.py
python3 tests/haunted-motion-assets.spec.py
python3 tools/prepare-undead-motion-test.py
run-in-roblox --place builds/0.110.13/TheLastThrone-0.110.13.rbxlx --script docs/evidence/undead-motion-review-20261115/final-suite.luau
```

Blender의70 Action/294개 수치 F-curve를 평가해 두 종14클립을 병합했다([평가 로그](blender-author.log)). 사용자 Blender 장면은 별도 headless 프로세스로 보존했다. 원본 TD 파일·Roblox 자산을 수정/업로드하지 않았다. 첫 최종 행렬 캡처는 다른 로컬 fixture로 연결돼 `Server`가 없어 중단됐다([도구 실패](capture-first-failure.log)); 지정 fixture에서 재실행해 두 종 캡처를 확인했다.

소스·LFS 자산·증거는 선별 커밋/푸시한다. 빌드 후 SHA256을 재확인했다. 다른 작업의 미커밋 파일은 보존한다. Roblox 게시·릴리스 태그는 만들지 않는다.

다음 담당 QA/ART: 게시 테스트 클라이언트에서 모델/텍스처 권한·경사/요철·실제 추적/회피·타격감·정면/후면 관절 접합·PC/터치/패드·다인 성능을 확인한다. 정상 입력·게시/실기기·사용자 자연스러움 수용은 미검증이며 부모 티켓과 출시 게이트는 닫지 않는다.
