#!/usr/bin/env python3
"""Render the applied planning budget from the validator output."""
from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[1]
def main():
 d=json.loads((ROOT/'assets/balance/epics-01-04-progression.json').read_text());rows=d['rows'];summary=d['summary']
 s='''# 프롤로그+에픽1~4 스토리별 Coins·XP·예상 레벨 · 반영 기준

문서 묶음 v0.23 · 2026-10-27, America/Toronto · 상태: 사용자 승인 기획 반영, 런타임/플레이테스트 전

[프롤로그/튜토리얼](prologue-dawnspire-tutorial.md) · [아이템/수익화](items-and-monetization.md) · [정본 보상 데이터](../assets/balance/story-reward-budget.json) · [표 보기](../assets/balance/epics-01-04-progression.html) · [검증 결과](../assets/balance/epics-01-04-progression.json) · [계산기](../scripts/simulate_story_progression.py) · [표 생성기](../scripts/render_story_progression_report.py)

## 1. 반영 범위

기존28스토리의 반영XP를 유지하고 요청된 Dawnspire 프롤로그4구간의 배분안을 앞에 연결했다. 프롤로그 수치/동선은 신규 상세 제안이며 연속32구간으로 검증한다. 각 시나리오·에픽 보상표·시나리오JSON이 정본 보상 데이터와 일치한다. 코인 초회 보상은 유지한다. 아래 ‘이전’은 폐기된 퍼센트 표를 환산한 비교 기록이고 ‘반영’이 현재 기획값이다. 원본 아카이브·TD 지갑·게임 런타임에는 쓰지 않았다.

Coins는 RPG의 일반 영속 재화로 골드 역할을 한다. TD 전투용 Gold와 별도 잔액이며 명칭 변경/지갑 통합은 하지 않았다. Diamonds는 별도 공통 계정 지갑이다.

## 2. 반영한 계산 기준

- LvN→N+1 필요XP = `100 + 25 × (N−1)`. 프롤로그+에픽1~4의 Lv1~40 기획 기준이다. Lv41~80 콘텐츠 수용까지 검증했다는 뜻은 아니다.
- 일반 적XP=`8 + 2 × 적 레벨`, 일반 적Coins=`3 + floor(적 레벨/2)`. 보스/유효 비살상 승리는 각각5배XP/10배Coins를 적용한 기획 기준이다. 실제 종별 시간/난도는 플레이테스트로 조정할 수 있다.
- Lv1·0XP·0Coins에서 프롤로그4구간과28스토리를 순차 수행한다. 프롤로그 완료는Lv5·0XP·총유입198Coins이며 해당 상태를 그대로 Deepwood에 이관한다. 남은XP는 다음 스토리로 이월하며 매번 레벨/XP를 초기화하지 않는다. 표의 시작/완료Lv는 반영값을 계속 적용한 한 실행이다.
- 퀘스트XP는 고정 정수 지급이다. 일반 스토리 반복 퀘스트XP는25% 정수 내림/Coins30%,안전 거점은0이다. 프롤로그 재현은 퀘스트와 처치 모두XP/Coins0이며 초회 논리 처치 수령 기록으로 재시도 파밍을 막는다. 처치/보스 보상은 별도 유효 참여/수령 기록으로 처리한다.
- 레벨업마다 스탯4P/스킬1P를 지급하며 Lv5누적16/4P,Lv40누적156/39P다. 실제 투자와 미배분 잔액은 별도다. 개인 유효 참여자는 전액 지급받고 파티 인원으로 나누지 않는다. 보호/회복/조사도 참여이고 막타 경쟁은 없다. 실제 참여/리조인 판정 구현은 별도 검증한다.
- 선택 적/선택 보스·리젠·슬라임 자식·랜덤 전리품·판매·부스터·장비 가치는 예산에서 제외했다. DW-01은 필수 공터3마리만,EC-01은 선택Lava Slime을 빼고 계산한다. 나머지 필수 경비전/고정 증원은 시나리오 배치 초안이다. 구현에서 우회 가능한 적이 더 있으면 재검증해야 한다.
- Coins는 소비 전 **총유입**이다. 필수 전직/재도전은 무료이고 확정 배분 초기화는 판매 리셋권을 소비한다. 선택 리셋권/장비 구매는 기본 경로에 넣지 않아 필수 비용은0이다. 선택 물약/제작/재련·재료 가격을 차감한 실제 잔액은 아직 미검증이다.

## 3. 검증 결과와 한계

반영값은32구간의 목표 완료 레벨을 모두 만족하며 마지막은Lv40·0XP다. 목표는 다음 구간 추천 하한과 에픽 끝12/20/30/40을 기준으로 정했다. 이전표 비교 실행은 목표 미달6곳/초과9곳이며 마지막Lv39·652/1,050XP다.

현재 검증기는 **보상을 자동으로 재보정하지 않는다.** 고정 지급값을 읽고 예상 레벨/데이터 일치를 검증하며 불일치하면 실패한다. 원래 보정값이 목표에 맞춰 산출됐으므로 이 결과는 산술 일관성 검증이고 독립적인 재미/경제/성장 속도 수용은 아니다. 실제 전투 시간·무료 장비의 난도·죽음/재접속·소비 가격은 구현 후 측정해야 한다.

'''
 s+=f'프롤로그 포함 초회 퀘스트Coins **{d["quest_coins_total"]:,}** + 처치Coins **{summary["gross_coins_draft"]-d["quest_coins_total"]:,}** = 총유입 **{summary["gross_coins_draft"]:,}**. 이전 퀘스트XP 합계 **{summary["quest_xp_total_existing"]:,}**, 반영 퀘스트XP 합계 **{summary["quest_xp_total_proposed"]:,}**.\n\n'
 s+='''## 4. 스토리별 반영표

총XP=반영 퀘스트XP+필수 전투XP. 총Coins=퀘스트Coins+처치Coins. 이전후Lv는 처음부터 이전 보상표만 적용한 별도 실행의 비교 결과다. 이월XP/정밀 상태는 HTML/JSON에 표시한다.

| ID | 시작Lv | 퀘스트Coins | 처치Coins | 총Coins | 이전퀘스트XP | 전투XP | 반영퀘스트XP | 반복퀘스트XP | 총XP | 이전후Lv | 반영후/목표Lv | 누적 스탯/스킬P |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
'''
 for q in rows:s+=f'| {q["id"]} | {q["start_adjusted"]["level"]} | {q["quest_coins"]} | {q["kill_coins_draft"]} | {q["total_coins_draft"]} | {q["existing_quest_xp"]} | {q["combat_xp_draft"]} | {q["applied_quest_xp"]} | {q["repeat_quest_xp"]} | {q["total_adjusted_xp"]} | {q["baseline_finish"]["level"]} | {q["adjusted_finish"]["level"]}/{q["target"]} | {q["cumulative_stat_points_earned"]}/{q["cumulative_skill_points_earned"]} |\n'
 s+='''
## 5. 재생성과 변경 관리

프로젝트 루트에서 `python3 scripts/simulate_story_progression.py` 후 `python3 scripts/render_story_progression_report.py`를 실행한다. 정본은 `assets/balance/story-reward-budget.json`이고 퍼센트 표에서 지급값을 다시 만들지 않는다. 시나리오/몹 배치/지급값을 변경하면 문서·시나리오JSON을 함께 수정하고 검증해야 한다. 목표 레벨을 맞추기 위해 검증기가 보상을 몰래 바꾸지 않는다. 실제 플레이테스트 결과로 기준을 바꿀 때는 변경 이유와 새 결과를 기록한다.
'''
 (ROOT/'docs/story-progression-budget.md').write_text(s)
 h='''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>에픽1~4 반영된 성장 예산</title><style>body{margin:0;padding:28px;background:#08101e;color:#e7edf2;font:15px/1.6 system-ui,sans-serif}h1{color:#deb96a}a{color:#c3b5ff}.wrap{overflow:auto}table{border-collapse:collapse;min-width:1550px;width:100%}th,td{padding:12px;border-bottom:1px solid #354762;text-align:right;white-space:nowrap}th{background:#141d2d;position:sticky;top:0}td:first-child,td:nth-child(2){text-align:left}.applied{color:#a9dfba}small{color:#9cb9d2}</style><h1>프롤로그+에픽1~4 · 반영된 스토리 성장 예산</h1><p class="applied">v0.23 · 사용자 승인 기획 반영 완료 · 32/32 목표 레벨 일치</p><p>실제 게임 지급/플레이테스트는 아직이다. Coins는 TD Gold와 별도인 RPG 일반 재화이며 총Coins는 소비 전 유입량이다.</p><p><a href="../../docs/story-progression-budget.md">기준/상세 설명</a> · <a href="story-reward-budget.json">정본 지급값</a> · <a href="epics-01-04-progression.json">검증 JSON</a></p>'''
 h+=f'<p>퀘스트Coins {d["quest_coins_total"]:,} + 처치Coins {summary["gross_coins_draft"]-d["quest_coins_total"]:,} = 총 {summary["gross_coins_draft"]:,} · 이전표: 미달6/초과9 · 반영표: 전 구간 목표 일치</p><div class="wrap"><table><thead><tr>'
 heads=['스토리','이름','시작Lv','퀘스트Coins','처치Coins','총Coins','누적Coins','이전 퀘스트XP','전투XP','반영 퀘스트XP','반복 퀘스트XP','총 반영XP','이전후Lv','반영후Lv','이월XP','목표Lv','누적 스탯P','누적 스킬P']
 h+=''.join('<th>'+x+'</th>' for x in heads)+'</tr></thead><tbody>'
 for q in rows:
  vals=[q['id'],q['name'],q['start_adjusted']['level'],q['quest_coins'],q['kill_coins_draft'],q['total_coins_draft'],q['cumulative_gross_coins_draft'],q['existing_quest_xp'],q['combat_xp_draft'],q['applied_quest_xp'],q['repeat_quest_xp'],q['total_adjusted_xp'],q['baseline_finish']['level'],q['adjusted_finish']['level'],f'{q["adjusted_finish"]["xp_in_level"]}/{q["adjusted_finish"]["next_level_xp"]}',q['target'],q['cumulative_stat_points_earned'],q['cumulative_skill_points_earned']]
  h+='<tr>'+''.join('<td>'+html.escape(str(v))+'</td>' for v in vals)+'</tr>'
 h+='</tbody></table></div><p><small>목표에 맞춘 보정값의 산술 검증이다. 실제 성장 속도/난도/경제 검증을 대신하지 않는다.</small></p></html>'
 (ROOT/'assets/balance/epics-01-04-progression.html').write_text(h)
if __name__=='__main__':main()
