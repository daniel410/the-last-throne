# 전체 몬스터 본체·파트 소실 검사

작업: TLT-032/033/057/084 후속 · 2026-11-16 America/Toronto(UTC 11-17) · ENG → QA · 전 종 로컬 엔진 검사 완료.

사용자 요청 “다른 몬스터도 다확인해봐”에 따라 [Sovereign 본체 소실 수정](../hollowbark-visibility-20261117/README.md)을 포함한 기존0.111.33 빌드에서 전체 몬스터를 검사했다. **추가 본체·팔다리·무기·장식 분리 결함은 발견하지 않았다.** 런타임 소스·원본 자산·VERSION을 변경하지 않았고 새 빌드·게시·태그도 만들지 않았다.

## 범위와 수용 기준

`EnemyPatterns.profiles`의50종을 정렬해 전수 생성한다. 캠페인의 직접 적 정의가 이 목록에 포함되는지도 확인한다. 각 종류의 `StoryMonsterSizing` 기본값에0.6/1/1.4배를 적용한150개와 SlimeSplit 크기 규칙0.5를 적용한 SmallSlime3개, 합계153개를 생성한다. SmallSlime은 Slime의 동일 EnemyKind·리그/자산을 쓰는 별도 크기 변형이다. 실제 전투 서비스의 분열 이벤트 발생 자체를 검사한 것은 아니다.

| 지역 | 종류 수 | 결과 |
| --- | ---: | --- |
| Deepwood | 10 | PASS |
| Gloamwood | 9 | PASS |
| Frozen Vale | 10 | PASS |
| Ember Caldera | 10 | PASS |
| Haunted Graveyard | 11 | PASS |

파트의 투명도·메시/크기·스킨 플래그, 표시 파트의 비충돌/질량, WeldConstraint 또는 JointInstance 연결을 확인한다. RegionalCaster3종(QueenIceElf·VolcanoShaman·KingVolcanoShaman)의 Body/Staff는 원본 Motor6D 연결을 보존한다. 이 구조에 중복 용접을 추가하지 않는다.

실제 엔진 중력 아래0.75초 이상 둔 뒤 모든 표시 파트가 게임플레이 루트의 연결 assembly에 있고 상대 위치/각도가 유지되는지 확인한다. 루트를 이동·회전하고0.5초 후 다시 확인한다. 원본146개 공격을 각3크기에서, 분열체의 Slime공격까지 합쳐444회 표본으로 재생하며 준비·접촉·회수 단계마다 실제 관절 평가 후 파트 생존·유한 좌표·접합부를 검사한다. 클라이언트 표현이 서버 루트·HP를 변경하지 않는지도 확인한다.

## 결과·재현

```text
run-in-roblox --place builds/0.111.33/TheLastThrone-0.111.33.rbxlx --script tests/monster-visual-attachment-native.luau
```

- **23,759검사 PASS**, 실패0. 153개 모델에서 중력 후 최대 이탈0stud, 이동·회전 후 최대 위치 오차0.000386stud, 공격 재생 후 접합부 최대 위치 오차0.000336stud. 허용 위치 오차0.002stud·각도0.003rad 이내다.
- 모든 모델에 실제 MeshPart가 있고 표시 투명도/LocalTransparencyModifier가1 미만이며, 스킨 메시의 HasSkinnedMesh가 유지된다. 전체 rig의 Atomic streaming 설정을 확인했다.
- 로컬 Studio의 실제 MeshPart 인스턴스를 `ContentProvider:PreloadAsync`에 전달했다. 검사 모델이 참조한 **고유 자산218개 모두 Success**였다. 같은 메시를 공유하는 원본 모델까지 선택되어174개 MeshPart에서 총223개 콜백이 나왔으며 추가5개도 Success다. 이 결과는 PlaceId/UniverseId0의 현재 Studio 계정에서 얻은 결과다. 자산ID 문자열만으로 로딩하는 방식은 메시 타입 정보를 보존하지 않아 최종 판정에 사용하지 않는다.
- [원본 엔진 로그](native.log) · [로딩 콜백·요구 자산 목록](assets.json) · [50종 목록·요약·입력 해시](results.json).

검사 빌드: `0.111.33`, 입력 소스 `35f903d576eb6cdfd6591edb3e9d0527d65ed588`, SHA-256 `d2d8696dcecdc865a9f2bdc54c67fab6148d22aee1ec034f3fe7dbfb83b0111e`. 검사에 사용한 생성/외형/크기/모션 등10개 모듈이 해당 산출물과 현재 소스에서 일치함을 확인했다. 새 검사는 산출물 외부의 스크립트이며 별도 SHA-256을 기록했다. 계정·전투·원정 시작 스크립트는 격리 실행에서 비활성화하고 실제 사용자 저장·TD 운영 데이터는 건드리지 않았다.

## 미검증·다음 담당

이 결과는 파트 연결·엔진 물리·표현 모션과 Studio 자산 로딩의 전수 검사다. 게시 Experience 권한·게시 클라이언트의 실제 화면 렌더·스트리밍 이탈/재진입·전투 서비스 분열/사망/재생성 이벤트·모바일·1~4인 성능·사용자 미술 수용은 미검증이다. 부모 티켓이나 G5/G7 상태를 완료로 바꾸지 않는다.

다음 담당 QA/사용자는 게시 빌드에서 지역별 실제 전투와 재접속/스트리밍, 특히 GW-06의 Sovereign 본체 표시를 확인한다. 본 작업의 변경 파일은 검사와 이 증거, 현재 상태 링크뿐이며 기존 미커밋 자산과 다른 작업의 빌드 기록은 보존·제외했다.
