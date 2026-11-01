# NPC 얼굴 데칼 적용 조사

2026-11-01 · TLT-031/057/061/084 · ART/ENG → QA

사용자는 Selene를 제외한 NPC 외형 개선, 블록 몸체 유지, 컨셉에 가까운 데칼 얼굴과 Blender MCP 제작을 요청했다. 기존 [NPC 사례 조사](2026-10-31-npc-cast-and-services.md)의 역할/서비스 구분은 유지한다. 이번 비교는 기존 컨셉6보드와 실제 런타임 형상이다. 타 게임의 얼굴 자산을 복제하지 않는다.

[Roblox Decal 공식 문서](https://create.roblox.com/docs/reference/engine/classes/Decal)는 BasePart 면에 이미지 적용과 SurfaceGui/ImageLabel 대안을 설명한다. [텍스처 문서](https://create.roblox.com/docs/parts/textures-decals)는 메시 및 데칼 텍스처 스트리밍을 설명한다. 2026-11-01 검색 확인이며 직접 플레이 근거가 아니다.

기존 런타임은 흰자/홍채/동공/빛점/코/볼/입을 별도 구체로 쌓아 눈이 튀어나오고 얼굴이 분절돼 보인다. 채택안은 인물29명 표정의 투명 아틀라스1장과 둥근 머리, 입체 귀/헤어/수염이다. SurfaceGui의 ImageRectOffset/Size로229px 셀을 선택한다. AlwaysOnTop=false, LightInfluence=1로 가림과 지역 조명을 따른다. 몸체·소품·서비스·안정ID는 기존 계약이다.

대안인 개별 UV 메시29개는 얼굴 곡면/측면 완성도에 유리하지만 메시 업로드·권한·LOD 제작량이 증가한다. 이번에는 공유 이미지1장으로 적용했다. 정면 표정이 개선될 것으로 판단하나 평면 이미지의 비스듬한 시야와 세부 헤어는 한계가 있다. 추후 곡면UV 머리 메시가 필요한지 사용자 미술 수용으로 결정한다.

최소 검증은29개 고유 셀·이미지 로드, Selene 원본 보존, 블록 팔다리, 안전한 장식, 로비 서비스와 호위 피벗이다. 실제 모바일/GPU·다인/스트리밍·게시된 Battle 권한은 후속 검증이다.
