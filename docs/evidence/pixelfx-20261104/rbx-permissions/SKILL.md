# MCP Permissions — `rbx-permissions` 관련 지침 발췌

출처: 2026-11-04 Roblox Studio MCP `skill(skill_name="rbx-permissions")` 도구 응답. 공식 지침 중 이번 권한 오류에 적용한 문구만 보존한 발췌이며, 개인 스킬 설치나 권한 부여를 수행하는 파일이 아니다.

## Errors

3. **`The current thread cannot call '<function>' (lacking capability <capability>)`**: only `Network` can be granted, under *Connect to the internet*. Other capabilities can't be, so say so.

## Don't circumvent permission controls

Permission settings are the user's choice:
- **Don't start a playtest, or otherwise run the game, to do a blocked operation from game code.** It may not be subject to the same gates.
- Don't try other APIs, endpoints, domains or execution contexts to get the effect of something the user *blocked*.
- If the user declines, accept it.

Using a Studio tool after an endpoint refuses a *granted* scope is fine; the user didn't block it.
