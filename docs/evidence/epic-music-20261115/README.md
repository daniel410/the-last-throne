# TD 신규 음악의 TLT 에픽 연결

2026-11-15 · TLT-061/062/063/064/084-MUSIC-20261115 · ENG · **소스 구현/회귀 통과, 실제 음원 연결 대기**

사용자 지시: TD에 새로 만든 맵별 음악을 TLT 에픽별로 재사용하고 기존 일반곡은 로비/로딩, 기존 보스곡은 보스전에 유지한다. 사용자 후속 답변으로 신규5곡은 업로드 전임을 확인했다. 이번 변경은 지정된 원본의 동기화와 재생 경로 연결이며 새로운 게임성 규칙/작곡 설계는 하지 않았다.

변경 범위는 `DeepwoodMusicPolicy`, `K0BackgroundMusic`, 클라이언트 시작/ReplicatedFirst 로딩, 두 프로젝트의 로딩 의존성, 신규 WAV/원본 레지스트리와 관련 검사/기록이다. 기존 미커밋 이미지/Blender 자산 변경은 포함하지 않았다. TD는 읽기만 했다.

| TLT 에픽 | TD 테마 | 신규 곡 |
| --- | --- | --- |
| Deepwood | forest | Paths Beneath the Leaves |
| Frozen Vale | snow | Where the Snow Remembers |
| Ember Caldera | volcano | Heart of the Caldera |
| Haunted Graveyard | cemetery | The Lantern Keeper's Waltz |
| Gloamwood | gloamwood | Between Seven Silver Threads |

WAV5개를 [원본 매니페스트](../../../assets/audio/td-map-themes-v2/manifest.json)의 SHA-256 그대로 복사했다. TD 소스 HEAD는 이전 커밋이므로 실제 읽은 작업 트리/상위 원본 매니페스트 해시를 함께 고정했다. 음원 가공/재작곡/별도 업로드는 없다. 사용자 요청이 원본 재사용의 근거이며, TLT Experience의 재생 권한 확인을 대신하지 않는다.

재생은 실제 `CampaignBiome`의 지형/연결로 기준으로 선택해 도보 이동을 반영한다. 로비·입장 덮개·여행/귀환·사망/훈련에서는 Riftstorm `73105938035554`, 자격을 만족한 보스 교전에서는 기존 Throne Under Siege `120016858360297`을 유지한다. 준비되지 않은 보스곡은 지역곡, 지역곡도 준비되지 않았으면 기존곡으로 복귀한다. 현재 신규ID는 전부0이므로 게임의 일반 배경음은 아직 Riftstorm이다. 정상ID가 없는 상태를 실제 새음악 연결로 보고하지 않는다.

ReplicatedFirst가 기존 일반곡을 일찍 재생하고 클라이언트가 같은 Sound를 인계해 로비에서도 재생한다. 보스 전환 조건/볼륨0.20/페이드1.5초를 보존했다. 각 음원은 개별 비동기 preload하고, 반복 관측은 음악을 재시작하지 않는다. 신규 Sound는 양수ID만 생성한다.

## 검증

[소스 회귀 출력](source-checks.txt). `lua`는 Roblox 대역을 사용하는 소스 실행이며 Studio/실제 오디오 재생이 아니다.

- `lua tests/epic-background-music.spec.lua`: 실제 클라이언트 선택/시작 코드, 실제 캠페인 구역 이동, 5곡/보스 우선, 로딩 덮개·Teleport 실패·훈련·사망, 지연 로드/실패 fallback, 반복/늦은 fade 완료·Sound 인계/정리. **신규ID910001~910005는 테스트 전용 가상값**이다.
- 기존 정책/늦은 스토리 Remote/입장 화면/프레젠테이션 격리 회귀.
- WAV5개 SHA-256·2채널/44.1kHz/16-bit PCM 일치, 프로젝트 정본/호환 사본 동일, LFS 포인터/스테이징 diff 검사.

## 남은 연결과 다음 담당

2026-11-15 읽기 전용 Open Cloud GET probe에서 `asset:read`, `asset:write`, `asset-permissions:write`가 각각 미허용으로 반환됐다. 사용한 endpoint는 `/cloud/v2/universes/10773575153`; 현재 연결된 TD QA Studio를 인증 수단으로만 사용했고 해당 문서/게임/권한은 변경하지 않았다. 사용자 인증정보·대체 API·브라우저 우회는 시도하지 않았다.

다음 담당 ENG/원본 업로드 담당: Roblox Assistant의 MCP Permissions에서 Publish & manage assets의 `asset:read`(업로드 상태), `asset:write`(업로드), `asset-permissions:write`(해당 음원의 TLT Experience 사용권한)를 허용하고 TD 원본 폴더를 업로드 디렉터리로 허용해야 한다. 권한 부여 후 TD 원본의 개인 소유 Restricted/공개 노출 OFF 정책을 유지해 업로드하고 TLT Universe `10773575153`에 사용권한을 연결한다. 이미 TD에서 업로드했다면 동일5개 ID를 재사용하며 중복 업로드하지 않는다.

발급ID를 `Policy.epicIds`와 매니페스트에 반영한 뒤 TLT Studio 로드, 실제 게시 테스트 클라이언트의 로비→로딩→5지역→보스→지역 복귀, PC/폰 청취·SFX 균형·장기 반복을 확인한다. 현재 Studio/게시 클라이언트/실기기/사용자 청취는 미검증이다. 새 빌드·버전 증가·태그·Place 게시를 하지 않았다. 상위 티켓/G5/G7은 완료 처리하지 않는다. 복구는 본 작업의 소스/원본 등록을 revert하면 된다.
