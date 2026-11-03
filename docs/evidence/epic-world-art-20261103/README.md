# 다섯 에픽 맵 컨셉 대조·실제 환경 개선

2026-11-03 · TLT-031/057/061/062/063/064/065/084 · DES/ART/ENG/QA · 0.66.0 로컬 개선본·미게시.

[실제5맵 전후 갤러리](index.html) · [맵별 문제/개선/컨셉 해시](reviews.json) · [리서치/선택](../../research/2026-11-03-epic-world-art.md).

## 변경

사용자가 거부한0.65.2 플랫폼 수준을 기준으로5개 에픽 본편35+선택9구역을 각각 테마별로 꾸몄다. 공통 EpicEnvironmentKit과 EpicWorldArt를 CampaignWorld 생성 끝에 연결한다. Deepwood 숲·거목·폭포/감시탑/폐허, Frozen Vale 삼단 설송·빙하·요새/피난처, Ember 현무암·용광로/굴뚝·상부 배관/외곽 용암, Gloamwood 짙은 수관·뿌리·거미줄·숨은 관문, Haunted 묘역·예배당·종탑·왕릉/민트 등불을 조합했다.

기존 TDMapModels의 ForestTree/ForestLandmark, 각 지역 Cliff/Landmark 메시를 복제한다. 원본 `assets/shared/td-deepwood-environment/maps.rbxmx`와 공유 레지스트리/권한은 기존 고정 입력을 따른다. 곡선 지형이 없어 보이던 큰 쐐기는 폐기했다. 기존 절벽 원형을 뒤집어 산 능선으로 배치하고, 잔디색 텍스처는 파생 소품에서만 지역 재질로 교정하며 TDOriginalTexture를 남긴다. Gloamwood 잎도 원본 geometry를 유지하고 어두운 녹색 파생 재질을 쓴다. 신규 외부 자산 업로드/TD 원본 변경은 없다.

높은 기존 발판의 옆면에 smooth Terrain 지형 가장자리·낮은 계곡 바닥을 추가했다. 지형이 퀘스트/전투/스폰과 이웃한 낮은 지역을 덮지 않도록 기존 zone/ramp footprint 위의 생성 Terrain을 비운다. 가시적 소품은 모두 anchored·비충돌·비쿼리·비터치다. 원경 최대900stud, 근거리 그림자 제한과 Atomic 모듈을 사용하며 추가 개별 PointLight/입자 루프는 만들지 않는다. 기존 장식 예산에서 원경까지340stud로 잘리던 문제를 제한된 거리 속성으로 보완했다.

서버 게이트·목표·적·보상·안정ID·스폰/전투 바닥과 기존 콜라이더 위치는 유지했다. 기존 사각 발판 자체/전투 면적을 모두 재작성한 것은 아니다. 사각 경계 일부와 넓은 평탄한 교전장은 남아 있다. GW 몬스터는 이전 지시대로 교체 가능한 임시 모델이다.

## 실제 검토/검증

Studio 로컬 후보에서 같은 카메라/중립 조명으로5개 입구 전후, 지역 조명/플레이어 높이5장, 마지막 구역5장을 실제 캡처했다. 생성 컨셉/Blender 렌더/정상 조작 플레이 영상과 구분한다. 조감도에는 원거리 발판과 직선 길이 계속 보이며 이 한계를 숨기지 않는다. UI를 새로 만든 작업이 아니다.

`tests/epic-world-art-native.luau`: smooth Terrain과 기존 Parts를 함께 Raycast하고, 원래 콜라이더/프롬프트 좌표 보존,44곳 소품 물리/쿼리·수량·원본 MeshId·지연 재생성 방지를 검사한다. [후보 결과](candidate-native.json) 86,749검사/바닥4,789표본 PASS. 생성12.91초는 이 PC의 한 번의 측정이며 프레임 시간/FPS가 아니다. site17,794parts/전체34,566descendants/메시 복제4,438개는 고유 메시 수가 아니다.

전체 Luau 컴파일과 전체 Lua suite를 [컴파일](compile.json)·[Lua 결과](lua-tests.json)에 남긴다. Lua43/44 PASS, 기존 `k0-appearance.spec.lua`의 mock GetDescendants 누락1개는 남아 있다. 최초 지형 교차 실패와 공유 조명 회귀/교정은 [실패 기록](first-native-failure.txt)에 공개한다. 최종 고정 빌드 결과는 아래에 기록했다.

## 미검증·다음 담당

실제 캐릭터의 정상 전투/스프린트·경사 카메라·실제 저장·게시 클라이언트 자산 권한·PC/터치/패드·4인+AI FPS/메모리/스트리밍·로드 시간·최종 미술/사용자 수용은 남아 있다. 부하 증가가 있어 실기기 성능 통과를 주장하지 않는다. ART/DES는 실제 시야에서 잔여 사각 경계·건물/곡선 길·고유 메시를 다듬고 QA는 실제 플레이·기기 예산을 수용해야 한다. 부모 티켓은 In Progress다. 미게시·릴리스 태그 없음. 기존 미커밋 로비/이동/애니메이션 작업은 보존·빌드 제외한다.

## 0.66.0 고정 빌드 최종 결과

입력 소스 `fa8ac0382c4af0c5d1cef28b12db62ee22712935`. `python3 tools/build-regional-caster-freeze.py --source <commit> --record docs/evidence/epic-world-art-20261103/build.json`으로 커밋의 필요한 소스와 검증한 LFS 입력만 분리해 Lobby/Battle을 빌드했다. 두 파일 모두 성공했고 검사 후 SHA256이 유지됐다([빌드·해시](build.json)). 기존 미커밋 로비/이동 작업은 포함하지 않았다.

별도 `TheLastThrone-Battle-0.66.0.rbxlx` Studio에서 [고정 fixture](final-suite.luau)·[소스/fixture 해시](final-suite.json)를 MCP `execute_luau`로 실행했다. [원본 엔진 로그](final-native.log)·[9개 결과 JSON](final-native.json).

| 검사 | 결과 |
| --- | --- |
| 새 월드 지형/기존 콜라이더·44구역/지연 재생성 | 86,749 PASS, 바닥4,789표본 유지 |
| HG 개별 동작 | 380,138 PASS(주로 수치 표본 유한값 검사) |
| Frozen / Ember 스토리·동작 | 4,056 / 4,114 PASS |
| 지역20종 / Deepwood10종 동작 | 7,033 / 2,813 PASS |
| 스트리밍 / 배틀 시작 | 10 / 10 PASS |
| 후기14개 스토리/19종 실제 엔진 | 1,939 PASS, fake 계정/플레이어·수동 피해 fixture |
| 고정 소스 컴파일 | 306/306 PASS, [기록](pinned-compile.json) |
| 고정 소스 Lua suite | 42/43 PASS, 기존 기사 외형 mock 실패1건, [기록](pinned-lua-tests.json) |

작업 디렉터리의43/44 결과에는 기존 미추적 travel-attempt 테스트1개가 추가돼 있어 고정 소스 수와 구분한다. 최종 생성4.84초/후보12.91초는 한 PC의 서로 다른 두 실행이고 FPS/실기기 예산 수용이 아니다. 기존 `rbxassetid://203785492` asset type mismatch 경고1건은 남아 있으며 정상 오디오 재생을 주장하지 않는다. QA Run 시뮬레이션은 중지하고 고정 빌드의 편집 미리보기를 남긴다. Git 소스·20개 PNG LFS 전송 성공, 게시/릴리스 태그 없음.
