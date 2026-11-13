# rbx-permissions — 이번 작업에 적용된 원문 발췌

2026-11-12 Studio MCP `skill(skill_name="rbx-permissions")` 반환 지침에서 발췌. 현재 대화에서 조회한 원천의 증거이며 새 권한을 부여하는 문서가 아니다.

> Check what's granted, before acting
> Ask for exactly what's missing
> Permission settings are the user's choice
> Don't try other APIs, endpoints, domains or execution contexts to get the effect of something the user blocked.

원문은 Publish & manage assets의 `asset-permissions:write`를 자산 공유 변경 권한으로 구분한다. 2026-11-12 읽기 전용 범위 검사에서 다음 응답을 받았다.

```text
Could not acquire an Open Cloud access token: Scope 'asset-permissions:write' has not been granted. Ask the creator to grant the required scope in the Assistant MCP Permissions settings, then retry.
```

이를 근거로 새 이미지2개에 The Last Throne Experience 사용 권한을 추가할 수 있도록 이 토글만 요청했다. 다른 API나 실행 컨텍스트로 공유 변경을 우회하지 않는다.
