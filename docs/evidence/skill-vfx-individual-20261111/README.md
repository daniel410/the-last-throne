# 128개 스킬 개별 VFX 리뷰·개선

TLT-033/057 · 2026-11-11 · [스킬별 검토표128행](review.md) · [개별 제작값/판정 JSON](review.json) · [참고와 캡처 경로](../../research/2026-11-11-individual-vfx-review.md).

네 영웅32개씩 **128개 기술의 수정 전/후 고정 엔진 화면을 모두 관찰**했다. 반복 기술39개는 마지막 펄스도 관찰했다. 단순 생성 검사와 실제 픽셀 관찰을 구분하며, 전체 영웅 모션·사용자 미술 수용으로 게이트를 닫지 않는다.

## 실제 비교 화면

| 영웅·순서 | 이전 | 개선 |
| --- | --- | --- |
| Knight1~16 | [전](before/knight-1.png) | [후](after/knight-1.png) |
| Knight17~32 | [전](before/knight-2.png) | [후](after/knight-2.png) |
| Dwarf1~16 | [전](before/dwarf-1.png) | [후](after/dwarf-1.png) |
| Dwarf17~32 | [전](before/dwarf-2.png) | [후](after/dwarf-2.png) |
| Elf1~16 | [전](before/elf-1.png) | [후](after/elf-1.png) |
| Elf17~32 | [전](before/elf-2.png) | [후](after/elf-2.png) |
| Mage1~16 | [전](before/mage-1.png) | [후](after/mage-1.png) |
| Mage17~32 | [전](before/mage-2.png) | [후](after/mage-2.png) |

마지막 펄스: [Knight](last-pulse/knight-1.png), [Dwarf](last-pulse/dwarf-1.png), [Elf](last-pulse/elf-1.png), [Mage](last-pulse/mage-1.png). 개별 원본은 검토표의 각 행에 연결했다. 총 **전128장+후128장+마지막39장=295장**이다. 검토판은 해당 원본을 축소하지 않고 이름과 함께 배치한 것이다.

## 리뷰에서 반영한 변화

- `SkillVFXProfiles`에128개의 명시적 제작값을 두었다. 색만 바꾸던 공통 분기에서 벗어나 각 기술의 실루엣·리본 수/폭·수명을 지정했다. Wind Lance는 기존 별도 리본을 유지하고 장식 중복을 제거했다.
- 찌르기/수직 베기/교차/낮은 베기/방패 면/회전·함성을 구분했다. Sunward Cross의 실제 두 교차선, Low Sweep의 접지 높이, 방패의 공격축 방향을 확인했다. 기존 범위선은 얇고 투명하게 보조하도록 조정했다.
- 복귀 도끼의 두 번째 펄스를 반전했다. Chain Lightning은 확정 대상 사이만 연결하고 빈 대상에 전기 타격을 만들지 않는다. 서버의 교차 직선은 기존 단일18도 보정 계약을 유지한다.
- 원형·전방 균열, 공중 Stone Lance, 낙하 화살/불씨/우박을 분리했다. Ember Step/Frost Step의 장판은 현재 위치 대신 서버가 확정한 출발 중심을 사용한다.
- 스킬127개의 개별 제작값·연출을 조정하고 Wind Lance1개는 유지했다. 실제 연결은 advanced 이벤트, 공통 근접 속성, 확정 영역, 일반 발사체 경로를 사용한다. 공통 Multi Shot은 주 화살1개와 서버 추가4개만 장식해 합성 부채 중복을 방지했다. 일반 마법탄/도끼는 기존 발사체 도착과 연결했다.
- 1차 수정 후 화면에서 Cinder Ring/Ember Step/Searing Ward의 큰 별 모양 선 겹침을 확인해 짧게 솟는 불꽃으로 재수정·재촬영했다. Provoke는 전체 파문을 보기 좋게 카메라만 재구도했다.

서버 피해·사거리·범위·쿨다운·MP·해금·소유/저장/상품/TD 운영은 변경하지 않았다. 추가 장식의 글로벌 상한은 기존 PC12/터치8효과, PC240/터치144 Beam, 파편48개다. 기술별 최대48 Beam은 Oath of Dawn의4고리에 사용되며 글로벌 상한 안에서 생략될 수 있다.

## 검증과 재현

| 항목 | 실제 결과 |
| --- | --- |
| 128기술 생산 장식·실제 advanced 연결·공통 근접 연결·정리/충돌/거리/중복 | 5,132검사 통과 |
| 개별 계약: 귀환·실제 체인 연결/빈 체인·출발 장판·돌창·교차검·낮은 베기·산탄·방패 방향·공통1+4화살 | 295검사 통과 |
| 기존 Wind Lance / 명중 표현 | 98 / 102검사 통과 |
| 효과 CPU / advanced 규칙 / 영웅 성장 | 15,938 / 1,435 / 3,711검사 통과 |
| 변경 Luau7개 컴파일 | 통과 |

엔진 합계 **5,627검사**. [엔진 로그](native.log), [정적/CPU 로그](source-checks.log). 생산 모듈과 실제 엔진을 호출했지만 입력·캐릭터·서버 이벤트 인자는 fixture이며 네트워크 전송 자체를 검증한 것은 아니다.

```bash
python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-vfx-review
# 출력된 run-in-roblox 명령 실행: 기본은 엔진 회귀
python3 tools/prepare-hero-vfx-native.py --output /tmp/tlt-vfx-frames --review-mode frames
# 출력 명령의 stdout을 /tmp/tlt-vfx-frames.log로 저장
# Pillow가 있는 Python으로 복원
python3 tools/decode-skill-vfx-captures.py /tmp/tlt-vfx-frames.log /tmp/tlt-vfx-png
# 반복 기술만 캡처할 때 --review-mode last-pulse 사용
```

MCP는 계속 `Place is not open`이었고 새 StudioCaptureService는 미지원이었다. 공식 CaptureService의 임시 이미지를 EditableImage로 읽은 **실제 엔진 픽셀**을 사용했다. 로컬 fixture만 열었고 게시·실계정·TD 데이터에 접근하지 않았다. `run-in-roblox`는 사용한 QA 세션을 종료했다.

[이전 입력](before-inputs.json), [1차 개선 입력](first-after-inputs.json), [최종 엔진 입력](final-inputs.json)을 보존한다. after의4개 이미지는 최종 재촬영으로 교체했고 manifest에 표시했다. 마지막 펄스는 화염 보정 후 생산 VFX 모듈을 사용했다. 일반 Multi Shot 연결 보정은 이후 엔진295검사에 포함했으며 정적 샘플의 직접 호출 연출은 동일하다. 각 폴더 manifest의 SHA-256으로 개별 이미지 바이트를 검증할 수 있다.

## 빌드·미검증·다음 담당

**0.104.1 로컬 빌드 통과**, 입력 커밋 `bfa0dc4c33d71a6e8ed4f66da76abff88a5a0099`. [명령·출력 SHA-256](build.json). `builds/0.104.1/TheLastThrone-0.104.1.rbxlx`에서 엔진5,627검사를 재실행해 모두 통과했다. [빌드 파일 엔진 로그](build-native.log). 최종 검사 입력354개가 빌드 소스와 해시 일치한다. Roblox 게시·릴리스 태그는 만들지 않았다.

이 캡처는 합성 회색 캐릭터 옆의 효과를 고정한 장면이다. advanced 기술은 실제 생산 이벤트 렌더러를 호출했고, 최초 공통3개 기술은 VFX 장식층을 직접 호출했다. 실제 공통 발사 연결은 별도 엔진 검사로 확인했다. 실제 영웅 리그/무기/모션 전체, 모든 중간 애니메이션 프레임,1~4인+AI의 중첩, 모바일/저사양 P95 성능, 낮은/높은 그래픽 품질과 게시 클라이언트·사용자 수용은 **미검증**이다. 적 위험 예고의 가림과 화면 흔들림 수용을 고정 프레임만으로 통과시키지 않는다. 일부 긴 사거리 샘플은 검토 바닥 가장자리가 보이며 맵 미술 평가에 사용하지 않는다.

다음 담당 QA/사용자는 위 조건의 실제 플레이·동영상으로 모션 접점/잔상 시간·예고 가림·성능을 수용한다. 회귀가 있으면 클라이언트 VFX 변경 커밋을 되돌릴 수 있으며 서버 데이터 이관은 없다.
