# 몬스터별 마법 공격 VFX

2026-11-12 · TLT-005/027/032/033/057/061~065/084 · ENG/DES → QA

사용자가 모든 몬스터의 마법이 같은 볼트처럼 보인다고 지적하고 종별 마법 효과 구현을 요청했다. 기존 서버에는50종/146공격·6형상·40개 투사체 공격이 있으나 클라이언트 투사체와 시전 응집은 색만 다른 같은 구체였다. 기존 [패턴 조사](2026-11-05-enemy-pattern-review.md)와 [피격 개선 조사](2026-11-12-boss-impact-motion.md)를 재사용한다.

## 공식 근거·확인일

2026-11-12 공식 설명을 확인했다. 실제 외부 게임 플레이나 현행 패치 수치를 조사한 것은 아니다.

- [Diablo IV 2021-12 개발자 VFX 설명](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021): 전투 가독성과 플레이 우선, 효과 강도/크기 변화의 설계 원리를 설명한다. 출시 전 개발 설명에서 **공격 종류를 읽는 실루엣과 정확한 타격 시점**을 참고한다. 디아블로의 이미지/고유 기술/성인용 표현은 복제하지 않는다.
- [Diablo IV 2021-06 몬스터 미술 설명](https://news.blizzard.com/en-us/article/23665024/diablo-iv-quarterly-updatejune-2021): 게임 카메라에서 읽히는 외형과 세부 표현을 구분한다. 이번에는 색만 바꾸는 대신 부적·결정창·돌덩이·거미줄·영혼 가면·균열 등35모티프와 종별 장식50조합을 사용한다.
- [Roblox 공식 입자 설명](https://create.roblox.com/docs/effects/particle-emitters), [성능 설명](https://create.roblox.com/docs/performance-optimization/improve): 투명 효과의 겹침과 입자 비용을 고려해야 한다. 이미 승인된 PixelFX 보조 효과·유한 Trail을 재사용하고, 의미를 전달하는3D 형상은 이미지 로딩과 독립적으로 유지한다. 파트640/효과64 예산은 구현 상한이며 실기기 성능 보장치가 아니다.

## 적용·비용·수용

Shaman 부적/KingShaman 토템, IceElf 결정창/QueenIceElf 프리즘/IceTroll 얼음 바위, Imp 불씨/VolcanoShaman 화염 부적/CalderaTitan 불붙은 바위, Webling 실침/Silkweaver 실 그물/WidowQueen 독알과 실 부채, Lich 영혼 가면/LichSovereign 봉인/Veyr 균열로 구분한다. 일반 근접 적의 속성 공격·보스 범위 기술도 같은 종별 룩업을 사용한다. 비행은 기존 서버 직선 탄도를 유지하고 회전/잔상만 꾸민다.

시전→발사→비행→환경 충돌/실제 명중→범위 타격을 연결한다. 고리형 공격의 안전한 가운데는 비워 두며 바닥이 스트리밍되지 않은 곳에는 공중 분출을 만들지 않는다. 새 지속 피해·유도탄·감속/구속·공격 빈도/데이터/보상 변경은 없다. 서버 메시지에는 실제 공격ID와 실제 접촉 위치만 보강한다.

최소 실험은50종146공격/40투사체의 형상 생성·탄도·영역·정리·중복/지연/취소, 기존 서버 방어/회피/원정 격리 회귀다. 별도 Studio 표본과 정상 게시 클라이언트·작은 화면·4인+AI 성능/가독성 수용을 구분한다. [실행 증거와 남은 수용](../evidence/monster-spell-vfx-20261112/README.md).
