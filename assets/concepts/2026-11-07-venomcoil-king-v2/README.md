# Venomcoil King 보스 확대 시안 v2

2026-11-07 · TLT-065/venomcoil-king-v2 · 내장 image_gen 사용.

사용자가 Venomcoreking으로 지칭한 보스를 기존 Venomcoil King 자산과 대조했다. 일반보다 작고 약해 보인다는 리뷰에 따라 몸통 마디와 다리 수를 늘리고, 몸통을 길고 두껍게, 다리를 더 길고 굵게 만든 3D 스타일 참고 PNG다. 기존 왕관 갑각·금색 테두리·보라색 눈·상아색 턱·붉은 갑각을 이어간다.

- 결과: [VenomcoilKing-v2.png](VenomcoilKing-v2.png)
- 입력: `../2026-11-07-gloamwood-individuals-v1/VenomcoilKing.png`
- 전체 생성 프롬프트: [prompt.txt](prompt.txt)
- 생성 원본: `/Users/daniel/.codex/generated_images/01a1b944-bb31-7320-9af5-9c667ee31b9b/exec-998a9a06-8cec-4760-b3f3-f0f2a186a06a.png`

시각 검토에서 긴 굴곡형 몸통·다수의 다리·강화된 앞몸통과 왕관을 확인했다. 프롬프트의 약20마디/20쌍은 생성 목표이며 정확한 해부 구조나 메시 개수의 실측값이 아니다.

검증: `sips -g hasAlpha -g pixelWidth -g pixelHeight`와 Python 표준 라이브러리 PNG IDAT 해제/필터 복원으로 1536×1024 RGBA, 알파0~254, 완전 투명666644픽셀, 네 모서리 알파0을 확인했다. 생성 PNG 바이트를 그대로 복사했다. 원본 자산은 보존한다.

범위는 투명 PNG 제작 완료다. 실제3D 메시·리그·게임 크기·전투 능력치·Studio 적용/게시·사용자 미술 수용은 미검증이며 게임 빌드나 릴리스가 아니다. 다음 담당은 사용자/3D 담당의 시안 검토와 후속 모델 제작이다.
