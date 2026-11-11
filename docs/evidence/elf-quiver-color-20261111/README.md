# 엘프 활·화살통 색상 연동

2026-11-11 · TLT-008 · ENG · 소스 구현 및 독립 Studio 엔진 검증

사용자 지시: 엘프의 화살통 색을 장착한 활 색에 자동으로 맞춘다. 기존 고정 갈색 몸통·초록 테두리를 제거했다. `ElfQuiverAppearance`가 현재 Bow의 텍스처 팔레트와 Color 틴트를 사용한다. 몸통·끈은 주색, 테두리는 보조색이며 화살 메시·색·물리·소켓은 유지한다. 기존 외형 동기화 경로에서 장비 변경/재생성 시 자동 적용하고, 정상 화살통에 `ensure`를 다시 호출하면 색만 갱신한다. 구버전 화살통은 버전2로 재생성한다.

## 색상 근거

`tools/derive-elf-quiver-palette.py`로 승인 GLB의 sRGB base-color 이미지를 읽었다. 최대256×256 표본에서 검정 여백·무채색·극단 밝기를 제외하고 RGB32단위 최빈 구간의 평균을 주색, 색 거리100을 넘는 다음 최빈 구간을 보조색으로 사용했다. [원본 해시와 결과](palette.json). Blender 렌더나 조명 보상은 사용하지 않았다.

Traveler / Tempered / Veteran / Sentinel 및 기존 TD 기본 활의5개 텍스처를 지원한다. `SurfaceAppearance.ColorMap`이 있으면 `TextureID`보다 우선하며, 텍스처 팔레트에 Bow.Color를 곱한다. 무텍스처/미등록 텍스처는 Bow.Color를 사용한다. 향후 새 텍스처 추가 시 생성기의 입력과 팔레트를 갱신해야 한다. 텍스처의 무늬 자체를 화살통에 복사하지는 않는다.

## 검증

```text
/tmp/tlt-quiver-python/bin/python tools/derive-elf-quiver-palette.py
node tools/prepare-dwarf-swing-review.mjs /tmp/tlt-quiver-color-qa tests/elf-quiver-native.luau
run-in-roblox --place /tmp/tlt-quiver-color-qa/tlt-k0-qa-empty.rbxlx --script /tmp/tlt-quiver-color-qa/source-probe.luau
```

생성기는 Pillow 사용. 의존성은 저장소 밖 임시 venv에 설치했다. 독립 Place fixture는 게임 빌드/게시가 아니며 VERSION을 증가하지 않았다. [입력 소스 해시](source-manifest.json), [엔진 결과](native.log).

**245검사 PASS**. Part의8비트 색 저장에 맞춰 틴트 결과를 반올림하고 동일 색 재동기화가 외형을 계속 무효화하지 않는지도 확인했다.

R6/R15 각각5개 텍스처의 색 연동·틴트·동일 화살통 재사용·SurfaceAppearance 우선·무텍스처 대체·손상 복구·다른 클래스 전환과 기존 화살 꺼내기/전달/취소/물리 회귀를 검증했다. 현재 작업트리의 기존 K0Config 변경도 fixture 입력 해시에 기록했으며 이번 커밋에서는 제외했다.

미검증: 실제4계열 무기 교체의 게시 클라이언트 조작, 조명 아래 육안 색상 수용, 모바일/멀티플레이. Roblox 게시·릴리스는 수행하지 않았다. 상위 TLT-008/G1 전체 완료를 선언하지 않는다.

다음 담당: QA/사용자 — 다음 시험 빌드에서 엘프 활4계열 교체 후 등 뒤 화살통의 몸통·테두리를 확인하고 시각 수용한다.
