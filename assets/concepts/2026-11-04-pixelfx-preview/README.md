# PixelFX 적용 후보 미리보기

2026-11-04 · TLT-005/032/033/055/057/084 · 효과 제작 시안, 게임 미적용

- [6종 애니메이션](preview.gif) / [정적 요약](overview.png)
- [로컬 갤러리](index.html): 재생/정지·배경색 비교. 파일을 브라우저에서 직접 열 수 있다.
- [도입 검토·검증·한계](../../../docs/research/2026-11-04-pixelfx-review.md)
- [원천/옵션/프레임](manifest.json) / [생성 파일 SHA256](sha256.json) / [MIT 고지](LICENSE.pixelfx.txt)

픽셀 효과 자체를 렌더링한 개발 검토 보드다. 실제 Roblox 화면이나 TD 메뉴 미리보기가 아니다. 금빛 기사/치유와 원본 드워프/엘프/화염/냉기6종을 제공한다. 현재 시트는 일반 PixelFX 출력이며 Roblox용 셀·여백·해상도 재패킹과 자산 업로드가 필요하다.

원천 커밋: `patch-gg/pixelfx@a84159688af3ca37a4be05a0d422b94451b2e24e`.
재현: Node18 이상과 Pillow가 있는 Python으로 `tools/render-pixelfx-review.py <고정 PixelFX 체크아웃>`을 실행한다. 원본 코드는 임시 체크아웃에서 실행하며, 이 폴더에는 파생 효과와 MIT 고지를 보관한다.

6개 기본 효과의 공식 검사는 통과했다. 브라우저 열기는 Work의 로컬 브라우저 비활성 설정으로 검증하지 못했다. 실제 게임·기기·최종 미술 수용은 남아 있다. 새 게임 빌드/릴리스가 아니므로 VERSION·릴리스 태그를 변경하지 않았다.
