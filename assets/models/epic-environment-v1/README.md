# 에픽 환경 보강 키트

TLT-057/061~065/084 · 2026-11-11 · Blender MCP 직접 제작.

`tools/build-epic-environment-blender.py`를 Blender MCP로 실행한 별도 장면의10모델·246파츠다. 기존 Hollowbark 사용자 장면은 유지했다. 생성 서비스/외부 자산 다운로드 없이 직접 조형했고, 기존 TD 랜드마크 주변에 배치한다. 숲 유적·뿌리와 고치·빙하·주상절리·기념묘 및 각각의 지면 군집으로 구성한다.

- `epic-environment.glb`: 새 장면만 내보낸 편집 가능한 기하/재질 원본.
- `kit.json`: Blender 제작값, sRGB 색·Roblox 축 기준 위치/크기/회전/재질.
- `kit-preview.png`: Standard / sRGB / Look None / Exposure0 / Gamma1 / Curves Off 렌더.
- `python3 tools/export-epic-environment.py`: 같은 기하를 `EpicDetailTemplates.luau`로 내보낸다. Roblox 기본 Part/WedgePart를 사용하므로 새 메시 업로드/자산 권한 없이 재현된다. Shader 세부와 라이팅은 엔진별로 다르다.

GLB/PNG는 LFS. 안전 모드에서 외부 스크립트 실행·라이브러리 저장이 거부되어 허용된 직접 코드 실행과 새 장면 GLB export로 제작했다. 기존 사용자 .blend를 저장하거나 덮어쓰지 않았다. 모델 미술/실기기 최종 수용은 작업 증거를 따른다.
