# 공통·지원 VFX 후속 구현

TLT-033/057/084 · ART-COMMON-05/06/07 대응 · 사용자의 우선/후속 전체 개선 지시. 공통 소유 파일4개와 전용 검사만 변경했다. 팔레트/명중/HeroVFX·장비/활/소켓 소스는 다른 담당 범위다.

## 플레이어에게 보이는 변경

- **Heal 단독 accent:** 원래12입자·4emitter·작은 Plus2개 예약을 유지했다. 주 상승 파편의 시작 크기를0에서0.32/0.36으로 바꾸고 최대크기0.48/0.55는 유지했다. 시작 투명도0.04와 짧은 유지/감쇠 곡선으로 첫 상승을 보강했으며 발광은0.45다. Specs도 시작 크기0.1로 보완했다. 입자 원점을 몸 중앙 대신 양옆X±0.95와 허리 아래로 옮겨 초기 실루엣에 가려질 가능성을 줄였다. 큰 의료 십자나 오라는 추가하지 않았다.
- **Heal 전체지원:** 기존 지원 링24파트를8개의 작은 생명 줄기/잎으로 재배치했다. 수신자 옆에서 짧게 위로 올라오고 소멸한다. 시전자 연결선과 `+12 HP` 등 실제 결과 문구는 유지한다. 실제 회복량/지원 권리/서버 이벤트를 변경하지 않는다.
- **Protect:** 보이는 금빛 ForceField 구형 외피·바닥링·연결선/문구를 유지한다. 내부 몸이 보이는 기존 방향을 보존한다.
- **Cleanse 단독 accent:** 초기 빈 atlas 프레임에만 의존하지 않고 엔진 기본 텍스처를 사용하는4방향·12입자의 짧은 외향 release로 구분했다. 지속은 표시용0.65초로 Heal1.25초와 다르다. 동일 Curated12입자 예약 안에 포함한다.
- **Cleanse 전체지원:** 기존24파트를 수신자 바깥으로 씻겨 나가는 짧은 수평 스트로크로 재배치했다.0.58초 흐름 이후 사라지고 결과 문구는 기존 표시 수명을 유지한다. PixelFX의 외향 입자를 쓰므로 별도 수신자 generic24입자 burst는 제거해 중복을 줄였다. 이는 제거된 상태의 시각 단서이며 실제 상태 제거 판정을 추가하지 않는다.
- **길안내:** `GuideOverlay.AlwaysOnTop=false`로 일반 월드 깊이를 사용한다. 경로 계산·목표·도착 표지·근처 fallback·표시 ON/OFF 로직은 유지한다. 기존 안내가 실제 위험 바닥을 가렸다는 확정 결함이 아니라, 전체 미술 위계에서 겹침 가능성을 줄이는 승인된 개선이다.

## 예산과 계약

`SelenePresentation`은 원래 효과별24개 세부 파트와 기존 glow1개/Protect외피1개 범위를 유지한다. Heal/Cleanse/Protect 모두 같은 수신자 추적·사망/스트림아웃/만료 정리를 사용한다. Curated의 동시 입자 상한192/터치96, PixelFX의 기록24/거리80 제한을 공유한다. Heal12입자 예약은 그대로고 Cleanse도12 예약에 포함한다. Source손의12입자는 유지하며 Cleanse의 기존 target24 generic burst를 제거했다. 새 이미지 업로드·권한·연속 emitter 의존은 없다. GPU/실기기 성능 향상을 주장하지 않는다.

서버 피해/회복/상태·지원권·전투 이벤트·수치·쿨다운·성장·TD 자산/운영·실제 손소켓/무기 정렬은 변경하지 않았다. 영어 결과 문자열도 그대로다.

## 변경 파일

- `src/client/CuratedVFX.luau`: 작은 Heal의 초기 가시성/원점, shared-budget Cleanse 외향입자.
- `src/client/PixelFX.luau`: Cleanse 표시를 Curated release에 연결; 기존 follow/만료/취소 기록 사용.
- `src/client/SelenePresentation.luau`: 원래24파트로 상승 Heal/외향 Cleanse를 구분하고 Protect 유지.
- `src/client/DeepwoodNavigation.luau`: 월드 occlusion과 공통 chevron 생성 helper; 안내 경로/도착/fallback 유지.
- `tests/vfx-art-support-fixes-native.luau`: 실제 엔진 인스턴스/흐름/정리·예산 검사. 실제 게임/기기 수용을 대신하지 않는다.

## 검증·인계

담당자가 실행한 범위:

- 변경4모듈+전용 native suite Luau 컴파일 PASS.
- `lua tests/pixelfx.spec.lua`: **634 PASS**.128기술/4기본 profile·지원/취소/예산 CPU 회귀이며 엔진 렌더 검증이 아니다.
- 작업 파일 `git diff --check` PASS.

통합 담당 root가 고정 소스 `c1b578d470a26536bd1a22895f265b91d3c16669` /0.104.28에서 실행한 [엔진 로그](native.log)를 확인했다. **전용 지원127 PASS**, 팔레트562·기존 Curated182/PixelFX1690 등 **17 suite 합계95,423 PASS**다. CPU 회귀 합계는 [cpu.log](cpu.log)의634+15,822=16,456 PASS이며 새 기대와 연동된 기준이다. [검증 요약](validation.json).

전용 suite는 Heal12예약/작은Plus·원점/상승·수신자 추적/사망 정리, Cleanse12예약/외향 burst/짧은 수명, 실제 Selene 전체지원24파트·방향/위계/결과 문자열·권한 없음·정리, 혼합 포화 예산 및 occluded 길안내 생성 속성을 검사했다. 실제 적/영웅 전투나 GPU 수용 검사는 아니다.

기존 `navigation-always-on-native`는 root가 승인된 AlwaysOnTop=false 계약으로 갱신해 별도 실행했다. [nav.log](nav.log)에 거리·직접방향·지역 바닥/고도·스트림 바닥 fallback·설정·훈련/사망 정리 PASS가 있다. `selene-motion-native`의 ring배열24개는 유지하지만 Heal/Cleanse에서는 지면 링이 아닌 지원 단서다.

0.104.26의31장 후 캡처와 baseline을 [전후 ART 재검토](common-after-review.md)에 연결했다. 팔레트/명중은 다른 담당 변경의 ART 관찰이며 지원05/06은 구현 담당자의 전후 검토다. 이를 독립 QA 최종 수용으로 표현하지 않는다.
0.104.26의 실제 TD Selene+Traveler 장비 stockR15·2지역 조명 프로필 합성6장을 직접 확인했다. 이 범위와 최종0.104.28 재촬영은 [전후 ART 재검토](common-after-review.md)에서 구분한다.

미검증: 실제 지역맵·이동 캐릭터/손소켓·6지역/조명, 위험 바닥/목표와의 겹침, 이동/다인4인+AI, 터치/패드·GPU/실기기, 전체 재생 시간·최초 로드/사용자 미술 수용. root의 격리 엔진/전후 캡처와 실제 지역/자산/다인 수용은 구분한다. 원래 ART 수용 공백을 단순 구현으로 완료 처리하지 않는다.

최종0.104.28 단독 Heal 초기 가시성 보강은 컴파일과 전용127검사에 포함됐다. [최종 지원4장](support-final/sheet-01.png)과 [실제 자산 문맥6장](support-context-final/sheet-01.png)을 직접 확인했다. 단독 Heal은 작은 양옆 상승파편이 첫 스틸에서 보이며 full Heal의 작은 줄기/잎을 덮지 않는다. 실제 TD nun+Traveler stockR15·밝음/어두움 조명에서 Heal/Protect/Cleanse 형상 구별을 확인했다. 상세·메타데이터·수용 한계는 [최종 ART 판정](common-after-review.md)에 기록했다. 실제 지역맵/다인/실기기 수용은 남는다.
