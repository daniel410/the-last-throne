# 오우거 곤봉·DW-05 보스 오른손 수정

2026-11-02 · TLT-005/032/033/055/057/084 · ART/ENG → QA · 로컬 구현·미게시

사용자 요청 두 건을 수정했다. 오우거의 기존 강체 분할선이 곤봉 머리를 Body와 ArmR로 나눠 공격 시 서로 떨어졌다. DW-05의 실제 보스는 일반 Orc가 아닌 Warlord이며, 원래 오른손 무기는 소스 ArmL에 있는데 공격과 궤적은 일괄 ArmR/Left Shoulder를 사용했다. 도끼 아래쪽도 다리·몸체 분할에 섞여 있었다.

## 변경

- TD 원본과 기존 `assets/shared/td-monsters/runtime.rbxmx`는 불변이다. 별도 `DeepwoodWeaponRepairModels`에 Ogre6메시·Warlord5메시를 연결한다. [파생본·업로드ID·해시](../../../assets/shared/deepwood-weapon-repair/manifest.json), [가져오기 원시 기록](../../../assets/shared/deepwood-weapon-repair/native-import.json).
- Ogre는 원래 곤봉 머리·노출된 아래 손잡이를 별도 Weapon 메시로 모으고, 손 내부를 통과하는 짧은 나무 자루를 연결했다. 손·팔·몸체는 Weapon에 포함하지 않는다. Weapon 전체를 원래 무기 팔과 같은 앵커에 Weld한다.
- Warlord 도끼의 아래 날을 오른손 ArmL에 모으고, 실제 Right Arm/Right Shoulder가 무기 채널을 받도록 수정했다. 반대 팔은 보조 동작이다. 오른손 도끼는 아래를 향한 원형이므로 기존 공격 곡선의 pitch/roll 방향을 보정한다. 무기 끝점·궤적도 실제 메시/손을 따른다.
- 피해·서버 예고/유효/회복 시간·보상·몬스터 높이·스토리ID는 유지한다. 같은 Ogre/Warlord 종을 사용하는 다른 교전에도 같은 외형 수정이 적용된다. KingOgre와 EnragedWarlord는 별도 모델이며 이번 대상이 아니다.
- 3D 분리 전후의 기존 표면 면적 오차는 두 모델 모두0이다. Blender에서 새 절단 경계를 닫고 자루를 추가했으므로 최종 표면 면적이 원본과 같다는 뜻은 아니다. 내보내기 이후 면적0 삼각형 검사를 추가하고 최종본에서0개를 확인했다.

## 제작·검증

`python3 tools/repair-deepwood-weapons.py` → Blender MCP에서 `tools/author-deepwood-weapon-repair.py` → Studio 기본 Import/Me/Upload to Roblox → `python3 tools/build-deepwood-weapon-runtime.py`. 사용자에게 신규 메시 업로드와 로컬 연결 승인을 받은 뒤 진행했다. 첫 업로드 이후 분할면 정리로 최종 두 모델을 다시 업로드했다. 첫 기록은 `first-import.json`, 채택본은 자산 폴더의 native-import/manifest다. 기존 자산을 덮어쓰거나 삭제하지 않았다.

Blender 편집 장면과 다른 사용자 장면은 분리했다. 기존 Blender 파일은 `/tmp/tlt-user-blender-preserved-20261102.blend`에 복사 보존했다. 안전 모드가 `.blend` 라이브러리 저장을 차단하므로 해제하지 않고 재편집 가능한 GLB와 제작 스크립트를 제공한다. [Blender 준비→타격→회수](blender-attack.png), [실제 Studio 메시 타격 자세](studio-contact.png). 후자는 격리된 Edit 모드 정적 자세이며 실제 플레이 교전 영상이 아니다. Studio에 추가한 가져오기 원본·미리보기·새 템플릿은 별도 ServerStorage 폴더에 보관하고 원래 카메라를 복원했다. 기존 게임 스크립트를 덮어쓰지 않았다. 런타임 연결은 새 로컬 빌드에 들어간다.

- `python3 tests/deepwood-weapon-geometry.spec.py`:56검사, 원본 해시/분리 전후 면적/최종11메시/유한값/면적0/업로드ID/좌표 정규화 통과.
- `python3 tests/td-monster-assets.spec.py`:기존 TD 원본134검사 통과.
- 네이티브 무기 소유·오른손·강체 연결·실제 자산 로드108검사 통과.
- 종별 기존 동작9,553검사와10종·4공격·30/60/144Hz·공격 전진·궤적·정리3,122검사 통과. 최초 오른손 전환만 적용했을 때 도끼가 뒤로 움직인 실패를 보존하고 방향 보정 뒤 재검증했다.
- 최종 고정 소스·빌드·재검증은 `build.json`과 `results.json`에 기록한다. 임시 QA fixture는 제품 릴리스로 취급하지 않는다.

미검증: 게시된 Roblox 클라이언트의 새 자산 권한, 실제 플레이 전투·네트워크/스트리밍·실기기/4인+AI 성능, 사용자 최종 미술 수용. 게시·릴리스 태그는 수행하지 않는다. 상위 작업은 In Progress를 유지한다. 다음 담당 QA/ART는 새 Battle 빌드에서 Ogre와 DW-05 Warlord를 실제 교전해 손 접촉·무기 궤적을 수용한다.

고정 마감: 소스 `64bb6ef1d66305bbba105642dab5288666807529`의 `git archive`를 기준으로20개 LFS 입력OID를 검증하고 Lobby/Battle **0.60.2**를 빌드했다. 최종 Battle에서 네이티브 **12,803개**, 정적 **190개** 통과. 빌드 해시는 `build.json`, 세부 수용 한계는 `results.json`에 기록했다. 기존 미커밋 로비/지원/인벤토리/이동 작업은 소스 고정·커밋에 포함하지 않았다.
