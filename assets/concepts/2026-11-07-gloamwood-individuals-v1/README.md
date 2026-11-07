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
