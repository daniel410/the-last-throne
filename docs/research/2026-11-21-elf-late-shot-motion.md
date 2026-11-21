# 엘프 발사 확인과 활시위 동작

TLT-033/057/059 · 2026-11-21 · 기준 0.115.37

0.115.37에서 방향과 발사 원점을 다듬었다. 후속 검사에서는 발사 확인이 85ms 늦게 도착할 때 이미 화면에서 당기고 있던 시위가 손에서 앞으로 튀는 구간을 건너뛰었다. 기본 사격과 단발 스킬은 바로 회수 자세, 연속 사격은 바로 다음 화살 준비로 넘어갔다. [이전 발사축 검증](../evidence/hero-release-alignment-20261121/README.md)

| 공식 사례 | 관찰과 적용 |
| --- | --- |
| Diablo IV · 2021년 12월 개발자 업데이트 | 타격 범위와 동작·효과가 같은 시간에 읽히도록 맞춘다. TLT는 권위 있는 발사 확인 직후 당김 자세에서 시위를 놓는 구간을 보여 준다. [Blizzard](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) |
| World of Warcraft Retail · Legion 7.3 | 시전 자세의 무게와 반응성을 함께 맞추고 준비와 방출의 모양을 구분했다. TLT는 시위 동작을 짧게 보여 준 뒤 기존 회수 시각에 합류시킨다. [Blizzard](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) |
| Lost Ark 글로벌 · 2025년 4월 Sharpshooter | Charged Shot의 조준과 Snipe의 유지 시간을 서로 다르게 조정했다. TLT는 Heavy Draw의 기존 당김과 연속 사격의 연사 간격을 기준으로 각각 검증한다. [Amazon Games](https://www.playlostark.com/en-us/news/articles/april-2025-update-release-notes) |
| Roblox Creator Hub | `GetServerTimeNow`는 클라이언트가 추정한 서버 시각이며, 속성과 원격 이벤트의 도착 순서는 보장되지 않는다. 테스트에서는 발사 시각과 확인 도착 시각을 따로 입력한다. [Workspace 시계](https://create.roblox.com/docs/reference/engine/classes/Workspace#GetServerTimeNow) · [복제 순서](https://create.roblox.com/docs/scripting/attributes#replication-order) |

이미 화면에서 보고 있던 활시위의 발사 구간만 복구한다. 다음 발사나 기술 종료가 가까우면 기존 시각을 사용한다. 사례 조사는 공식 문서에 기반하며 네트워크 지연 실측은 TLT의 게시 테스트 수용 항목이다. [전후 결과](../evidence/elf-late-shot-motion-20261121/README.md)
