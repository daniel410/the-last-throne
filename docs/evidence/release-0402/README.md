# 0.40.2 비공개 게시 기록

2026-10-30 · TLT-021/053/084 · 사용자 게시 및 자산 사용 권한 부여 승인에 따라 Experience `10773575153`의 두 Place를 게시했다. Creator Dashboard에서 Game access와 Audience reach가 모두 Private임을 확인했다. 기존 TD Experience는 대상이 아니다.

| 대상 | Place ID | 게시 버전 / America/Toronto | 원본 SHA256 |
| --- | --- | --- | --- |
| RPG Lobby | 70829337938054 | 18 / 19:19 | 570c1e0108457b0e12435db916aa0a7fe19352eedbee78edcffd39bf9983ea71 |
| RPG Battle | 129388473517823 | 4 / 18:04 | 5d103a26bf2ed2fbaf200289b1a96c98e5cba3762dfc5433a9f5467f8106354f |

두 버전은 Creator Dashboard의 **Show published only**에서 확인했다. 게시 소스 커밋은 `0a04d7b98e07e8b0c4eb99d7e7330e90d2273d46`이고, [빌드 기록](../deepwood/places-0400/build.json)의 파일을 재빌드하지 않고 게시했으며 게시 후 SHA256을 재확인했다.

Studio의 자산 권한 안내에서 사용자가 The Last Throne Experience에 권한 부여를 명시적으로 승인한 뒤 **Grant Permissions and Publish**를 실행했다. 안내에 개별 자산 목록은 표시되지 않아 자산 ID와 개수는 확인하지 못했다. 사용자의 명시적 요청에 따라 게시 전 Studio 창들을 강제 종료했다.

[구현 및 네이티브 검증](../deepwood/places-0400/README.md)과 실제 게시 결과는 별개다. 0.40.2의 게시된 클라이언트 플레이, 장소 왕복, 다인 및 실기기 수용은 아직 확인하지 않았다. 다음 담당 QA는 해당 경로와 자산 표시를 실제 클라이언트에서 검증한다.
