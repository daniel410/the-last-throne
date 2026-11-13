# 선별 무료 VFX 게임 입력

2026-11-12 · TLT-033/057. [선정 검토](../../../docs/research/2026-11-12-free-roblox-vfx-review.md), [원천·해시·업로드ID·권리](source-manifest.json).

- Yuruzuu Healing Effect의4 emitter와 Arrow Rain의3 emitter 디자인을 추출했다. 치유는 MINT 상승12입자·최대0.2stud 십자2개, 화살비는 펄스당5낙하/5접촉광/5파편이다. 원본 수명·크기 곡선/텍스처에서 색·속도·크기·방출 수·위치를 조정했다. 원본 Place/조명/캐릭터/스크립트는 게임 입력에 포함하지 않는다.
- Frost Ring은 지면의8개 얼음 면과8개 작은 파편 입자를 사용한다. 원근이 그려진 Frost Nova PNG는 출처 확인용으로만 보존하고 런타임 참조/사전 로드에서 제외한다.
- ParticleFX Rolling Fireball Explosion의1024×1024·8×8 PNG는 원본 그대로 사용하며, 가림을 유지하는 BillboardGui/ImageLabel에서0.85초간64프레임을 재생한다. Bomb Toss의 큰 구형 면은 제거하고 작은 접촉 섬광·날아가는 파편과 조합한다. 라이브러리 재배포용 팩이 아니다.
- [제작자 Yuruzuu](https://devforum.roblox.com/t/yuruzuus-open-source-vfx/1840021): 게임 사용·수정 가능, 크레딧 선택, 본인 제작 주장 금지. 사용 파일은 같은 글의 제3자 미러에서 확보했으며 원본과 동일성을 증명하지 않았다.
- [ParticleFX 무료 팩](https://www.particlefx.studio/roblox/free-vfx-pack)의 ZIP README: 상업 게임 사용 가능, 크레딧 불필요, 팩 자체 재판매/재업로드 금지. 전체 ZIP은 저장소에 포함하지 않는다.

실행은 `CuratedVFX`/`HeroVFX`, 이벤트/수명은 기존 `PixelFX`와 공유한다. 서버 판정·지원 자격·피해·회복에 관여하지 않는다. [현재 미술 정리·검증·미검증](../../../docs/evidence/vfx-style-fit-20261112/README.md), [최초 도입/권리 확인](../../../docs/evidence/curated-vfx-20261112/README.md).
