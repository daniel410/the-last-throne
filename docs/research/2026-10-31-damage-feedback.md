# 피격 피드백 조사 · TLT-005/032/033/084

2026-10-31 확인. 목표는 사용자 요청의 짧은 비언어적 피격 신음·아주 약한 붉은 효과, 더 잘 보이는 몬스터 타격이다. 제작 스킬과 리서치 역할의 기존 전투 조사 범위를 재사용하고 다음 공식 자료를 확인했다. 직접 다른 게임을 플레이하거나 소리를 청음한 증거로 간주하지 않는다.

| 비교/근거 | 확인 사실 | 적용 판단 |
| --- | --- | --- |
| [God of War 개발자들의 전투 설명](https://blog.playstation.com/2022/10/04/game-developers-explain-what-makes-god-of-war-2018s-combat-tick/) · 2022-10-04 | 타격 뒤 적의 반응, 애니메이션·음향이 전투 피드백을 만든다고 설명한다. | 짧은 시각적 몸 반응과 접촉면 섬광을 결합한다. 이 작품의 폭력 표현·자산은 복제하지 않는다. |
| [Roblox 피격 GUI/Sound 제작 사례](https://devforum.roblox.com/t/damage-guisound-module/896959) · 제작자 게시물 | 체력 변화를 검사하고 GUI/소리의 tween을 구현한 공개 사례다. 특정 출시 게임의 인기도/효과성 검증은 아니다. | 로컬 효과 구조는 참고하되 장비 HP 조정/회복에도 울릴 수 있는 일반 HealthChanged 대신 실제 서버 피해 적용 후 전용 pulse를 쓴다. |
| [Sound](https://create.roblox.com/docs/reference/engine/classes/Sound), [UI appearance modifiers](https://create.roblox.com/docs/ui/appearance-modifiers), [Highlight](https://create.roblox.com/docs/reference/engine/classes/Highlight) | Sound 로드/재생, UIGradient, Occluded Highlight의 공식 동작 계약. | 재사용 Sound 하나·5개 비입력 Frame·짧은 Tween, 기존24개 타격 효과 상한을 유지한다. |

선택: 화면 중앙 적색 불투명도2.5~4.5%, 가장자리10~18%, 약0.42초 fade. 카메라 흔들림과 화면 전체 강한 플래시는 추가하지 않는다. 피격 음성은 설치된 Studio와 Player 양쪽의 `content/sounds/ouch.ogg`(약0.449초)를 `rbxasset://sounds/ouch.ogg`로 참조한다. 새 오디오 파일을 재배포/업로드하지 않는다. 음량0.24, 최소0.55초 재생 간격으로 연타 음성 중첩을 제한한다. 원본 파일 존재는 실제 클라이언트 로드·청음 검증을 대신하지 않는다.

몬스터는 기존 서버 확정 피해 이벤트에서 몸 앞 접촉면으로 충격을 옮기고, 클래스 색상의 윤곽/섬광·2개 교차 광선·기존5개 파편을 보강한다. 약0.18초의 국소 몸 반응은 서버 루트/피해/공격 시간/스턴을 바꾸지 않는다. 보스 반응 폭은 절반이다. 별도 hit-stop이나 추가 스턴은 이번 범위에 포함하지 않는다.

최소 시험: 무효/흡수/회피/완벽 방어는 피격 pulse0, 실제 피해·연타 중복 방지·회복/리스폰 분리,4클래스 소리 로드와 GUI 캡/정리, 몬스터 루트 불변과 몸 반응 복귀, 기존 타격/동작 회귀. 다음 QA는 실제 게시 클라이언트 청음·터치/패드/실기기·멀티플레이 가독성을 수용한다.
