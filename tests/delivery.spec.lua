local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local D=dofile('src/server/Lobby/DeliveryRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0
local function check(ok,label)checks=checks+1;assert(ok,label)end
local config={codes={THRONE={rewards={gold=50,diamonds=2,items={{definitionId='iron_ore',quantity=5}}},expiresAt=1000}},mails={
 {id='notice',title='News',body='Hello',rewards={}},
 {id='gift',title='Gift',body='A gift',userIds={[51]=true},rewards={gold=10}},
 {id='private',title='Private',body='Secret',userIds={[99]=true},rewards={gold=99}},
}}
local function claim(p,kind,value,request,now,catalog)
 return D.claim(p,kind,value,now or 500,catalog or config,R,C,request)
end
local p=R.new(51)
check(D.valid(p),'legacy profile accepts optional ledger')
check(D.normalize(' throne \n')=='THRONE','normalizes ASCII case and outer whitespace')
for _,bad in ipairs({'',' ',string.rep('a',65),'a b','<script>','가나다'})do check(not D.normalize(bad),'rejects malformed code')end
local n=assert(claim(p,'Redeem',' throne ','one'))
check(p.wallet.gold==0 and not p.deliveries,'input profile untouched')
check(n.wallet.gold==50 and n.wallet.diamonds==2,'server reward credited')
local quantity=0
for _,item in pairs(n.items)do check(item.location.kind=='pending','attachment retained without hero or bag space');quantity=quantity+item.quantity end
check(quantity==5 and R.validate(n,C)and D.valid(n),'account item and receipt validate together')
local replay,e,repeated=claim(n,'Redeem','THRONE','one',2000,{codes={},mails={}})
check(replay and not e and repeated and replay.wallet.gold==50,'same request recovers after expiry or campaign removal')
local duplicate,reason=claim(n,'Redeem','throne','different')
check(not duplicate and reason=='AlreadyRedeemed','different request cannot reuse same code')
local _,expired=claim(p,'Redeem','THRONE','expired',1000)
check(expired=='InvalidCode','expiry boundary is exclusive')
local _,invalid=claim(p,'Redeem','UNKNOWN','invalid')
check(invalid=='InvalidCode','unknown code grants nothing')
local other=R.new(52);local claimed=assert(claim(other,'Redeem','THRONE','other'))
check(claimed.wallet.gold==50,'a different account can use same promotion once')
local private,denied=claim(p,'ClaimMail','private','forged')
check(not private and denied=='MailUnavailable','targeted mail enforces recipient')
config.codes.THRONE.userIds={[51]=true}
local _,codeDenied=claim(other,'Redeem','THRONE','forged')
check(codeDenied=='InvalidCode','targeted code enforces account eligibility')
local notice=assert(claim(n,'ClaimMail','notice','read'))
check(notice.wallet.gold==50,'announcement read does not invent reward')
local gift=assert(claim(notice,'ClaimMail','gift','gift'))
check(gift.wallet.gold==60,'mail reward committed')
local _,again=claim(gift,'ClaimMail','gift','newgift')
check(again=='MailAlreadyClaimed','mail cannot duplicate gift')
local view=D.project(gift,config,500,R)
check(#view.mails==2 and view.unread==0,'private mail hidden and received badge cleared')
check(not view.codes,'code catalog never projected')
local overflow=R.copy(p);overflow.wallet.gold=1e12
local _,limit=claim(overflow,'Redeem','THRONE','limit')
check(limit=='BalanceLimit'and not overflow.deliveries,'balance cap retains unclaimed entitlement')
local corrupt=R.copy(p);corrupt.deliveries={['code:THRONE']={at=1}}
check(not D.valid(corrupt),'malformed ledger rejected')
local full=R.copy(p);full.deliveries={}
for i=1,D.maxReceipts do full.deliveries['mail:'..i]={at=1,requestId='r'..i}end
local _,fullError=claim(full,'Redeem','THRONE','full')
check(fullError=='ReceiptLimit','full ledger rejects grants without deleting old receipts')
local db,fail={},false
local adapter={UpdateAsync=function(_,key,callback)
 local result=callback(db[key]and R.copy(db[key]));if result then db[key]=R.copy(result)end
 if fail then error('acknowledgement lost')end;return result
end}
local store=Store.new(adapter,R,C,function()return 500 end,function()end,'a')
assert(store:open(51));fail=true
local lost,unknown=store:transact(51,function(current)return claim(current,'Redeem','THRONE','lost')end)
check(not lost and unknown=='SaveUnknown','lost acknowledgement is uncertain')
check(db['account:51'].wallet.gold==50,'retry loop credits once even if committed before error')
fail=false
local recovered,err,replayed=store:transact(51,function(current)return claim(current,'Redeem','THRONE','lost')end)
check(recovered and not err and replayed and recovered.wallet.gold==50,'same logical request recovers without duplicate')
local second=Store.new(adapter,R,C,function()return 500 end,function()end,'b')
local blocked,busy=second:open(51)
check(not blocked and busy=='AccountBusy','simultaneous server cannot bypass account fence')
assert(store:close(51));local rejoined=assert(second:open(51))
local _,rejoinReason=claim(rejoined,'Redeem','THRONE','rejoin')
check(rejoinReason=='AlreadyRedeemed'and rejoined.wallet.gold==50,'rejoin preserves permanent used-code record')
-- Ordinary operation history rotation must not discard promotion receipts.
rejoined.operations={};rejoined.operationOrder={}
local _,retained=claim(rejoined,'Redeem','THRONE','rotation')
check(retained=='AlreadyRedeemed','receipt independent of bounded inventory operation history')
db['account:53']=corrupt;db['account:53'].userId=53
local badStore=Store.new(adapter,R,C,function()return 500 end,function()end,'bad')
local unavailable,badReason=badStore:open(53)
check(not unavailable and badReason=='Incompatible'and db['account:53'].deliveries,'incompatible saved ledger never reset')
print('Delivery: '..checks..' checks passed')
