# Soft Hide 제거·초기 광석10개 · 0.82.5

2026-11-07 · TLT-029/041/043/052/057/084 · ENG/QA → QA · 사용자 지시 구현·미게시.

사용자는 담요처럼 보이는 Soft Hide를 모두 삭제하고 초기 Iron Ore를10개로 줄이도록 지시했다. 신규 영웅당 첫 광석은24→10개, Soft Hide8개 지급은 제거했다. 물약·장착 장비·Lv5 보너스 투구와 영웅별 최초1회 권리는 유지한다. 이미 보유한 광석을10개로 잘라내거나 사용분을 다시 채우지 않는다.

## 기존 보유품 정리

- 계정 로드의 `Rules.upgrade`에서 `definitionId=='soft_hide'`인 모든 인스턴스를 제거한다. 가방/다른 영웅 가방/창고/미수령·잠금·캐릭터 귀속 모두 포함한다. 다른 아이템·장비/강화·Gold/Diamonds·보상/영수증/진행은 변경하지 않는다.
- 실제 계정 저장을 직접 일괄 조작하지 않았다. 새 소스가 적용된 서버에서 계정을 성공적으로 열 때 저장 이관이 수행된다. 미게시 로컬 구현을 현재 라이브 계정 삭제 완료로 보고하지 않는다.
- `AccountStore`는 이관 전에 저장 프로필을 검증한다. 따라서 Soft Hide의 안정ID/스택 상한 등 **읽기 호환용 폐기 정의**만 남겼다. 정의 자체를 바로 지우면 기존 계정을 Incompatible로 막을 수 있다. `retired=true`로 신규 generic grant를 거부하며 활성 아이콘 매핑은 제거했다. 혼합 TD 원본 스프라이트/역사적 희귀도 감사 자료는 훼손하지 않았다.
- 유효 프로필의 이관은 같은 계정 갱신으로 저장하고 반복 실행은 추가 변화를 만들지 않는다. 저장 실패/응답 불명·다른 서버 lease 활성 상태에서도 새0프로필/보급 재지급/다른 권리 손실을 만들지 않는다. 기존 보유품 보존 계약의 명시적 사용자 예외는 Soft Hide뿐이다.

## 검증

- [순수 검사](tests.log): 전용 정리35, 초기보급316, 인벤토리271, 재료교환183, 강화확률2869, 난이도/강화153, 경제42 — 총3869 PASS.
- 전용 검사는4클래스 각각Ore10/Soft Hide0·기본 무기 자동 착용·동일 영웅 중복 재지급 금지·폐기품 신규 grant 거부/아이콘 없음, 잠금/귀속 포함4개 위치의 기존 스택 제거, 기존광석24 보존/소모분 미충전·다른 상태 전체 동일·revision1회·이관 반복, 실제 AccountStore의 검증→이관→저장 불명/재접속·읽기 실패/다른lease 차단을 확인한다.
- 기존 인벤토리 이동/폐기 경계 검사는 명시적 과거광석24개 fixture로 유지했다. 새 보급이10개인지는 신규 보급/정리 검사에서 별도 검증한다. 사용자 기존 스택의24개가 소급 보존되는 계약도 계속 검사한다.
- `run-in-roblox --place /tmp/tlt-mana-regen-restored/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-starter-material-cleanup-native.luau`: [Luau 결과](native.json)/[로그](native.log).32개 관련 소스를 메모리에 로드해 전용/초기보급/인벤토리/교환 **805검사 PASS**. `game=nil` 격리 환경으로 실제 순수 모듈과 AccountStore를 실행했다. PlaceId0·Player0, 합성 저장 어댑터이며 live DataStore/클라이언트/화면 검사가 아니다. 기존203785492 asset type 경고가 있으며 이 검사는 자산 렌더 수용이 아니다.
- [검증 소스 해시](source-hashes.json)·`git diff --check` PASS. 지정 가격/보급·미사용 재료 정리에 한정한 사용자 지시이므로 별도 디아블로 비교 조사는 반복하지 않았다.

VERSION0.82.5와 입력 소스 `3df102cf1fad9355c33083fa1bebf4b94adf04ea`를 먼저 커밋·푸시한 뒤 `python3 tools/build-game.py --source 3df102c --record docs/evidence/starter-material-cleanup-20261107/build.json`으로 단일 빌드에 성공했다. [결과](build.json)에 소스/산출물 해시를 보존했다. `python3 tests/single-build.spec.py --artifact builds/0.82.5/TheLastThrone-0.82.5.rbxlx`: 역할10/로딩192·실제 산출물 검사 PASS. [정리/카탈로그/아이콘3모듈 Source 대조](artifact-check.json)에서 고정 소스와 바이트 일치를 확인했다. Roblox 게시/릴리스 태그 없음.

미검증: 실제 계정/클라이언트·실기기/다인·배포 후 재접속/오래된 서버 교체. 다음 QA는 기존 계정의 모든 Soft Hide 제거·다른 권리 보존과 신규/추가 영웅Ore10·이후 미재지급을 확인한다. 이전 서버의 새 지급이 남지 않도록 로비/배틀과 기존 서버 교체를 함께 확인한다. 부모 티켓은 In Progress를 유지한다. 비관련 Blender 변경·컨셉 삭제·첨부/증거 파일은 포함하지 않았다.
