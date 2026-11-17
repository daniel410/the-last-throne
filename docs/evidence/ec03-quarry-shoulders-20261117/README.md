# TLT-063 · EC-03 광산 외곽 기저 연결

2026-11-17 UTC / Toronto11-16. [서사 제작표·공식3게임 비교·대안](../../research/2026-11-17-ec03-quarry-shoulders.md). 별도 sparse 작업트리에서 리서치·맵 구현·환경 아트·환경 모델링을 순차 수행했다. 사용자 미커밋 자산과 기존 Studio는 보존했다.

## 결과·변경

최종 **0.111.30 / 737d79560e5f15fecfbd4c6ce88ed1ab556baa51**. [빌드 입력·해시](build.json). CalderaMineLandforms v2 / EpicWorldArt v31. 기존 동쪽 능선2곳 각각에 매립된 현무암 구88/54를 겹쳐 하부 폭을 늘리고 능선 사이 빈틈을 줄였다. 원래의96stud 전체 예약 범위 안이며 전체 Terrain 쓰기6→10, 추가 BasePart/메시/광원/입자/반복루프0. 스토리 장애물·진행·보상·저장·TD 운영/원본 자산은 변경하지 않았다.

0.111.29 / 8b22732b는 내부에 낮은 지형1곳을 놓았던 **기각 후보**다. 동선은 통과했지만 경사 배치 검사 때문에 광산 피벗이(380.5,142,-12485.9004)로 바뀌고 암반 외곽이 분리되어 보였다. [후보 전](candidate-029-before.jpg) / [후보 후](candidate-029-after.jpg), [검증](candidate-029-results.json), [빌드](candidate-029-build.json), [재현 코드](candidate-029-verify.luau)를 보존했다. 최종에는 내부 지형과 강화 예약 코드를 모두 제거했다. 기각 후보를 수용 결과로 집계하지 않는다.

## 검증 조건·결과

최종 고정 XML의 Script/LocalScript Disabled만 true로 바꾼 `/tmp/tlt-ec03-apron-final.rbxlx`, 별도 로컬 Studio/Edit/PlaceId0/플레이어0. [verify.luau](verify.luau)는 두 변경 모듈 Source 일치를 확인한 뒤 CampaignWorld.create(4)로 실제 지형·배치·충돌을 생성한다. 최종 장면에 Source를 주입하지 않았다. [results.json](results.json).

- Shared/Server/Client LuaSourceContainer530개 구문 통과.
- 실제 능선2곳 중심 높이87.88/71.66stud와 Basalt 유지. 중심에서70stud 떨어진4방향, 총8개 기저 샘플에서 연속 현무암 확인. 마커2개 외 부품/스크립트0.
- 중심+70stud의 상부 높이8개는 이전과 같았다. 이것만으로 신규 기저를 판정하지 않고 실제 voxel을 추가 측정했다. [동일 범위 전후 voxel/층별 부피](voxels.json), [측정 코드](measure-voxels.luau): 기존 외곽2곳의 기저 고체 부피가 각각2,346,575.5 / 1,869,510.25stud³ 증가했다. 기존 상부 실루엣 아래를 채우는 변경이며 기기 메모리 비용은 미측정이다.
- 0.111.28 기준 장면과 최종 장면의 광산56파트: 정렬한 월드 CFrame·Size·CanCollide·CanQuery·Transparency와 모델 피벗이 정확히 같다. 구조 지지대13개도 고정/비충돌 유지. 피벗(437.894592,141.959488,-12517.9668).
- EC11스토리/9연결: 기존144목표8,396표본 + Easy150목표8,526표본. 차단·바닥 누락·서버 보정·안내 실패·작은 단차 모두0. [EC 범위 재현 sweep](navigation.luau). 실제 Humanoid 이동/사용자 입력은 아니다.

## 전후 화면·한계

[이전0.111.28](before.jpg) / [최종0.111.30](after.jpg). 별도 fresh Edit 장면, 동일 기본 주간 조명·카메라(640,189,-12595)→(797,166,-12480), Focus 고정 후 다른 검사 호출을 사이에 두고 override 없는 screen_capture로 촬영했다. 즉시 임시 카메라 캡처에 따른 Terrain LOD 지연을 피했지만 엔진 렌더 스케줄러의 완료를 직접 측정한 것은 아니다. 카메라의 현재 프레임은 능선 기저 접합부를 검토하기 위한 Edit 시점이며 실제 영웅 시점이 아니다.

화면에서 두 능선 하부 사이 하늘이 보이던 큰 틈이 줄었다. 둥근 대형 능선·각진 Terrain 음영·외곽 공간과 어두운 광산 가독성은 여전히 개선 대상이다. 전체 광산/최고 품질 완성 또는 TLT-063/G5 완료로 판정하지 않는다.

Roblox 게시·릴리스 태그 없음. 다음 QA/ART: 실제 영웅 카메라와 구조 전투/회피·PC/터치/패드·게시 클라이언트/스트리밍·1~4인+AI 성능·사용자 미술 수용. 다음 제작은 같은 암반/소품 증량을 반복하기보다 실제 게임 화면에서 구조 목표와 주변 큰 공간의 관계를 평가한다.
