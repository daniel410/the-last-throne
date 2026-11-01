# 0.58.5 빌드 및 게시 시도

2026-10-31 · TLT-005/014/032/055/084 · ENG → QA

입력 커밋 `ad52bce` / VERSION `0.58.5`, 별도 Git worktree에서 Rojo 7.7.1로 Lobby와 Battle을 각각 빌드했다. 원래 작업 트리의 미커밋 로비·이동 및 Blender 파일은 포함하지 않았다.

| 산출물 | SHA-256 |
| --- | --- |
| `builds/0.58.5/TheLastThrone-Lobby-0.58.5.rbxlx` | `f0e276476478cdb93299ef3655fdf0ef0a643f0f6247415275e7a3353164650b` |
| `builds/0.58.5/TheLastThrone-Battle-0.58.5.rbxlx` | `dbba077531be72df4cac906e420e153a39f8edea099abb90d424c2c537dba4b4` |

`rojo build default.project.json` 및 `rojo build battle.project.json` 성공. Battle 격리 네이티브 시작 검사 10개, 투척 장식의 한정 fixture 12개 통과. 기존 자산 `203785492`의 유형 불일치 경고는 남는다. 실제 클라이언트·기기·다인 검증은 하지 않았다.

초기 게시 시도에서는 UI 제어가 다른 Studio 창에 고정되어 게시하지 못했다. 이후 사용자의 Studio 강제 종료·재게시 지시에 따라 고정 빌드를 각각 열고 The Last Throne Experience `10773575153`에 게시했다. Creator Dashboard의 Show published only에서 Battle `129388473517823` 버전 **6** (10월31일 22:52), Lobby `70829337938054` 버전 **20** (22:54)을 확인했다. 시간대는 America/Toronto다. 게시 후 파일 SHA-256도 위 값과 일치한다. Experience는 비공개 테스트 상태다. 자산 권한 안내에서 Grant Permissions and Publish를 실행했으며 개별 자산 목록은 표시되지 않았다.

게시된 클라이언트에서의 실제 조작·Place 이동·다인 및 실기기 수용은 미검증이다. 비공개 테스트 게시로 정식 릴리스 태그는 만들지 않았다. 다음 담당은 QA다.
