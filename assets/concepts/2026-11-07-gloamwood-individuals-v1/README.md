# Gloamwood 개별 투명 PNG · v1

작업: **TLT-065/gloamwood-individual-transparent-20261107** / 3D 미술 참고 이미지 제작 / 2026-11-07.

사용자 요청에 따라 일반 몬스터5종과 보스3종을 각각 배경 없는 PNG로 제작했다. 내장 `image_gen`을 개체별1회씩 사용했으며 [전체 프롬프트](prompts/requests.json), [생성 원본 경로](sources.json), [크기·SHA256·알파 검사](manifest.json)를 보존한다.

| 구분 | 개체 | 개별 PNG |
| --- | --- | --- |
| 일반 | Webling | [Webling.png](Webling.png) |
| 일반 | Silkweaver | [Silkweaver.png](Silkweaver.png) |
| 일반 | Barkstalker | [Barkstalker.png](Barkstalker.png) |
| 일반 | Gloambat | [Gloambat.png](Gloambat.png) |
| 일반 | Venomcoil Centipede | [VenomcoilCentipede.png](VenomcoilCentipede.png) |
| 보스 | Widow Queen | [WidowQueen.png](WidowQueen.png) |
| 보스 | Ancient Hollowbark | [AncientHollowbark.png](AncientHollowbark.png) |
| 보스 | Venomcoil King | [VenomcoilKing.png](VenomcoilKing.png) |

일괄 전달: [8개 PNG ZIP](gloamwood-8-transparent-png.zip).

## 근거와 범위

[기존 v5 일반/보스 보드](../2026-10-30-gloamwood-v1/README.md)를 직접 열어 참조 이미지로 제공했다. 얼굴·원형색·큰 블록형 몸통/관절을 이어가며, 글자·프레임·환경을 제외한 개별 전신3/4 시점으로 생성했다. Barkstalker는 원본 보드의 나무껍질 위장 **거미**를 따른다. 현재 런타임의 임시 엔트 대체 형상을 변경하는 작업은 아니다.

파일은 생성 원본을 그대로 복사했으며 별도 리사이즈·수동 알파 수정은 하지 않았다. 재설계나 신규 게임성 제안 없이 기존 컨셉을 개별 제작 참고 이미지로 옮긴 범위다. 기존 사용자 파일과 삭제 상태를 보존했다.

## 검증과 후속

`uv run --quiet --with pillow python`으로8개 PNG 디코딩, RGBA 모드, 알파 최소0/최대254~255, 투명 외부 픽셀 및 네 모서리 알파0을 검사했다. 알파128 이상 피사체 경계가 모두 캔버스 안에 있다. 크기는1536×1024가5개, Gloambat1752×897, Venomcoil Centipede1774×887, Ancient Hollowbark1320×1192다. 생성 이미지의 외형도 시각 검토했다. ZIP 재해제 바이트·SHA256 일치 검사와 Git LFS 포인터 검사를 마감 때 수행한다.

미검증: 사용자 최종 미술 수용, 후면 형상, 실제 메시·삼각형 수·리그·애니메이션·Studio·실기기. 특히 다리/몸통 마디의 정확한 수와 숨겨진 관절은 실제3D 제작 시 확인해야 한다. 2~3k tris는 기존 제작 목표이며 PNG로 실측할 수 없다. 게임 빌드/게시/릴리스가 없어 VERSION과 태그는 변경하지 않는다. 다음 담당자는3D 모델링 아티스트이며 이 이미지를 참고해 메시와 리그를 제작하고 원형/관절을 검증한다.

## 사용자 후속 수정 · v2

2026-11-07: Silkweaver의 다리를 사용자 지정인 좌우3개씩 총6개로 교정했다. 최초 생성 프롬프트의8개 요구는 이 최신 지시로 대체하며, 중간5개 수정본은 미채택했다. 최종 이미지의6개 발을 시각 확인했다. Venomcoil Centipede는 몸통을 짧고 가늘게 줄이고 캔버스 여백을 늘려 King보다 작게 보이도록 수정했다. 과도한 긴 더듬이를 머리 위 양쪽에서 이어지는 짧은 한 쌍으로 교정했다.

내장 image_gen으로 수정하고 PNG2개를 교체했으며 [수정 프롬프트·원본 경로](prompts/corrections-v2.json)를 보존했다. 기존 버전은 Git 이력5b2dddb에 있다. 두 파일 모두1536×1024이며 RGBA/투명 외부·네 모서리 알파0 검사 PASS.8종 ZIP도 갱신하고 CRC/전체8파일 SHA256 일치를 확인했다. 나머지6종은 바이트가 동일하다. 이 크기 차이는 참고 이미지 표현이며 런타임 크기 변경/실제3D 모델 수용은 아니다.

## 최신 사용자 수정 · 거미8다리 v3

2026-11-07: 사용자가 거미 전부의 다리를8개로 정정했다. 앞선 Silkweaver6다리 지시보다 이 지시가 우선한다. Webling·Silkweaver·Barkstalker·Widow Queen4종을 내장 image_gen으로 재생성하고, 빠진 뒷다리 한 쌍을 추가 교정했다. 최종 이미지 각각에서 좌우4개의 보행 다리/발을 시각 확인했다. 발 구분을 위해 정면에 가까운 높은 시점으로 바꿨다. 얼굴·원형색·블록형 스타일·투명 배경을 이어간다. 픽셀 동일성은 보장하지 않는다.

[프롬프트/채택·미채택 원본](prompts/spiders-eight-legs-v3.json)과 [알파/해시 검사](manifest.json)를 기록했다. PNG4개 RGBA/투명 외부 검사 PASS. Webling·Silkweaver·Widow Queen의 네 모서리 알파는0이며 Barkstalker는 좌상단1/255, 나머지0이다. 이 미세 반투명 잔여를 수동 수정하지 않고 생성 원본을 보존했다. ZIP8개 CRC/각 SHA256 일치 PASS. 나머지4종은 직전 바이트를 유지했다. 기존6다리와 일반 지네 교정은 Git b943c40에 보존되며, 일반 지네의 축소/더듬이 수정은 현재 묶음에도 유지된다.3D 실제 관절·리그·모션은 후속 모델링 담당자의 검증 대상이다. 게임 빌드/게시/태그는 없다.
