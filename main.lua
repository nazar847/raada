---@diagnostic disable: undefined-global, need-check-nil, redundant-parameter
require 'addon'
require 'LGBTQ'
local servers = require 'servers'
local effil = require 'effil'
local json = require("dkjson")
local ffi = require('ffi')
local sampev = require('samp.events')
local encoding = require('encoding')
local http = require('socket.http')
local md5 = require('md5')
local https = require("ssl.https")
local ltn12 = require('ltn12')
encoding.default = 'CP1251'
local u8 = encoding.UTF8
LGBTQ_start('PeReKiD by LoveKa2')

local timeTP, stepTP = 45, 2
local LastCollectAll = false
local goToAbrakham = false

local Accounts = {}
local NowAccount = {index=0, password=''}
local email = {}
local InventMode = "AZ"
local IsLast = false
local AzCoins, exp
local Taked = {}
local key
local last_code = 1111111
local launcher_emulator = false
local BASE_URL = "https://api.mail.tm"

math.randomseed(os.time())

function sampev.onSendSpawn()
	newTask(function ()
		if getBotInterior() == 0 then
			-- wait(11000)
			sendInput('/accepttrade')
		end
	end)
end

function sampev.onSendPlayerSync(data)
	if key then
        data.keysData = key
        key = nil
    end
end

local items = {
	["1102"] = "Тактический бронежилет",
	["1057"] = "Пояс боеприпасов",
	["1114"] = "Мусорный нимб",
	["1101"] = "Тактический шлем",
	["1089"] = "Маска череп",
	["15411"] = "Скин: Катсу (ID: 862)",
	["15410"] = "Скин: Ися (ID: 861)",
	["3140"] = "Скин: Ричи (ID: 344)",
	["15715"] = "Скин: Хиток (ID: 869)",
	["1069"] = "Анимированная пчела",
	["1058"] = "Экзоскелет",
	["1047"] = "Оружие Бамбли Би",
	["1070"] = "Паучьи лапы",
	["1099"] = "Складная мусорная лавка",
	["15623"] = "Воздушный шар Бомж",
	["15412"] = "Скин: Sam Mason Военный (ID: 863)",
	["15409"] = "Скин: Гоуст (ID: 860)",
	["15441"] = "Скин: Коннор Военный (ID: 865)",
	["14303"] = "Объект: Надпись Лето",
	["14311"] = "Объект: Дерево Сакура",
	["19468"] = "Кусок редкой ткани",
	["items:item_crystal_clover"] = "Осколок читерского Clover",
}

function sampev.onShowTextDraw(textdrawId, data)
	if InventMode == 'AZ' then
		if data.modelId == 1274 then
			newTask(function ()
				wait(250)
				if doesTextdrawExist(textdrawId+1) then
					local textDrawAzCoins = getTextdraw(textdrawId+1)
					printk(textDrawAzCoins.text .. ' az')
					AzCoins = tonumber(textDrawAzCoins.text)
				end
				sendClickTextdraw(textdrawId)
				wait(150)
				sendClickTextdraw(textdrawId)
			end)
		end
	end
	if InventMode == "TRUNK" then
		if (items[tostring(data.modelId)] or items[data.text]) then
			printk((data.position.x > 320 and not IsLast) and 'True' or 'False')
			if data.position.x > 320 and not IsLast then
				printk('Кладу в багажник ' .. (items[tostring(data.modelId)] or items[data.text]))
				InventMode = 'CLOSE'
				sendClickTextdraw(textdrawId)
				sendClickTextdraw(textdrawId-1)
				newTask(function ()
					wait(1500)
					sendClickTextdraw(65535)
					sendClickTextdraw(65535)
				end)
			elseif data.position.x < 320 and IsLast then
				printk('Беру из багажника ' .. (items[tostring(data.modelId)] or items[data.text]))
				table.insert(Taked, (items[tostring(data.modelId)] or items[data.text]))
				newTask(function ()
					for i = 1, 3, 1 do
						wait(math.random(1, 1500))
						sendClickTextdraw(textdrawId)
						sendClickTextdraw(textdrawId-1)
					end
				end)
			end
		end
		if not IsLast then
			newTask(function ()
				local nick1 = getBotNick()
				wait(2500)
				if nick1 == getBotNick() then
					printk('Завис')
					NextAccount()
				end
			end)
		end
	end
	if textdrawId == 2302 then
		sendClickTextdraw(textdrawId)
		newTask(function ()
			wait(150)
			sendClickTextdraw(textdrawId)
			wait(200)
			if InventMode == 'CLOSE' then
				sendClickTextdraw(65535)
				sendClickTextdraw(65535)
			end
		end)
	end
end

function onRunCommand(cmd)
	if cmd:find('next') then
		NextAccount()
		return false
	end
end

function sampev.onServerMessage(color, text)
	if text:find('Действие невозможно, поскольку у вас не привязана к аккаунту почта') then
		printk('Ну хз')
		NextAccount()
	end
	if text:find('Вы исчерпали количество попыток%. Вы отключены от сервера') then
		NextAccount()
	end
	if text:find('%[Подсказка%]{......} У Вас не привязан e%-mail адрес%. Привяжите его \"/settings %- Безопасность аккаунта\"') then
		print('Почта не привязана')
		sendInput('/settings')
	end
	if text:find('^Вы сняли ограничение! Теперь вы можете торговать с игроками %(/trade %[id%]%)') or text:find('%[Ошибка%] {......}У Вас отсутствует ограничение по торговле') then
		newTask(function ()
			if not launcher_emulator then
				printk("Привязал почту")
				launcher_emulator = true
				reconnect()
			else
				wait(2000)
				InventMode = 'AZ'
				sendInput('/invent')
				if goToAbrakham then
					printk('Лечу к абрахаму или как там его')
					local toX, toY, toZ = 1103.5825195313, -1428.3907470703, 15.796875
					if not tpNEW(toX, toY, toZ, {
						401, 402, 403, 408, 410, 411, 412, 414, 415, 420,
						422, 423, 424, 429, 431, 433, 434, 436, 437, 438,
						439, 442, 443, 444, 445, 447, 451, 455, 456, 457,
						460, 462, 465, 469, 474, 475, 478, 480, 482, 483,
						489, 491, 494, 495, 496, 497, 499, 500, 502, 503,
						505, 506, 508, 514, 515, 517, 518, 524, 525, 526,
						527, 528, 533, 534, 535, 536, 537, 538, 549, 554,
						555, 556, 557, 558, 559, 560, 561, 562, 563, 565,
						573, 574, 575, 576, 577, 578, 579, 580, 587, 589,
						592, 593, 596, 597, 598, 599, 600, 601, 602, 603,
						604, 605, 15879, 547, 437, 431
					}) then
						coordStart(toX, toY, toZ, timeTP, stepTP, true)
						while isCoordActive() do
							wait(0)
						end
					end
					sendClickTextdraw(65535)
					sendClickTextdraw(65535)
					sendClickTextdraw(65535)
					for i = 1, 5, 1 do
						pickupNearestPickup()
						sendKey(1024)
						wait(200)
					end
					wait(250)
				end

				printk('Лечу к багажнику')
				prints('Скин: ' .. getBotSkin())
				local toX, toY, toZ = 1989.0831298828, -1983.9426269531, 13.546875
				if not tpNEW(toX, toY, toZ, {
					401, 402, 403, 408, 410, 411, 412, 414, 415, 420,
					422, 423, 424, 429, 431, 433, 434, 436, 437, 438,
					439, 442, 443, 444, 445, 447, 451, 455, 456, 457,
					460, 462, 465, 469, 474, 475, 478, 480, 482, 483,
					489, 491, 494, 495, 496, 497, 499, 500, 502, 503,
					505, 506, 508, 514, 515, 517, 518, 524, 525, 526,
					527, 528, 533, 534, 535, 536, 537, 538, 549, 554,
					555, 556, 557, 558, 559, 560, 561, 562, 563, 565,
					573, 574, 575, 576, 577, 578, 579, 580, 587, 589,
					592, 593, 596, 597, 598, 599, 600, 601, 602, 603,
					604, 605, 15879, 547, 437, 431
				}) then
					coordStart(toX, toY, toZ, timeTP, stepTP, true)
					while isCoordActive() do
						wait(0)
					end
				end
				sendClickTextdraw(65535)
				InventMode = 'TRUNK'
				local nearest = nil
				local nearest_dist = math.huge
				for id, v in pairs(getAllVehicles()) do
					local px, py, pz = getBotPosition()
					local dist = getDistanceBetweenCoords3d(v.position.x, v.position.y, v.position.z, px, py, pz)
					if dist < nearest_dist then
						nearest_dist = dist
						nearest = id
					end
				end
				sendInput('/trunk '..nearest)
				newTask(function ()
					if IsLast then
						wait(5000)
						if isBotConnected() then
							NextAccount()
						end
					end
				end)
			end
		end)
	end
	if text:find('Указаный вами код не соответвует') then
		reconnect()
	end
	if text:find('^Вы закончили свое лечение%.') then
		reconnect()
	end
	if text:find('^Повторно отправить письмо можно раз в 1 минуту%.') then
		reconnect()
	end
end

function sendKey(id)
    key = id
    updateSync()
end

function pickupNearestPickup()
    local function getDistance(a, b)
        return math.sqrt(
            math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2) + math.pow(b.z - a.z, 2)
        )
    end

    local pickups = {}
    local x, y, z = getBotPosition()
    for k, v in pairs(getAllPickups()) do
        local distance = getDistance({ x = x, y = y, z = z }, v.position)
        table.insert(pickups, { id = k, dist = distance, pos = v.position, model = v.model })
    end
    table.sort(pickups, function(a, b) return a.dist < b.dist end)
    local near = pickups[1]
    if near ~= nil then
        if near.dist <= 10 then
			sendPickedUpPickup(near.id)
		end
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if title:find('Авторизация') then
		sendDialogResponse(dialogId, 1, 0, NowAccount.password)
	end
	if title:find('Уведомление') then
		sendDialogResponse(dialogId, 1, 0, '')
	end
	if text:find('Введите количество, которое хотите положить') then
		sendDialogResponse(dialogId, 1, 0, tostring(NowAccount.kolvo))
	end
	if dialogId == 9898 then
		sendDialogResponse(dialogId, 1, 0, tostring(math.floor(getBotMoney()/82000)))
		-- newTask(function ()
		-- 	wait(1000)
		-- 	sendInput('/donate')
		-- 	wait(100)
		-- 	sendInput('/donate')
		-- end)
	end
	if dialogId == 25653 then
		sendDialogResponse(dialogId, 1, 0, tostring(exp))
	end
	if title:find('заблокирован') then
		printk('Аккаунт заблокирован')
		NextAccount()
	end
	if title:find('Выбор места спавна') then
		sendDialogResponse(dialogId, 1, 0, '')
	end
	if title:find('Багажник') then
		if text:find('Закрыт') then
			sendDialogResponse(dialogId, 1, 0, '')
		else
			if InventMode == 'TRUNK' then
				sendDialogResponse(dialogId, 1, 1, '')
			else
				-- sendDialogResponse(dialogId, 1, 0, '')
				NextAccount()
			end
		end
	end
	if title:find('Личные настройки') then
		sendDialogResponse(dialogId, 1, 6, '')
	end
	if text:find('Введите количество, которое хотите использовать') then
		sendDialogResponse(dialogId, 1, 0, tostring(AzCoins) or '1')
		-- newTask(function ()
		-- 	sendClickTextdraw(65535)
		-- 	wait(500)
		-- 	sendInput('/donate')
		-- 	wait(100)
		-- 	sendInput('/donate')
		-- end)
	end
	if title:find('Безопасность аккаунта') then
		local emailTied = false
		for line in text:gmatch('[^\n]+') do
			if line:find('E%-mail') then
				emailTied = not line:find('%[ %- %]')
				break
			end
		end
		printk('E-mail '..(emailTied and 'привязан' or 'не привязан'))
		sendDialogResponse(dialogId, emailTied and 0 or 1, 0, '')
	end
	if text:find('Привязать E%-mail') then
		printk('E-mail: '..email.email)
		sendDialogResponse(dialogId, 1, 0, email.email)
	end
	if text:gsub('{......}', ''):find('На ваш E%-MAIL') then
		if #email.email > 0 then
			newTask(function()
				wait(2500)
				local code = ''
				while #code == 0 do
					printk('Пытаюсь получить код...')
					local messages = get_messages(email.token)
					if messages then
						for _, msg in ipairs(messages) do
							print("Новое письмо от: " .. msg.from.address)
							print("Тема: " .. msg.subject)
							print("ID: " .. msg.id)
							if msg.from.address:find('noreply@arizona%-rp%.com') then
								local mail_text = get_message_body(email.token, msg.id)
								if mail_text then
									local temp_code = mail_text:match('(%d%d%d%d%d%d)')
									if temp_code and last_code ~= temp_code then
										code = temp_code
										last_code = temp_code
										printk('Код: '..code)
										sendDialogResponse(dialogId, 1, 0, code)
										if text:find('accepttrade') then
											sendInput('/accepttrade '..code)
										else
											sendInput('/accepttrade')
										end
										break
									end
								end
							end
						end
					end
					wait(15000)
				end
			end)
		else
			printk('Почта уже привязана')
			NextAccount()
		end
	end
end

function onReceivePacket(id, bs)
    if id == 220 then
        bs:ignoreBits(8)
        if bs:readInt8() == 17 then
            bs:ignoreBits(32)
            local len = bs:readInt32()
            if len > 0 and len < 4096 then
                local str = bs:readString(len)
                if str:find('npcDialog') then
					sendcef(string.format('answer.npcDialog|%d', 1))
					sendcef(string.format('answer.npcDialog|%d', 0))
				end
				local json_table = str:match("['`](%[.+%])['`]%);")
				local table = json_table and json.decode(json_table) or {}
				if str:match('event%.setActiveView') then
        			sendcef('onActiveViewChanged|'.. (table[1] or ''))
				end
				local AzCoins1 = tonumber(str:match('window%.executeEvent%(\'event%.donationshop%.ShopCountDonate\', %`%[%[ (%d+) %]%]%`%)%;'))
				if AzCoins1 then
					exp = math.floor(AzCoins1/3)
					printk(('Покупаю %d exp'):format(exp))
					newTask(function ()
						wait(500)
						sendcef("buyItemDonationButton|26|11")
						wait(250)
						closeCEF()
					end)
				end
			end
		end
	end
end

function closeCEF()
	local BITSTREAM = bitStream.new()
	BITSTREAM:writeInt8(220)
	BITSTREAM:writeInt8(24)
	BITSTREAM:writeInt8(0)
	BITSTREAM:writeInt8(0)
	BITSTREAM:writeInt8(0)
	BITSTREAM:writeInt8(0)
	BITSTREAM:writeInt8(0)
	BITSTREAM:sendPacketEx(1, 7, 1)
	BITSTREAM:reset()

	local BITSTREAM = bitStream.new()
	BITSTREAM:writeInt8(220)
	BITSTREAM:writeInt8(0)
	BITSTREAM:writeInt8(27)
	BITSTREAM:writeInt8(64)
	BITSTREAM:sendPacketEx(1, 7, 1)
	BITSTREAM:reset()
end

function sendcef(...)
	print('sendcef: ' .. ...)
	local bs = bitStream.new()
	bs:writeInt8(220)
	bs:writeInt8(18)
	bs:writeInt8(string.len(...))
	bs:writeInt8(0)
	bs:writeInt8(0)
	bs:writeInt8(0)
	bs:writeString(...)
	bs:writeInt32(0)
	bs:writeUInt8(0)
	bs:writeUInt8(0)
	bs:sendPacketEx(2, 9, 6)
	bs:reset()
end

function onPrintLog(...)
	if (...):find('%[SELECTABLE%-TEXTDRAW%]') then
		return false
	end
end

function reverseTable(tbl)
    local reversed = {}
    local n = #tbl

    for i = 1, n do
        reversed[i] = tbl[n - i + 1]
    end

    return reversed
end

function LoadAccounts()
	for account in io.lines('accounts.txt') do
		local ip, nick, password, kolvo, money = u8:decode(account):match('^(.+);(.+);(.+);(.+);(.+)')
		if ip and nick and password and kolvo and money and ip == getServerAddress() then
			table.insert(Accounts, {ip=ip, nick=nick, password=password, kolvo=kolvo, money=money})
		end
	end
	Accounts = reverseTable(Accounts)
	printk(("Загружен %d аккаунт(-ов). Сервер: %s"):format(#Accounts, servers[getServerAddress()]))
end

function deleteAccountLine()
    if (string.gsub(getBotNick(), ' ', '')) ~= 'nick' then
        local content = '';
        for _line in io.lines('accounts.txt') do
            if _line:find(getBotNick()) then
                if not _line:find(getServerAddress()) then
                    content = content.._line..'\n';
                end
            else
                content = content.._line..'\n';
            end
        end
        local file = io.open('accounts.txt', 'w')
        file:write(content);
        file:close();
    else
        printk('nick')
    end
end

function NextAccount()
	reconnect()
	if Accounts[NowAccount.index + 1] then
		NowAccount.index = NowAccount.index + 1
		local nick, password, kolvo = Accounts[NowAccount.index].nick, Accounts[NowAccount.index].password, Accounts[NowAccount.index].kolvo
		setBotNick(nick)
		NowAccount.password = password
		NowAccount.kolvo = kolvo
		printk(("Захожу на аккаунт %s (%sшт). Осталось %d аккаунтов"):format(nick, kolvo, #Accounts-NowAccount.index))
		InventMode = "AZ"
		IsLast = false
		launcher_emulator = false
		Taked = {}
		if LastCollectAll and NowAccount.index == #Accounts then
			IsLast = true
			printk('Включён сбор аксов на последнем аккаунте')
		end
		deleteAccountLine()
	else
		printk('Закончил')
		if IsLast then
			printk(('Все аксы на аккаунте %s'):format(Accounts[NowAccount.index].nick))
			SaveAcc()
		end
		newTask(exit, 5000)
	end
end

function onLoad()
	local email_, password_ = create_email()
	if email_ then
		local token_ = get_token(email_, password_)
		if token_ then
			email = {email=email_, password=password_, token=token_}
		else
			printe('Что-то пошло не так')
			newTask(exit, 1000)
		end
	else
		printe('Что-то пошло не так')
		newTask(exit, 1000)
	end
	LoadAccounts()
	NextAccount()
end

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function (method, url, args)
	   local requests = require 'requests'
	   local result, response = pcall(requests.request, method, url, args)
	   if result then
		  response.json, response.xml = nil, nil
		  return true, response
	   else
		  return false, response
	   end
	end)(method, url, args)
	-- Если запрос без функций обработки ответа и ошибок.
	if not resolve then resolve = function() end end
	if not reject then reject = function() end end
	-- Проверка выполнения потока
	newTask(function()
		local runner = request_thread
		while true do
			local status, err = runner:status()
			if not err then
				if status == 'completed' then
					local result, response = runner:get()
					if result then
					resolve(response)
					else
					reject(response)
					end
					return
				elseif status == 'canceled' then
					return reject(status)
				end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end

function SaveAcc()
    newTask(function ()
		local server = servers[getServerAddress()] or 'None'

        local lvl = getBotScore()

		local star = ''
		for _, v in ipairs(Taked) do
			star = star .. v .. ', '
		end

		local f2 = io.open('DoneAccounts.txt', "a")
		f2:write(("%s;%s;%s;%s;%s;%s"):format(server, getServerAddress(), getBotNick(), NowAccount.password, lvl, star) .. '\n')
		f2:close()

        prints('Сохранил аккаунт')

		wait(2000)
		exit()
    end)
end

function unicode_to_utf8(code)
	local t, h = {}, 128
	while code >= h do
	  t[#t+1] = 128 + code%64
	  code = math.floor(code/64)
	  h = h > 32 and 32 or h/2
	end
	t[#t+1] = 256 - 2*h + code
	return string.char(unpack(t)):reverse()
  end
  
function ununicode(str)
	local s = str:gsub('\\u(%x%x%x%x)', function (a)
	  return unicode_to_utf8(tonumber('0x' .. a))
	end) 
	return s
end

local ansi_decode = {[128] = '\208\130',[129] = '\208\131',[130] = '\226\128\154',[131] = '\209\147',[132] = '\226\128\158',[133] = '\226\128\166',[134] = '\226\128\160',[135] = '\226\128\161',[136] = '\226\130\172',[137] = '\226\128\176',[138] = '\208\137',[139] = '\226\128\185',[140] = '\208\138',[141] = '\208\140',[142] = '\208\139',[143] = '\208\143',[144] = '\209\146',[145] = '\226\128\152',[146] = '\226\128\153',[147] = '\226\128\156',[148] = '\226\128\157',[149] = '\226\128\162',[150] = '\226\128\147',[151] = '\226\128\148',[152] = '\194\152',[153] = '\226\132\162',[154] = '\209\153',[155] = '\226\128\186',[156] = '\209\154',[157] = '\209\156',[158] = '\209\155',[159] = '\209\159',[160] = '\194\160',[161] = '\209\142',[162] = '\209\158',[163] = '\208\136',[164] = '\194\164',[165] = '\210\144',[166] = '\194\166',[167] = '\194\167',[168] = '\208\129',[169] = '\194\169',[170] = '\208\132',[171] = '\194\171',[172] = '\194\172',[173] = '\194\173',[174] = '\194\174',[175] = '\208\135',[176] = '\194\176',[177] = '\194\177',[178] = '\208\134',[179] = '\209\150',[180] = '\210\145',[181] = '\194\181',[182] = '\194\182',[183] = '\194\183',[184] = '\209\145',[185] = '\226\132\150',[186] = '\209\148',[187] = '\194\187',[188] = '\209\152',[189] = '\208\133',[190] = '\209\149',[191] = '\209\151'}
function AnsiToUtf8(s)
  local r, b = '', ''
  for i = 1, s and s:len() or 0 do
    b = s:byte(i)
    if b < 128 then
      r = r .. string.char(b)
    else
      if b > 239 then
        r = r .. '\209' .. string.char(b - 112)
      elseif b > 191 then
        r = r .. '\208' .. string.char(b - 48)
      elseif ansi_decode[b] then
        r = r .. ansi_decode[b]
      else
        r = r .. '_'
      end
    end
  end
  return r
end

function threadHandle(runner, url, args, resolve, reject)
  local t = runner(url, args)
  local r = t:get(0)
  while not r do
    r = t:get(0)
    wait(0)
  end
  local status = t:status()
  if status == 'completed' then
    local ok, result = r[1], r[2]
    if ok then
      resolve(result)
    else
      reject(result)
    end
  elseif status == 'canceled' then
    reject(status)
  end
  t:cancel(0)
end

function requestRunner()
  return effil.thread(function(u, a)
    local https = require 'ssl.https'
    local ok, result = pcall(https.request, u, a)
    if ok then
      return {true, result}
    else
      return {false, result}
    end
  end)
end

function async_http_request(url, args, resolve, reject)
  local runner = requestRunner()
  if not reject then
    reject = function()
    end
  end
  newTask(function()
    threadHandle(runner, url, args, resolve, reject)
  end)
end

function getRandomWord(length)
	local chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
	local word = ''
	for i = 1, length do
		local random_index = math.random(1, #chars)
		word = word .. chars:sub(random_index, random_index)
	end
	return word
end

-- Функция для создания почтового ящика
function get_domains()
    local response_body = {}

    local _, status = https.request{
        url = BASE_URL .. "/domains",
        sink = ltn12.sink.table(response_body)
    }

    if status ~= 200 then
        print("? Ошибка получения доменов: " .. status)
        return nil
    end

    local domains = json.decode(table.concat(response_body))
    
    if not domains["hydra:member"] or #domains["hydra:member"] == 0 then
        print("? Нет доступных доменов")
        return nil
    end

    return domains["hydra:member"][1]["domain"]
end

-- Функция для создания временного почтового ящика
function create_email()
    local domain = get_domains()
    if not domain then return nil end

    local username = getRandomWord(10)
    local email = username .. "@" .. domain

    local post_body = json.encode({address = email, password = "password123"})
    local response_body = {}

    local _, status = https.request{
        url = BASE_URL .. "/accounts",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#post_body)
        },
        source = ltn12.source.string(post_body),
        sink = ltn12.sink.table(response_body)
    }

    if status ~= 201 then
        print("? Ошибка создания почты: " .. status)
        return nil
    end

    print("? Почта создана: " .. email)
    return email, "password123"
end

-- Функция для получения токена авторизации
function get_token(email, password)
    local post_body = json.encode({address = email, password = password})
    local response_body = {}

    local _, status = https.request{
        url = BASE_URL .. "/token",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#post_body)
        },
        source = ltn12.source.string(post_body),
        sink = ltn12.sink.table(response_body)
    }

    if status ~= 200 then
        print("? Ошибка получения токена: " .. status)
        return nil
    end

    local data = json.decode(table.concat(response_body))
    print("? Токен получен!")
    return data.token
end

-- Функция для получения писем
function get_messages(token)
    local response_body = {}

    local _, status = https.request{
        url = BASE_URL .. "/messages",
        headers = {
            ["Authorization"] = "Bearer " .. token
        },
        sink = ltn12.sink.table(response_body)
    }

    if status ~= 200 then
        print("? Ошибка получения писем: " .. status)
        return nil
    end

	response_body = u8:decode(table.concat(response_body))

    local messages = json.decode(response_body)
    
    if #messages["hydra:member"] == 0 then
        print("Нет новых писем.")
        return
    end

    for _, msg in ipairs(messages["hydra:member"]) do
        print("Новое письмо от: " .. msg.from.address)
        print("Тема: " .. msg.subject)
        print("ID: " .. msg.id)
    end
	return messages["hydra:member"]
end

function get_message_body(token, message_id)
    local response_body = {}

    local _, status = https.request{
        url = BASE_URL .. "/messages/" .. message_id,
        headers = {
            ["Authorization"] = "Bearer " .. token
        },
        sink = ltn12.sink.table(response_body)
    }

    if status ~= 200 then
        print("Ошибка получения письма: " .. status)
        return nil
    end

    local message = json.decode(u8:decode(table.concat(response_body)))
    print("Тема: " .. message.subject)
    print("Тело письма: " .. message.text)
	return message.text
end

function sampev.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, challengeResponse2)
	if launcher_emulator then
		newTask(Validation, 100)
		return {version, mod, nickname, challengeResponse, joinAuthKey, "Arizona PC", challengeResponse2}
	end
end

function sendGamePath()
    local server_ip, port = getServerAddress():match("(.*):(.*)")
    local player_name = getBotNick()
    local game_path = string.format("gta_sa.exe\" -c -h %s -p %d -n %s -mem 2048 -x -ldo -seasons -graphics -enable_grass -allow_hdr -arizona -referrer", server_ip, port, player_name)
    print("Fake game path: " .. game_path)
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(140)
    bs:writeInt32(#game_path)
    bs:writeString(game_path)
    bs:writeInt8(0)
    bs:sendPacket()
    bs:reset()
    print("Game path sended!")
end

function Validation()
    sendGamePath()
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(20)
    bs:writeInt8(128)
    bs:writeInt8(7)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(56)
    bs:writeInt8(4)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(38)
    bs:writeInt8(101)
    bs:writeInt8(7)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(56)
    bs:writeInt8(4)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(50)
    bs:writeInt8(1)
    bs:writeInt16(1)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local bs = bitStream.new() -- TEST
    bs:writeInt8(220)
    bs:writeInt8(10)
    bs:writeInt8(0)
    bs:writeInt16(1)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local bs = bitStream.new() -- TEST
    bs:writeInt8(220)
    bs:writeInt8(10)
    bs:writeInt8(1)
    bs:writeInt16(1)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local string = "svelteReady"
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(18)
    bs:writeInt8(string.len(string))
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeString(string)
    bs:writeInt32(1)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local string = "@0, vueReady"
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(18)
    bs:writeInt8(string.len(string))
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeString(string)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local string = "onActiveViewChanged|"
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(18)
    bs:writeInt8(string.len(string))
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeString(string)
    bs:writeInt8(1)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()

    local string = "onActiveViewChanged|Auth"
    local bs = bitStream.new()
    bs:writeInt8(220)
    bs:writeInt8(18)
    bs:writeInt8(string.len(string))
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:writeString(string)
    bs:writeInt8(1)
    bs:writeInt8(0)
    bs:writeInt8(0)
    bs:sendPacketEx(2, 9, 6)
    bs:reset()
end

function getDistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function samp_create_sync_data(sync_type)
	-- from SAMP.Lua
	local raknet = require 'samp.raknet'
	require 'samp.synchronization'

	local sync_traits = {
	  player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC },
	  vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC },
	  passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC },
	  aim = {'AimSyncData', raknet.PACKET.AIM_SYNC },
	  trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC },
	  unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC },
	  bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC },
	  spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC }
	}
	local sync_info = sync_traits[sync_type]
	local data_type = 'struct ' .. sync_info[1]
	local data = ffi.new(data_type, {})
	local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))

	-- function to send packet
	local func_send = function()
	  local bs = bitStream.new()
	  bs:writeUInt8(sync_info[2])
	  bs:writeBuffer(raw_data_ptr, ffi.sizeof(data))
	  bs:sendPacketEx(HIGH_PRIORITY, UNRELIABLE_SEQUENCED, 1)
	  bs:reset()
	end
	-- metatable to access sync data and 'send' function
	local mt = {
	  __index = function(t, index)
		return data[index]
	  end,
	  __newindex = function(t, index, value)
		data[index] = value
	  end
	}
	return setmetatable({send = func_send}, mt)
end

function onDisconnect()
	clearTasks()
end

function tpNEW(x, y, z, allow_models)
	return false
end