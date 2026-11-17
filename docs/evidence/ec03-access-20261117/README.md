# TLT-063 · 광산 진입로 후보 실험

2026-11-17. 상태: 후보 기각·원인 측정, 실제 맵 개선 미완료. 제작 스킬의 맵 구현·환경 아트·환경 모델링·리서치 역할을 순차 수행했다. G5 미완료.

## 변경 범위와 결과

입구 소품 증량을 중단하고 BracedMineHead의 +Z 궤도 끝에서 실제 ApproachPosition까지 폭6stud의 접지 진입로를 시험했다. 개인 구조 상태를 표현하지 않는 영구 작업로 후보이며 TD 원본·목표·서버 진행·저장·보상을 바꾸지 않는다. 네이티브 Part만 사용했고 Blender는 사용하지 않았다.

[candidate.luau](candidate.luau)와 [integration.patch](integration.patch)는 **미적용 후보**다. 실제 소스에 넣지 않았다. 길이160stud 제한에서 Distance로 거부됐다. 격리 복제 모듈의 한도를256으로 늘린 진단에서는 Slope로 거부됐다. 후보를 통과시키려고 수용 기준을 낮추지 않았다. 후보 모듈의 형상·비충돌/query/touch·접지 높이 및 거리/지면누락/횡경사/종경사/장애물 거부16조건은 통과했다. 첫 검사에서 .06 부동소수점 직접비교 실패 후 .001 오차 비교로 수정했다. 모듈 검사는 실제 맵 플레이 수용이 아니다.

## 실제 월드 측정

자체 Studio PID78571, `/tmp/tlt-ec03-access-qa.rbxlx`, PlaceId0, Edit, 플레이어0. 기존 `/tmp/tlt-ec03-shoulder-after.rbxlx` QA 사본에 RegionalArchitecture v9와 후보2모듈을 주입하고 실제 CampaignWorld.create를 실행했다. 전체 최신 빌드가 아니며 최신 VERSION/게시 상태와 무관하다. [입력 해시](inputs.json), [51개 표본](results.json), [측정 코드](measure.luau).

- 입구 끝 `(372.609,142,-12494.940)` → 최근 목표 `(242.150,140,-12644.400)`, 약198.398stud.
- 초반 Native Terrain 높이141.419~141.991. 표본8→9 사이 약3.97stud 구간에서141.419→140 BasaltGround로 전환한다.
- 이것은 시각 진입로의 접지 기준 실패다. 실제 영웅이 걸리지 못한다는 판정이나 수직 절벽의 정확한 형상 측정은 아니다. 경사·높이 변화가 있는 접합부를 얇은 바닥 장식으로 덮지 않았다.
- 검사 후 자체 Studio만 종료했다. 사용자 Studio와 기존 미커밋 파일은 보존했다.

## 리서치와 적용 판단

2026-11-17 공식 본문 재확인. [Diablo IV 개발판2022 환경](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022)은 재료·건축 구성의 설득력, [WoW Retail The War Within](https://news.blizzard.com/en-us/article/24125258/explore-the-zones-and-dungeons-of-the-war-within)은 지하 지역·시설의 장소성, [Lost Ark 글로벌 Elgacia2023](https://www.playlostark.com/en-gb/news/articles/elgacia-release-notes)는 도시·정원·성산의 장소 구분을 설명한다. 현행 전투 수치나 서로 다른 버전을 혼합하지 않았다.

제작 해석: 구조 광산은 입구 장식보다 작업 시설에서 구조 목표까지의 연속 공간이 우선이다. 최소 실험 비용은 최장160stud/40파트, 주요 위험은 바닥 뜸·기존 지형과 겹침·새 길이 주는 잘못된 안내다. 실험이 실패했으므로 채택하지 않았다. 외부 자산은 가져오지 않았다.

## 다음 담당과 미검증

ENG/ART/QA: 우선 최신 소스 고정 빌드의 실제 Play supports→worm→miners 영웅/HUD/개인투영을 대조한다. 이후 광산 어깨 지형과140stud 본바닥 사이에 실제 통과 가능한 접합부를 설계하고, 그 위에 진입로를 재실험한다. 단순 길이 한도 확대·허용 경사 완화·입구 소품 추가로 대체하지 않는다.

이번에 실제 Play·게시 클라이언트·기기·스트리밍·멀티·성능·미술 수용은 수행하지 않았다. 게임 빌드/버전/릴리스 태그/Roblox 게시 없음. 전체 사용자 목표와 TLT-063 완료가 아니다.
