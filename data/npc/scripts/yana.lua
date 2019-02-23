local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local tokenid = 25377
local player = {}
local weaponEnhanceChoose = {}
local weaponEnhance = {"destruction"}
local weaponTypeChoose = {}
local weaponType = {"axe", "blade", "bow", "chopper", "crossbow", "hammer", "mace", "rod", "slayer", "wand"}

local weapon = {
["axe"] = {destruction = {id = 30686}, price = 50,}, 
["blade"] = {destruction = {id = 30684}, price = 50,},
["bow"] = {destruction = {id = 30690}, price = 50,}, 
["chopper"] = {destruction = {id = 30687}, price = 50,}, 
["crossbow"] = {destruction = {id = 30691}, price = 50,}, 
["hammer"] = {destruction = {id = 30689}, price = 50,}, 
["mace"] = {destruction = {id = 30688}, price = 50,},
["rod"] = {destruction = {id = 30693}, price = 50,},						
["slayer"] = {destruction = {id = 30685}, price = 50,},
["wand"] = {destruction = {id = 30692}, price = 50}}

local function exchangeItem(cid)
	local playerToItem   = weapon[weaponTypeChoose[cid]]
	if weaponEnhanceChoose[cid] == "destruction" then
       playerToItem = weapon[weaponTypeChoose[cid]].destruction
	end
	local playerFromItem = playerToItem.id
	if player[cid]:removeItem(playerFromItem, 1) then
		if player[cid]:removeItem(tokenid, price) then
			if math.random(100) < chance then
				doPlayerAddItem(cid, playerToItem)
				return 1
			else
				return 2
			end
		else
			doPlayerAddItem(cid, playerFromItem)
			return 3
		end
	else
		return 4
	end
end
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end
local function greetCallback(cid)
	npcHandler.topic[cid] = 0
	return true
end
local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	elseif msgcontains(msg, "information") and npcHandler.topic[cid] == 0 then
		npcHandler:say({"Tokens are small objects made of metal or other materials. You can use them to buy superior equipment from {token} traders like me . . .", "There are several ways to obtain the tokens I'm interested in - killing certain bosses, for example. In exchange for a certain amount of tokens, I can offer you some {destruction} items."}, cid)
		npcHandler.topic[cid] = 1
	elseif npcHandler.topic[cid] == 1 and msgcontains(msg, "token") then
		npcHandler:say("If you have any {gold} tokens with you, let's have a look! Maybe I can offer you something in exchange.", cid)
		npcHandler.topic[cid] = 2
	elseif npcHandler.topic[cid] == 2 and msgcontains(msg, "gold") then
		npcHandler:say({"Here's the deal, Jess Leewyn. For 50 of your gold tokens, I can offer you some special equipment pieces which you can charge with a certain item type. I have the following item types to offer: {destruction}. ...", "I may also give you a short {description} what these labels mean. So, which item type are you most interested in?"}, cid)
		npcHandler.topic[cid] = 3
	elseif npcHandler.topic[cid] == 3 and msgcontains(msg, "description") then
		npcHandler:say({"A weapon of destruction increases your chance to hit harder and to enhance the damage you inflict. A weapon of remedy gives you a certain chance to gain a part of a creature's life energy for yourself. ...", "And a weapon of carving does the same with a creature's mana."}, cid)
	elseif msgcontains(msg, "gold") and npcHandler.topic[cid] == 0 then
		npcHandler:say("What weapon enhance would you like? We have {destruction}.", cid)
		npcHandler.topic[cid] = 1
	elseif	isInArray(weaponEnhance, msg:lower()) and npcHandler.topic[cid] == 1 then
		weaponEnhanceChoose[cid] = msg:lower()
		npcHandler:say(weaponEnhanceChoose[cid]:gsub("^%l", string.upper) .. " nice! Choose a weapon type: {axe}, {blade}, {bow}, {chopper}, {crossbow}, {hammer}, {mace}, {rod}, {slayer} or {wand}.", cid)	
		npcHandler.topic[cid] = 2
	elseif	isInArray(weaponType, msg:lower()) and npcHandler.topic[cid] == 2 then
		weaponTypeChoose[cid] = msg:lower()
		npcHandler:say(weaponTypeChoose[cid]:gsub("^%l", string.upper) .. " of " .. weaponEnhanceChoose[cid]:gsub("^%l", string.upper) .. " will cost " .. weapon[weaponTypeChoose[cid]].price .. " gold tokens. Would you like it?", cid)
		npcHandler.topic[cid] = 3
	elseif	msgcontains(msg, "yes") and npcHandler.topic[cid] == 3 then
		if player[cid]:removeItem(tokenid, weapon[weaponTypeChoose[cid]].price) then
			if weaponEnhanceChoose[cid] == "destruction" then
				doPlayerAddItem(cid,weapon[weaponTypeChoose[cid]].destruction.id)
			end
			npcHandler:say("There you go!", cid)
			npcHandler.topic[cid] = 0
		else
			npcHandler:say("You don\'t have enough gold tokens.", cid)
			npcHandler.topic[cid] = 0
		end
	return true
end
end

local function onAddFocus(cid)
	weaponEnhanceChoose[cid] = 0
	weaponTypeChoose[cid] = 0
	player[cid] = Player(cid)
end

local function onReleaseFocus(cid)
	weaponEnhanceChoose[cid] = nil
	weaponTypeChoose[cid] = nil
	player[cid] = nil
end

npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
