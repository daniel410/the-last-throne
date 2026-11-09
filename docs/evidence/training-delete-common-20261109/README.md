# Training 무기 삭제와 Common 기본 무기

2026-11-09 · TLT-029/032/041/052/057/084 · ENG/QA · 0.89.4

사용자 지정 변경과 후속 확인에 따라 Training Sword/Axe/Bow/Staff4종을 삭제 대상으로 지정했다. 기존 AccountStore 검증→세션 잠금→upgrade/save 경로에서 잠긴 아이템과 착용/가방/창고/미수령을 전부 제거한다. 구 저장 검증용 tombstone 정의만 유지한다. 빈 무기 슬롯에 대체품/환급을 자동 지급하지 않는다. 신규 지급/구매/상자 선택 차단은 기존 retired 계약을 유지한다. 과거 보유품 보존 지침보다 이번 삭제 요청이 우선한다.

기본 지급 Tempered Sword/Axe/Bow/Staff의 등급을 Uncommon→Common으로 변경했다. 기존 보유품과 앞으로 지급할 물건 모두 현재 정의를 사용한다. ID, Lv1, 공격력+3포인트, 강화단계/원래수치3% 증가, 가격, 외형은 유지한다. 현재 활성 장비 정의는 시작 지급 전용 Dawnspire Shield를 포함해17종(Common10/Uncommon7)이다. 상점 판매16종만 세면 Common9/Uncommon7이다. 기존 Rare/Epic 삭제14종과 보존10종 계약은 유지한다. 별도 신규 기능/밸런스 제안이 아닌 직접 지시 데이터 수정이다.

검증: `tests.log`. 순수 Lua10개 검사 통과(총4,607검사): 삭제171, 시작장비202, 상점115, 고정공격90, 비교52, 인벤토리271, 재료이관35, 영웅별보급316, 은퇴장비486, 강화2869. 실제 AccountStore 어댑터에서 반복 콜백/저장 뒤 응답 유실/재접속의 삭제와 다른 재산 보존을 검증한다. 시작장비 검사의 오래된 % 기대를 기존0.89.3 포인트 계약에 맞췄다.

`diamond-weapons.spec.lua`는 이미 퇴역한 Dawnforge까지8개라고 기대하는 기존 검사에서 실패한다. 변경 전 HEAD 동일 실패를 임시 archive에서 확인했다(`baseline.log`). 이번 작업의 통과로 보고하지 않으며 관련 없는 기대 수정은 하지 않았다.

미리보기: [현재 기본 무기4종](common-starter-weapons.png). `tools/render-common-starter-weapons.py`로 기존 Standard 검토용 Blender 파일에서 실제 사용 원천 메시를 렌더했다. 검 Azure Oathblade, 도끼 Embercleaver, 활 ElfSource_Bow+시위, 지팡이 MageStaff_* 목재 원본이다. 런타임은 `WeaponAppearance`/`ElfBowGeometry`/`WoodenStaffBuilder` 참조. 무기별 현재 외형이며 Rare 이상 승인 컨셉을 새 Common으로 구현한 것이 아니다. 독립 정면 구도를 위해 회전/중심/프레이밍만 조정하고 재질/버텍스는 보존했다. 화살/캐릭터는 제외했다.

색 비교: **View Transform=Standard**, Display=sRGB, Look=None, Exposure=0, Gamma=1, Use Curves=Off. 색/데이터 텍스처의 원본 노드 설정을 보존했다. 이 중립 조명 원본 렌더는 Roblox 실제 조명 검증과 별도다. `render-settings.json`에 출처/오브젝트/설정 기록. 원본 .blend와 사용자 미커밋 자산은 변경하지 않았다.

미검증: 라이브 계정 DataStore, 게시 클라이언트/기기, 실제 색/입력/밸런스 수용. 현재 연결된 Studio 소스는 변경하지 않았으며 Roblox 게시·릴리스 태그 없음. 후속 QA는 고정 빌드로 재접속 삭제/기본무기 Common 표시와 실제 외형을 검증한다.

고정 소스 `c9653bb92f55994af672812e8c916b5ceb408c42`를 origin/main에 푸시한 뒤 단일 빌드 **0.89.4 성공**. 산출물 `builds/0.89.4/TheLastThrone-0.89.4.rbxlx`, SHA256 `c6c84796537f5c0c0c419b91fe79e8d1c9b5f6532fa5932477232711df8fafcc`. `python3 tests/single-build.spec.py --artifact builds/0.89.4/TheLastThrone-0.89.4.rbxlx`: 역할10/도착로딩192/마운트·구성 PASS. `run-in-roblox --place builds/0.89.4/TheLastThrone-0.89.4.rbxlx --script docs/evidence/training-delete-common-20261109/native.luau`: 실제 모듈 삭제171/기본장비202/고정공격90/상점115=578검사 PASS(`native.log`). 미리보기 PNG5개 LFS 전송 성공. 이미지 보드는 `swift tools/compose-common-starter-weapons.swift <증거폴더절대경로>`로 조합했다. 라이브/연결된 사용자 Studio 적용은 별도다.
