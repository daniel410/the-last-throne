# 포션 마시는 효과음 적용 조사

2026-11-05 · TLT-005/028/032/057/084 · RESEARCH → ENG/QA

질문: 포션 사용 성공을 짧은 물 마시는 소리로 전달한다. PC/터치/패드의 기존 공통 서버 사용 경로를 활용한다. 프로젝트 제작 스킬을 적용했으며 별도 에이전트는 사용하지 않았다.

## 관찰과 출처

- [Roblox Sound objects](https://create.roblox.com/docs/sound/objects): 파트/Attachment 하위 Sound는 위치와 거리별로 들리고 SoundService 하위는 위치와 무관하게 들린다. 확인일2026-11-05. 본 저장소도 기존 전투/피격에 Sound를 사용한다.
- Creator Store 검색 `human drinking gulp`, Audio/4초 이하: ProSoundEffects의 [Drinking Cu Gulping 2 (SFX)](https://create.roblox.com/store/asset/9114171855)는 무료이며 설명상 마시기/삼키기0.9초다. MarketplaceService도 Audio(3)·동일 이름/제작자를 반환했다. Studio에서 실제 로드 길이0.8506875초 확인. Roblox 게임의 실제 플레이 비교로 간주하지 않는다.
- [Minecraft 공식 Feedback의 포션 소리 의견](https://feedback.minecraft.net/hc/en-us/community/posts/38959666912525-Adding-a-new-sound-to-the-drinking-potions): 2025-08-20 사용자 의견과2025-10-14 댓글에 소리 취향/종류별 구분 요구가 있다. 공식 사이트의 사용자 의견이며 개발사 사양·대표 만족도나 직접 플레이 증거가 아니다. 확인일2026-11-05. 타 게임 음원은 복제하지 않는다.

## 적용 판단과 최소 검증

사용자 요청에 따라 HP/MP 공통의 짧은 gulp를 사용한다. 서버 회복 확정 이후 캐릭터 Head(없으면 루트)에 음량0.4·16~60stud 감쇠로 재생한다. 기존 사용 멱등 처리 안에서 호출해 실패/재시도 중복을 피한다. 같은 캐릭터의 연속 사용 소리는 이전 것을 정리하며 Ended/5초 제한으로 제거한다. 회복량·사용시간·이동/공격 제한은 추가하지 않는다.

음량·거리·HP/MP별 구분은 이후 실제 전투 청취로 조정할 수 있다. 대안인 전역/UI 음원은 동료와 위치 맥락이 없어 이번에는 채택하지 않는다. 서버 호출/사망 세대 검사와 실제 로드·부모·감쇠·중복 정리를 최소 검사로 삼고, 게시된 두 Place/실기기/다인전투 청취는 QA 후속이다.
