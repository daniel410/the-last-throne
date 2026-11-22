# 연속 공격의 타격 박자 조사

2026-11-22 · TLT-033/057/059

| 공식 자료 | 관찰 | TLT 적용 |
| --- | --- | --- |
| [Diablo IV VFX 개발자 글](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 공격 범위와 애니메이션을 맞추고 타격 방향에 따라 피격 효과를 보낸다. 플레이어 효과와 적 예고에는 서로 다른 시각 우선순위가 있다. | Oathblade 검격을 서버가 확정한 정면 부채꼴 안의 두 방향으로 표현한다. 연속 원거리 공격은 펄스마다 궤적 하나를 보여 준다. |
| [World of Warcraft Legion 7.3 전투 애니메이션](https://wow-site-bwa-production-eks-prod-use1-01.worldofwarcraft.blizzard.com/en-us/news/20946579/patch-73-new-combat-animations-its-magic) | 대상형과 범위형 주문을 위한 서로 다른 준비 동작에 점진적인 에너지 축적을 더했다. 강한 주문과 짧은 손짓은 다른 팔 동작을 쓴다. | Molten Line은 지팡이를 든 손을 고정하고 다른 손과 앞무릎으로 지면을 누르는 세 박자를 읽게 한다. |
| [Lost Ark 글로벌 Glaivier 출시 안내](https://www.playlostark.com/en-us/news/articles/april-2022-release-notes?tag=release-notes), [Souleater Academy](https://www.playlostark.com/en-us/news/articles/souleater-academy) | Glaivier의 Flurry는 넓은 휩쓸기, Focus는 짧은 창의 연타를 강조한다. Souleater의 Harvest는 빠른 베기, Guillotine Swing은 큰 낙하 공격으로 설명한다. | 길게 남는 효과의 양보다 무기 방향과 타격 간격으로 기술을 구분한다. Quickfire는 짧은 총구 궤적에 손과 하체 반동을 맞춘다. Echo Arrows는 시위를 놓을 때마다 하나의 잎 잔상을 남긴다. |
| [Roblox 렌더링 성능 가이드](https://create.roblox.com/docs/performance-optimization/improve) | 투명 요소 겹침과 높은 오브젝트 밀도는 렌더링 비용을 높인다. | 총알·화살 궤적의 중복을 제거한다. 아군 화면에서는 추가 검격 면, 잎, 현무암 바탕을 생략하고 방향에 필요한 획을 남긴다. |

## 확인 범위

이전 이동 공격 후보가 검증한 128개 기술의 명중 경로를 기준으로, 연속 공격 네 개를 우선 골랐다. 기준 코드의 Oathblade는 두 펄스 모두 수평 리본을 사용했다. Quickfire는 HeroVFX와 기본 원거리 렌더러에서 중복 궤적을 생성했다. Echo Arrows는 펄스마다 잎 세 개와 중복 잔상을 만들었다. Molten Line은 펄스마다 경로 전체를 동시에 밝혔다. 피해, 판정 범위와 펄스 시각은 서버 정의를 사용한다. 비교 조건과 실행 결과는 [연속 공격 증거](../evidence/hero-pulse-rhythm-20261122/README.md)에 있다.
