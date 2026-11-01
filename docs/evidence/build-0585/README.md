# 0.58.5 빌드 및 게시 시도

2026-10-31 · TLT-005/014/032/055/084 · ENG → QA

입력 커밋 `ad52bce` / VERSION `0.58.5`, 별도 Git worktree에서 Rojo 7.7.1로 Lobby와 Battle을 각각 빌드했다. 원래 작업 트리의 미커밋 로비·이동 및 Blender 파일은 포함하지 않았다.

| 산출물 | SHA-256 |
| --- | --- |
| `builds/0.58.5/TheLastThrone-Lobby-0.58.5.rbxlx` | `f0e276476478cdb93299ef3655fdf0ef0a643f0f6247415275e7a3353164650b` |
| `builds/0.58.5/TheLastThrone-Battle-0.58.5.rbxlx` | `dbba077531be72df4cac906e420e153a39f8edea099abb90d424c2c537dba4b4` |

`rojo build default.project.json` 및 `rojo build battle.project.json` 성공. Battle 격리 네이티브 시작 검사 10개, 투척 장식의 한정 fixture 12개 통과. 기존 자산 `203785492`의 유형 불일치 경고는 남는다. 실제 클라이언트·기기·다인 검증은 하지 않았다.

게시 요청에 따라 Battle 파일을 Studio에서 열었고 MCP 목록에서 정확한 파일명을 확인했다. 그러나 UI 제어는 별도로 열린 Throne Defense 창에 고정되어 게시 대상 선택을 검증할 수 없었다. Roblox 게시 성공은 확인하지 못했고 두 Place 모두 게시하지 않았다. 로컬 빌드만 있으며 릴리스 태그도 만들지 않았다. 다음 담당은 Studio에서 해당 0.58.5 파일을 직접 활성화하여 The Last Throne Experience `10773575153`의 Battle `129388473517823`과 Lobby `70829337938054`에 각각 게시하고 버전 이력에서 확인한다.
