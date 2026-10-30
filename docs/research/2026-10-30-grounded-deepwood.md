# Deepwood: 열린 지상 숲길과 밝은 낮 시야

2026-10-30 · TLT-005/031/050/061/084 · RESEARCH/DES/ENG → QA.

사용자는 공중 섬처럼 보이는 전투 지형, 맵 밖 낙하 사망, 바닥 아래를 보는 카메라를 지적했다. 이어 **다리 양옆 벽의 답답함과 어두운 안개를 거부하고 다른 솔루션을 요청**했다. 최신 방향은 **넓은 지상 숲길·열린 길가·흙 둔덕·밝은 낮·아주 먼 배경만 옅은 하늘색 처리**다.2D 지도와 별도의 실제3D/물리/카메라 작업이다.

## 조사한 사실과 선택

| 공식 자료 ·2026-10-30 확인 | 관찰 사실 | 적용 판단 |
| --- | --- | --- |
| [Diablo IV 환경 제작 설명](https://news.blizzard.com/en-us/article/23788294/diablo-iv-quarterly-updatemarch-2022) | 연속된 월드, 자연스러운 색, 소품/조명으로 지역을 구분하는 제작 방식을 설명한다. | 허공의 좁은 다리를 **폭96studs의 잔디 지지 지형**으로 바꾸고 중앙24studs 길을 남긴다. 실제 TD 나무와 바깥쪽 흙 둔덕으로 방향을 읽게 한다. |
| [Roblox 야외 조명](https://create.roblox.com/docs/tutorials/use-case-tutorials/lighting/enhance-outdoor-environments) | Ambient는 나무 밑/가려진 공간, OutdoorAmbient는 하늘이 보이는 공간의 밝기에 영향을 준다. | 녹색 색보정과 어두운 근거리 안개를 빼고 낮14시·밝은 환경광을 사용한다. 태양 밝기만 높여 나무 밑이 검게 남는 접근을 피한다. |
| [Diablo IV VFX/가독성](https://news.blizzard.com/en-us/article/23746639/diablo-iv-quarterly-updatedecember-2021) | 자연 조명에만 맞추면 전투 효과가 읽히지 않을 수 있어 몰입과 가독성 사이 균형을 설명한다. | 정상 전투 거리에는 안개를 적용하지 않는다. 예고/주문/적을 가리는 어두운 분위기를 기본값으로 삼지 않는다. |
| [Roblox Lighting/FogEnd](https://create.roblox.com/docs/reference/engine/classes/Lighting#FogEnd), [Atmosphere](https://create.roblox.com/docs/reference/engine/classes/Atmosphere) | 거리 안개와 공기 산란은 다른 수단이며 Atmosphere가 있으면 거리 안개 속성이 가려진다. | 근거리 안개가 아닌 **180~340studs 밖의 밝은 하늘색 원경 페이드**만 사용한다. 기존 Atmosphere/Sky는 모험 중 로컬 보관하고 거점/훈련 때 복구한다. |
| [카메라 제어](https://create.roblox.com/docs/tutorials/use-case-tutorials/input-and-camera/control-the-users-camera), [RenderPriority](https://create.roblox.com/docs/reference/engine/enums/RenderPriority), [Spherecast](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#Spherecast) | 기본 카메라 뒤의 시점 보정이 가능하며 같은 우선순위는 순서가 고정되지 않는다. 구체 쓸기는 최초 겹침을 검출하지 않는다. | 기본 조작 뒤 Camera+2에서 살아 있는 모험 시점만 제한한다. 반경0.6 충돌과 끝점 겹침을 검사한다. 장애물 없는 회전은22~72도/최대18studs이며 가까운 충돌에서는 더 가까운 안전 시점으로 물러난다. 사망/Scriptable 카메라는 건드리지 않는다. |
| [Roblox Terrain](https://create.roblox.com/docs/reference/engine/classes/Terrain), [스트리밍 기법](https://create.roblox.com/docs/workspace/streaming/techniques) | 지형 채우기와 쐐기형 경사가 가능하며 Persistent 모델은 메모리에서 퇴거되지 않는다. | 큰 공유 Terrain 재작성 대신 기존 목표 높이를 보존하는 네이티브 기반·잔디 어깨·쐐기 흙 경사를 선택했다. 단순 지지체304개만 상주시키고 숲/둔덕은 스트리밍한다. 성능 개선량은 미측정이다. |

위 자료는 공식 설명을 읽은 사례 조사다. 직접 비교 게임을 플레이하거나 흥행/접근성/성능의 성공 인과관계를 측정한 것은 아니다.

## 대안 비교와 최종 구현

| 접근 | 판단 |
| --- | --- |
| 좁은 다리의 높은 벽/난간 | 사용자 거부. 연결 길에서 모두 제거했다. |
| 투명 벽으로 기존 다리만 막기 | 시각적으로 보이지 않는 곳에 막히고 지형이 공중에 떠 있는 근본 원인이 남으므로 선택하지 않았다. |
| 짙고 어두운 안개로 허공 숨기기 | 사용자 거부. 근경과 녹색 색보정을 제거했다. |
| 넓은 지상길+흙 경사+먼 수목/낮은 둔덕+안전 복구 | 채택. 길 중앙에서 양옆을 개방하고 이탈할 때는 마지막 정상 지면으로 복구한다. 아주 먼 배경만 밝게 사라진다. |

기존 지면은10개의 얇은 지역 블록과 폭24studs 다리였다. 이제 전체 배경 바닥과 지역/길 아래 흙을 채우고, 실제 지역 가장자리 높이끼리 경사로를 연결한다.10구역의 X/Z/높이와 목표/보상은 보존한다. 길 밖 배경 숲은 새 스토리 우회로가 아니며 실제 허용 공간/선행은 서버가 확인한다. 낙하 또는 이탈 위치를 안전 위치로 저장하지 않는다. HP/MP·보상·성장은 복구로 변하지 않는다.

검토용 Studio에 남은 초기 생성 지형도 감지해 구형 난간/길 벽을 제거하고 넓은 지형으로 갱신한다. TD maps/forest-kit의 현재SHA256은 기존 manifest와 일치했고 공유 원본은 수정하지 않았다.

## 검증과 한계

최종 엔진 검사와 실제 Play 관찰은 [수용 기록](../evidence/deepwood/grounded-0390/README.md)에 연결한다. Play의 계정/스토리는 합성 대역이며 실제 기본 아바타/입력/물리/카메라로 개방 길 이동, 최대 줌과 위/아래 회전, 맵 밖/지면 아래 주입 후 복구를 관찰한다. 본편 정상 완주·실기기/패드·4인 스트리밍/FPS·최종 미술 사용자 수용은 후속 QA다. 게시된 Place와 라이브 저장소는 이 로컬 작업으로 변경하지 않는다.
