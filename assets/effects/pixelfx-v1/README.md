# PixelFX 게임용 효과 v1

2026-11-04 · TLT-005/032/033/055/057/084 · 로컬 구현·미게시

20종의 투명512×512 PNG에128×128 셀16개(4×4)를 배치했다. 각 셀은4px 이상 투명 여백을 두고 원본 종횡비를 유지한다. 원본의 긴 준비 동작은 잘라 기존 서버 타격 시각부터 재생하는 짧은 보조 효과로 만들었다. 실제3D 무기·발사체·바닥 범위·적 예고를 대체하지 않는다.

- [원천 커밋·재생 구간·팔레트·PNG 해시·Roblox 자산ID](source-manifest.json)
- [20종 보드](../../../docs/evidence/pixelfx-20261104/runtime-textures.png)
- [128스킬 대응표](../../../docs/evidence/pixelfx-20261104/coverage.json)
- [구현/검증/제한](../../../docs/evidence/pixelfx-20261104/README.md)
- [MIT 고지](LICENSE.pixelfx.txt): Patch/Hugo Duprez. 런타임 `PixelFXAssets.luau`에도 전문을 포함했다.

재생기는 Roblox의 occluded BillboardGui/ImageLabel로 셀을 선택한다. 동시에24개, 카메라80stud 밖 생략, 크기6stud 이하, 수명1.6초 이하이며 중단/사망/새 행동/스트리밍 해제 때 정리한다. 이 수치는 구현 예산이며 모바일 성능 측정 결과가 아니다. 추가 효과가 생략되거나 이미지 로드가 실패해도 기존3D 연출은 유지한다.

재현: `node tools/export-pixelfx-runtime.mjs <고정 PixelFX 체크아웃>`. 원천은 `patch-gg/pixelfx@a84159688af3ca37a4be05a0d422b94451b2e24e`다. PNG 바이트가 이전과 같은 경우에만 기존 업로드ID를 보존한다. 새 PNG는 반드시 새로 업로드해 매니페스트와 `src/shared/PixelFXAssets.luau`를 함께 갱신한다.
