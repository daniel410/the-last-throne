-- Server-only campaigns. Published IDs/codes are immutable and never reused.
-- Rewards: {gold=0, diamonds=0, items={{definitionId='iron_ore', quantity=1}}}.
-- Optional startsAt/expiresAt are UTC Unix seconds; userIds is a set of numeric IDs.
-- Mail attachments do not expire. Close eligibility with startsAt/userIds, not deletion.
return {
 codes={},
 mails={
  {id='welcome-v1',title='Welcome to The Last Throne',
   body='Welcome, adventurer! Check your mailbox for news and gifts from The Last Throne team. Promotional codes can be entered in Redeem Code. Thank you for joining us!',
   sender='The Last Throne Team',rewards={}},
 },
}
