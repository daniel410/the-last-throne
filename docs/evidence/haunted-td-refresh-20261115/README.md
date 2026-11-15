# Haunted Graveyard TD 좀비·구울 동기화

2026-11-15 · TLT-032/033/064/084 · ART/ENG · 소스 교체·로컬 엔진 검증 완료, 게시/미술 수용 후속.

사용자가 업데이트한 TD Zombie/Ghoul을 Haunted Graveyard의 기존 `zombie`/`ghoul` 템플릿에 교체했다. TD 프로젝트가 실제 참조하는 `assets/models/zombie-ghoul-refresh-20261115/runtime-v2.rbxmx`에서 두 Model만 추출했다. 원본 전체 SHA256은 `f9b388b08b5654593dd71ed19a47d46b0c364a3fd72305a54fee403fdad4b31f`다. 모델별 TD 커밋·원본 경로·메시/텍스처 ID·geometry 해시는 [채택 manifest](../../../assets/shared/td-haunted-graveyard/manifest.json)에 고정했다. TD 파일은 변경하지 않았다.

새 Ghoul은 기존 Body 한 개에서 Body/ArmL/ArmR/LegL/LegR 다섯 파트로 바뀐다. 두 종의 관절 축을 새 geometry 기준으로 교체하고, Ghoul의 접지를 독립 다리 기준으로 전환했다. Zombie의 기존 보행 표본을 Ghoul 다리에 연결하고 각 체형에 맞게 stride를 계산했다. Zombie 팔은 TD가 기록한 0.1rad 범위로 제한했다. Ghoul은 기존 팔 고정·몸통 공격을 유지한다. 새 Blender 평가나 독립 팔 공격 완성을 주장하지 않는다. 서버 공격 시각·피해·보상·콘텐츠ID는 유지한다.

## 검증

- `python3 tools/refresh-haunted-td-models.py`: 원본 해시 고정, 두 모델만 갱신하고 모션 모듈 재생성. 새 Roblox 업로드 없음.
- `python3 tests/haunted-graveyard-assets.spec.py`: 10템플릿/11종·메시 ID·스크립트 부재·runtime 해시 PASS.
- `python3 tests/haunted-motion-assets.spec.py`: 385표본 채널·루프·유한값·새 파트/리그·해시 PASS.
- [자산 비교](asset-check.json): 교체한 두 모델은 TD Model과 동일하며 다른8템플릿은 교체 전과 동일하다. XML 공백만 정규화해 비교했다.
- [후보 엔진](candidate-native.json)과 [고정 빌드 엔진](final-native.json): 두 종 68,353검사 PASS. 대부분 표본 수치 검사이며 플레이 수용 횟수가 아니다. 실제 MeshPart/Motor6D 연결, 보행, 정지/스턴 접지, 4공격의 30/60/144Hz 접촉 시각, 서버 root/HP 불변을 확인했다. 평지 6stud/s 지지 발 미끄러짐은 체고 대비 Zombie 약1.06%, Ghoul 약1.95%로 기존 시험 기준3% 이내다.
- 전체 HG 검사는 LichSovereign의 `weapon/focus accent appears only at server-aligned contact`에서 실패했다([교체본](full-native.log)). 구 HG 자산·리그·모션을 분리한 기준 fixture에서도 같은 항목이 실패했다([기준본](baseline-native.log)). 전체 HG 회귀 PASS로 기록하지 않는다. 최초 기준 fixture는 Rojo 경로와 하위 override를 중복해 Ghoul 파트 불일치가 났고, 소스 폴더를 분리해 재실행했다.

## 빌드·재현

소스 `6299baa9f5cccbcaab13ed8b6548864a90d5f629`와 LFS 입력을 고정해 단일 빌드 **0.110.12**를 생성했다. [빌드 기록](build.json)의 산출물은 `builds/0.110.12/TheLastThrone-0.110.12.rbxlx`다. 시험 뒤 산출물 해시를 재대조했다.

```sh
run-in-roblox --place builds/0.110.12/TheLastThrone-0.110.12.rbxlx --script docs/evidence/haunted-td-refresh-20261115/final-probe.luau
```

[프로브](final-probe.luau)는 로컬 Place ID0·플레이어0에서만 동작하고 시작 스크립트를 비활성화한 뒤 실제 엔진 모델을 검사한다. 계정/저장·실제 플레이 조작·자산 다운로드 성공·표시 권한을 검증하는 시험이 아니다.

소스/LFS 커밋·푸시 완료. Roblox 게시·릴리스 태그는 만들지 않았다. 다른 작업의 미커밋 파일은 보존했다.

다음 담당 QA/ART: 게시 테스트 클라이언트에서 새 텍스처·메시 로딩/권한, HG 전투 시점의 외형·경사·회피·팔다리 접합·PC/모바일 성능과 사용자 미술 수용을 확인한다. 전체 HG 이펙트 실패는 별도 회귀 후속이다. 부모 티켓/출시 게이트는 완료로 변경하지 않는다.
