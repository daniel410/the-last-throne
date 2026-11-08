# Venomcoil King 꼬리 표시 조사·보완 · 0.83.7

2026-11-07 · **TLT-065/032/033/057/084** · ART/ENG → QA. 사용자가 이전 미리보기의 꼬리가 잘린 것 같다고 제보했다. **실제 잘림은 재현하지 못했다.** 원본부터 짧고 가늘게 휘어지는 끝부분이며 원근에 따라 짧아 보일 수 있다. 원인과 별개로 발견된 원본 표시 설정 누락을 복원했다.

Meshy 원본 GLB와 리그 GLB를 단순 정점 수뿐 아니라 정점 좌표로 구성한 전체 삼각형 면 집합으로 비교했다. 3,218정점·2,458삼각형이 동일하고, glTF Z < -0.30의 꼬리704정점과 경계도 완전히 일치한다. 위치를 용접한 꼬리 열린 모서리는0개다. 따라서 리깅 과정에서 꼬리를 삭제하거나 끝을 잘라낸 증거는 없다. [수치 기록](tail-comparison.json).

원본 재질은 `doubleSided=true`인데 Studio 가져오기는 `DoubleSided=false`였고, `RenderFidelity=Automatic`이었다. 런타임 King만 양면 표시를 복구하고 정밀도를 `Precise`로 고정했다. 얇은 부분의 뒷면/자동 단순화 차이를 줄이기 위한 보완이며 이 설정이 제보 원인이었다고 단정하지 않는다. 메시/텍스처 ID·형상·크기·본/움직임·다른7종·전투/보상은 유지한다. 별도 업로드는 없다.

열린 사용자 Studio는 Play 모드라 중단하지 않았다. 실행 중 서버의 King 템플릿 표시 속성만 갱신했고 해당 시점의 활성 King은0개였다. 이 실행 중 변경은 Edit 영구 반영과 구분한다. 저장소 런타임/준비 도구와 새 빌드에 수정사항을 보존한다. 검토는 별도 Studio에서 수행했다.

![위에서 본 전체 꼬리](studio-tail-top.jpg)

이 화면은 원본 형상·양면/Precise 설정의 별도 Studio 정지 자세다. 카메라를 위쪽으로 옮겨 끝부분까지 확인했으며 실제 제보 장면/전투 중 원인 재현이나 실기기 수용을 대신하지 않는다. QA는 제보와 같은 카메라/거리·보행/공격·경사면에서 후속 확인한다. Roblox Place 미게시·릴리스 태그 없음.

검증은 기존 `tests/gloamwood-meshy-native.luau`에 King의 원본 양면/정밀도 계약 검사를 추가해 수행한다. 결과·고정 빌드·소스 커밋은 마감 기록으로 연결한다.

`rojo build default.project.json -o /tmp/tlt-venomcoil-tail-final-review.rbxlx` 후 `run-in-roblox --place /tmp/tlt-venomcoil-tail-final-review.rbxlx --script tests/gloamwood-meshy-native.luau`는 **27,999 PASS·종료0**이다. King3크기×2표시 계약 검사6개가 기존27,993에 추가됐으며16개 메시/텍스처 모두 Success다. [로그](native.log) / [결과](native.json). 최초 실행은 별도 검토 Studio의 CLI 포트가 사용 중이라 시작에 실패했고, 검토가 끝난 후 정상 재실행했다([초기 실행 오류](native-launch-failed.log)).
