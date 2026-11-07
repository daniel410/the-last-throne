# 지역 이동 로딩 이미지 v1

2026-10-31 · 이미지 생성 도구로 제작한 원본. Roblox 이미지 등록과 로컬 이동 화면 코드 연결을 완료했으며 게시 클라이언트 검증은 남아 있다.

| 지역 | 파일 | SHA-256 | 참고 원본 |
| --- | --- | --- | --- |
| Deepwood | `deepwood.png` | `49d910dd462a0be3bc81c7c0401ec98fda534633eb308a2f65753c6afb8b541c` | `assets/concepts/2026-10-27-shared-ui-v2/world/epic-01-deepwood.png` |
| Frozen Vale | `frozen-vale.png` | `dbfc729167159d6b3e4a8afb75312e4aac774ceea8a1b5779baf31606268a0c5` | TD `assets/concepts/maps-battle-target-v1/snow.png` |
| Ember Caldera | `ember-caldera.png` | `be8c4d1c51858a1e6c5f507dba293d30474af9b11a71eebc3345a3adcdd3aac2` | TD `assets/concepts/maps-battle-target-v1/volcano.png` |

프롬프트 공통: 참조 이미지의 블록형 판타지 스타일로 지역 풍경을 넓은 로딩 배경으로 제작하고 글자·로고·UI·타워 배치 표식을 제외. Deepwood는 거목과 폭포·돌다리, Frozen Vale은 설송과 빙하·피난처·얼음성, Ember Caldera는 현무암 절벽의 드워프 대장간 도시와 화산을 지정했다. 이미지 속 글자와 수치를 게임 콘텐츠로 사용하지 않는다.

Roblox의 Place 썸네일 화면은 검색/상세용이다. 서버 이동용 화면은 등록된 이미지 자산과 클라이언트 `TeleportService:SetTeleportGui` 구현을 사용한다. 네 이미지 중 하나를 무작위로 선택한다. 같은 Experience 내부 이동에서만 사용자 지정 화면이 유지되며 실제 게시 클라이언트 검증이 필요하다. [Roblox 문서](https://create.roblox.com/docs/projects/teleport). 다음 담당: 엔지니어링/QA.

구현·자산 ID·검증 상태: [이동 로딩 증거](../../../docs/evidence/travel-loading-20261031/README.md).

## Gloamwood 추가 · 2026-11-07

사용자 요청으로 기존 [`gloamwood-environment.png`](../../concepts/2026-10-30-gloamwood-v1/gloamwood-environment.png) 원본을 편집 없이 로딩 배경에 추가했다. 기존 세 이미지와 함께 무작위로 표시하며, 원본 안의 영어 지역명은 그림 그대로 유지한다.

- Roblox 이미지: `rbxassetid://104518259187897`
- 원본 SHA-256: `c88cb3cefea6ec4951aa191f828cadb084c3261d898ffa3e8d088d792e123cbf`
- [검증·미게시·한계](../../../docs/evidence/gloamwood-loading-20261107/README.md)
