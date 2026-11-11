# 이야기 NPC의 떠 있는 얼굴 수정

2026-11-11 · TLT-050/070/084 · ENG · 로컬 수정·엔진 검증 완료, 게시·실기기·사용자 수용 미검증.

사용자 스크린샷의 얼굴들은 이야기 완료 후 표시할 귀환 NPC다. 실행 중인 0.102.0 Studio Client를 읽기 전용 검사하여 HomecomingReunion 5명과 SideStoryHomecomings 6명의 몸 Transparency=1, FaceDecal=0(Lumi는0.12)인 상태를 확인했다. [수정 전 실제 값](before.json). Roblox의 얼굴/머리카락 Decal 표시를 신체 Part의 투명도만으로 차단하지 못한 결함이다.

## 변경과 근거

- LobbyResidents/CampaignReturnScenes의 서버 생성 기본값에 Decal/Texture의 원래 투명도를 저장하고 처음부터 숨긴다. 첫 스냅샷 전에도 얼굴이 노출되지 않도록 한다.
- CampaignIncidentScenes의 지역별 개인 이야기 장면에도 동일한 표면 저장/숨김을 적용한다.
- CampaignExpansionPresentation이 확정 저널에 따라 Part와 Decal/Texture를 함께 숨기고 원래 투명도로 복원한다. 뒤늦게 도착한 표면에도 현재 영웅 상태를 적용한다.
- 일반 주민·모델 디자인·서버 퀘스트 자격·보상·저장 계약은 유지한다.

## 검증

고정 빌드 **0.102.1**, 입력 소스 `8c43ea7e321d5e8ac080c0db346fae42991f7909`. [빌드 기록](build.json). 산출물 `builds/0.102.1/TheLastThrone-0.102.1.rbxlx`, SHA256 `91ef95b676c6a5e27eb5e55ed26dd435c4cec578f9524ae7b6ee4162fae8f5a6`.

- `run-in-roblox --place builds/0.102.1/TheLastThrone-0.102.1.rbxlx --script tests/npc-scene-visibility-native.luau`: **12,084검사 통과**. 격리 Studio 엔진에서 실제 로비 주민17명, 귀환 장면4개와 지역 NPC 장면을 생성했다. 서버 기본 숨김·스냅샷 없음·완료/미완료 영웅 전환·훈련 상태·장면 재유입·늦은 Decal/Texture 유입·정상 Nia 보존·Lumi의 원래 반투명 얼굴 복원을 검사했다. [원문](native.log).
- 첫 검사에서 엔진의0.12 저장값이 `0.1199999973`인 부동소수점 차이로 테스트가 실패했다. 테스트의 소수 상수 비교를 오차0.00001로 수정한 후 위 고정 산출물에서 전체 재실행했다. 게임 소스 변경/재빌드 없이 테스트만 보정했다.
- `python3 tests/single-build.spec.py --artifact builds/0.102.1/TheLastThrone-0.102.1.rbxlx`: 역할10·도착192·프로젝트 연결/실제 산출물 검사 통과.

기존 실행 중인0.102.0 Studio·클라우드 편집 Place는 수정하지 않았다. 새 빌드를 열고 Play해야 수정이 보인다. Roblox 게시/릴리스 태그는 만들지 않았다. 화면 렌더의 전후 시각 비교·게시 클라이언트·실기기·사용자 수용은 미검증이며 상위 티켓/게이트 전체 완료로 처리하지 않는다. 다음 담당은 QA/사용자의 새 빌드 화면 확인이다.
