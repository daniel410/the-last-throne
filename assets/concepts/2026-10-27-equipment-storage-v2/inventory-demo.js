(function(root){
'use strict';
const slots=['weapon','offhand','head','body','hands','feet','accessory1','accessory2'];
function createState(){return {level:5,classId:'knight',safe:true,bagCapacity:60,storageCapacity:120,items:[
{id:'starter',name:'수련 기사의 검',slot:'weapon',location:'equipped',equippedSlot:'weapon',level:1,classId:'knight',qty:1,max:1,locked:true,power:12},
{id:'shield',name:'수련 방패',slot:'offhand',location:'equipped',equippedSlot:'offhand',level:1,classId:'knight',qty:1,max:1,locked:true,power:3},
{id:'ring-equipped',name:'결의의 반지',slot:'accessory',location:'equipped',equippedSlot:'accessory1',level:5,classId:'all',group:'resolve-ring',qty:1,max:1,locked:false,power:4},
{id:'sword',name:'서약 수호검',slot:'weapon',location:'bag',level:5,classId:'knight',qty:1,max:1,locked:false,power:18},
{id:'helm',name:'왕도 견습 투구',slot:'head',location:'bag',level:5,classId:'all',qty:1,max:1,locked:false,power:4},
{id:'wand',name:'공명 수습지팡이',slot:'weapon',location:'bag',level:5,classId:'mage',qty:1,max:1,locked:false,power:18},
{id:'ring',name:'결의의 반지',slot:'accessory',location:'bag',level:5,classId:'all',group:'resolve-ring',qty:1,max:1,locked:false,power:4},
{id:'ore',name:'철광석',slot:'material',location:'bag',level:0,classId:'all',qty:120,max:999,locked:false,power:0},
{id:'stat',name:'스탯 리셋권',slot:'consumable',location:'bag',level:0,classId:'all',qty:2,max:99,locked:false,power:0,paid:true},
{id:'ore-store',name:'철광석',slot:'material',location:'storage',level:0,classId:'all',qty:900,max:999,locked:false,power:0},
{id:'boots',name:'왕도 견습 장화',slot:'feet',location:'storage',level:5,classId:'all',qty:1,max:1,locked:true,power:4},
{id:'paid-skill',name:'스킬 리셋권',slot:'consumable',location:'pending',level:0,classId:'all',qty:1,max:99,locked:false,power:0,paid:true}
],nextId:1};}
function count(s,location){return s.items.filter(i=>i.location===location).length;}
function find(s,id){return s.items.find(i=>i.id===id);}
function validateEquip(s,id,target){let i=find(s,id);if(!i)return '아이템이 없습니다';if(!s.safe)return '전투 중 변경 불가';if(i.location!=='bag')return '가방으로 먼저 꺼내세요';if(!slots.includes(target))return '슬롯을 선택하세요';if(i.slot==='accessory'?!target.startsWith('accessory'):i.slot!==target)return '이 슬롯에는 장착할 수 없습니다';if(i.classId!=='all'&&i.classId!==s.classId)return '현재 클래스와 맞지 않습니다';if(s.level<i.level)return 'Lv'+i.level+' 필요';if(i.group&&s.items.some(j=>j.location==='equipped'&&j.equippedSlot!==target&&j.group===i.group))return '같은 고유그룹이 이미 장착돼 있습니다';return '';}
function equip(s,id,target){const err=validateEquip(s,id,target);if(err)return err;let i=find(s,id),old=s.items.find(j=>j.location==='equipped'&&j.equippedSlot===target);if(old){old.location='bag';delete old.equippedSlot;}i.location='equipped';i.equippedSlot=target;return '장착 완료 · 이전 장비는 가방으로 이동';}
function unequip(s,id){let i=find(s,id);if(!s.safe)return '전투 중 변경 불가';if(!i||i.location!=='equipped')return '장착된 아이템이 아닙니다';if(count(s,'bag')>=s.bagCapacity)return '가방 공간1칸이 필요합니다';i.location='bag';delete i.equippedSlot;return '해제 완료';}
function move(s,id,to,qty){let i=find(s,id);if(!s.safe)return '안전 거점에서 이용';if(!i||!['bag','storage','pending'].includes(i.location)||!['bag','storage'].includes(to)||i.location===to)return '이동 위치를 확인하세요';if(!Number.isInteger(qty)||qty<=0||qty>i.qty)return '올바른 수량을 선택하세요';const cap=to==='bag'?s.bagCapacity:s.storageCapacity;const candidates=s.items.filter(j=>j.id!==id&&j.location===to&&j.name===i.name&&j.max>1&&j.max===i.max&&!!j.paid===!!i.paid&&j.locked===i.locked);const room=candidates.reduce((n,j)=>n+j.max-j.qty,0);const newSlots=Math.ceil(Math.max(0,qty-room)/i.max);if(count(s,to)+newSlots>cap)return '공간 부족 · 이동/수령을 취소하고 원본 유지';let remaining=qty;for(let j of candidates){let n=Math.min(remaining,j.max-j.qty);j.qty+=n;remaining-=n;if(!remaining)break;}while(remaining){let n=Math.min(remaining,i.max);s.items.push({...i,id:i.id+'-m'+s.nextId++,location:to,qty:n});remaining-=n;}i.qty-=qty;if(!i.qty)s.items=s.items.filter(j=>j.id!==id);return '이동/수령 완료 · 잠금 상태 유지';}
function toggleLock(s,id){let i=find(s,id);if(!i)return '아이템 없음';i.locked=!i.locked;return i.locked?'잠금: 판매 제외,장착/창고 이동 가능':'잠금 해제';}
const api={slots,createState,count,find,validateEquip,equip,unequip,move,toggleLock};if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.InventoryDemo=api;
})(typeof globalThis==='undefined'?this:globalThis);
