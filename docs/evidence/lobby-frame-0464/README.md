# 로비 중복 테두리 빌드 0.46.4

- 작업: 사용자 요청 / TLT-028 관련 / 로컬 시험 빌드. 소스 커밋 `303d75d4d62390e1251ee73c4af61dde346549f5`, Rojo 7.7.1. 별도 브랜치에서 확정 소스로 빌드했으며 진행 중인 0.47.0 작업은 포함하지 않았다.
- `rojo build default.project.json -o builds/0.46.4/TheLastThrone-Lobby-0.46.4.rbxlx`: 성공. SHA-256 `3f4449744a6697f935b7874d10f72fbb2b8c5eba8830e3c2b5572887c66a6f76`.
- `rojo build battle.project.json -o builds/0.46.4/TheLastThrone-Battle-0.46.4.rbxlx`: 성공. SHA-256 `0edc3f6ff21c8da05bb7e2c39301da9522c90235c1148298ab0801c366387540`.
- 로비 산출물에서 중복 테두리 제거 코드가 포함된 것을 텍스트 검색으로 확인. Studio Play 시각·입력, 게시 클라이언트와 실기기는 미검증. 다음 담당: QA. 게시·릴리스 태그 없음.
