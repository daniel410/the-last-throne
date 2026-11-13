# 선별 무료 VFX 게임 입력

2026-11-12 · TLT-033/057. [선정 검토](../../../docs/research/2026-11-12-free-roblox-vfx-review.md), [원천·해시·업로드ID·권리](source-manifest.json).

- Yuruzuu Healing Effect의4 emitter와 Arrow Rain의3 emitter 디자인을 추출했다. 원본 수명·크기 곡선/텍스처를 참고하고 MINT/자연색·속도·방출 수·위치를 게임에 맞게 축소했다. 치유16입자, 화살비는 펄스당5낙하/5접촉광/5파편이다. 원본 Place/조명/캐릭터/스크립트는 게임 입력에 포함하지 않는다.
- ParticleFX Frost Nova/ Rolling Fireball Explosion의1024×1024·8×8 PNG를 게임 입력으로 보존한다. 텍스처는 원본 그대로며, 가림을 유지하는 BillboardGui/ImageLabel에서0.6/0.85초간64프레임을 재생한다. 네이티브 파티클 플립북 표현을 찾지 못하는 오류가 있어 기존 이미지 프레임 방식을 사용한다. 라이브러리 재배포용 팩이 아니다.
- [제작자 Yuruzuu](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021): 게임 사용·수정 가능, 크레딧 선택, 본인 제작 주장 금지. 사용 파일은 같은 글의 제3자 미러에서 확보했으며 원본과 동일성을 증명하지 않았다.
- [ParticleFX 무료 팩](https://www.particlefx.studio/roblox/free-vfx-pack)의 ZIP README: 상업 게임 사용 가능, 크레딧 불필요, 팩 자체 재판매/재업로드 금지. 전체 ZIP은 저장소에 포함하지 않는다.

실행 코드는 `src/client/CuratedVFX.luau`, 이벤트/수명은 기존 `PixelFX`에서 관리한다. 서버 판정·지원 자격·피해·회복에 관여하지 않는다. [구현 검증과 미검증](../../../docs/evidence/curated-vfx-20261112/README.md).
