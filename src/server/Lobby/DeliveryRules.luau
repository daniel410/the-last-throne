-- Pure account transitions; wallet, pending items and permanent receipt share one key.
local Economy=game and require(game:GetService('ReplicatedStorage').Shared.EconomyRules)or dofile('src/shared/EconomyRules.luau')
local Grants=game and require(game:GetService('ReplicatedStorage').Shared.EquipmentTransactions)or dofile('src/shared/EquipmentTransactions.luau')
local D={maxReceipts=2000}
local function int(v,min,max)return type(v)=='number'and v==v and v%1==0 and v>=min and v<=max end
function D.normalize(raw)
 if type(raw)~='string'or #raw>64 then return nil end
 local code=raw:match('^%s*(.-)%s*$'):upper()
 if #code==0 or not code:match('^[%w_-]+$')then return nil end
 return code
end
function D.valid(p)
 if p.deliveries==nil then return true end
 if type(p.deliveries)~='table'then return false end
 local count=0
 for id,r in pairs(p.deliveries)do
  count=count+1
  if type(id)~='string'or #id>80 or type(r)~='table'or not int(r.at,0,1e12) or type(r.requestId)~='string' or #r.requestId==0 or #r.requestId>64 or not r.requestId:match('^[%w_-]+$')then return false end
 end
 return count<=D.maxReceipts
end
function D.eligible(entry,userId,now,isCode)
 return type(entry)=='table'and (not entry.userIds or entry.userIds[userId]==true)
  and (not entry.startsAt or now>=entry.startsAt)
  and (not isCode or not entry.expiresAt or now<entry.expiresAt)
end
function D.claim(p,kind,value,now,catalog,R,C,requestId)
 if type(requestId)~='string'or #requestId==0 or #requestId>64 or not requestId:match('^[%w_-]+$')then return nil,'InvalidRequest'end
 if not D.valid(p)or not int(now,0,1e12)then return nil,'Incompatible'end
 if kind~='Redeem'and kind~='ClaimMail'then return nil,'InvalidRequest'end
 local normalized=kind=='Redeem'and D.normalize(value)or value
 if type(normalized)~='string'or #normalized==0 or #normalized>64 or not normalized:match('^[%w_-]+$')then return nil,'InvalidRequest'end
 local key=(kind=='Redeem'and 'code:'or 'mail:')..normalized
 -- Check permanent receipts before availability, expiry or current campaign contents.
 if p.deliveries and p.deliveries[key]then
  if p.deliveries[key].requestId~=requestId then return nil,kind=='Redeem'and 'AlreadyRedeemed'or 'MailAlreadyClaimed'end
  return R.copy(p),nil,true
 end
 local entry
 if kind=='Redeem'then entry=catalog.codes[normalized]
 else for _,mail in ipairs(catalog.mails)do if mail.id==normalized then entry=mail;break end end end
 if not D.eligible(entry,p.userId,now,kind=='Redeem')then return nil,kind=='Redeem'and 'InvalidCode'or 'MailUnavailable'end
 local count=0;for _ in pairs(p.deliveries or {})do count=count+1 end
 if count>=D.maxReceipts then return nil,'ReceiptLimit'end
 local reward=entry.rewards or {};local gold,diamonds=reward.gold or 0,reward.diamonds or 0
 if not int(gold,0,1e9)or not int(diamonds,0,1e9)then return nil,'Unavailable'end
 local n=R.copy(p);Economy.upgrade(n)
 if n.wallet.gold+gold>1e12 or n.wallet.diamonds+diamonds>1e12 then return nil,'BalanceLimit'end
 local items=reward.items or {}
 if type(items)~='table'or #items>20 then return nil,'Unavailable'end
 for i,item in ipairs(items)do
  local def=C.items[item.definitionId]
  if not def or def.retired or not int(item.quantity,1,math.min(1000,def.maxStack*20))then return nil,'Unavailable'end
  -- Gifts go to the existing account delivery queue, independent of selected hero/bag space.
  if not Grants.grant(n,R,C,nil,item.definitionId,item.quantity,'delivery:'..key..':'..i,true)then return nil,'Unavailable'end
 end
 n.wallet.gold=n.wallet.gold+gold;n.wallet.diamonds=n.wallet.diamonds+diamonds
 n.deliveries=n.deliveries or {};n.deliveries[key]={at=now,requestId=requestId};n.revision=n.revision+1
 return n
end
function D.project(p,catalog,now,R)
 local mails={};local unread=0
 for _,entry in ipairs(catalog.mails)do
  if D.eligible(entry,p.userId,now,false)then
   local claimed=p.deliveries and p.deliveries['mail:'..entry.id]~=nil or false
   if not claimed then unread=unread+1 end
   table.insert(mails,{id=entry.id,title=entry.title,body=entry.body,sender=entry.sender,
    rewards=R.copy(entry.rewards or {}),claimed=claimed})
  end
 end
 return {status='Ready',mails=mails,unread=unread}
end
return D
