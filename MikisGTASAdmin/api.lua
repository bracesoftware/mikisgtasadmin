local __MGSAAPI__ = {}

local MGSA_CHAT_OPEN = false
local MGSA_DIALOG_OPEN = false
function __MGSAAPI__.wait(what) wait(what) end
----------------------------------------------------------

local function MGSA_IsValidPointer(pointer)
    return pointer ~= nil and pointer ~= MGSA_FFI.NULL
end

function __MGSAAPI__.isSampLoaded()
    if not MGSA_SAMP_API or
       type(MGSA_SAMP_API.GetBase) ~= "function" then
        return false
    end

    local ok, base = pcall(MGSA_SAMP_API.GetBase)

    return ok and type(base) == "number" and base ~= 0
end


local function MGSA_GetSampVersion()
    if not MGSA_SAMP_API or
       type(MGSA_SAMP_API.GetSAMPVersion) ~= "function" then
        return nil
    end

    local ok, version = pcall(MGSA_SAMP_API.GetSAMPVersion)

    if not ok then
        return nil
    end

    return version
end

local function MGSA_GetRefObject(refFunction)
    if type(refFunction) ~= "function" then
        return nil
    end

    local ok, pointer = pcall(refFunction)

    if not ok or not MGSA_IsValidPointer(pointer) then
        return nil
    end

    if MGSA_GetSampVersion() == 3 then
        local derefOk, object = pcall(function()
            return pointer[0]
        end)

        if not derefOk or not MGSA_IsValidPointer(object) then
            return nil
        end

        return object
    end

    return pointer
end


--------------------------------------------------------
function __MGSAAPI__.isSampAvailable()
    if not __MGSAAPI__.isSampLoaded() then
        return false
    end

    if not MGSA_CNetGame or
       type(MGSA_CNetGame.RefNetGame) ~= "function" then
        return false
    end

    local netgame = MGSA_GetRefObject(
        MGSA_CNetGame.RefNetGame
    )

    return MGSA_IsValidPointer(netgame)
end


-----------------------------------------------------
local CHAT_TYPE_DEBUG = 8

local function normalizeColor(color)
    if type(color) ~= "number" or color == -1 then
        return 0xFFFFFFFF
    end

    if color >= 0 and color <= 0xFFFFFF then
        return 0xFF000000 + color
    end

    return color
end
-----------------------------------------------------
function __MGSAAPI__.sampAddChatMessage(text, color)
    if not __MGSAAPI__.isSampAvailable() then
        return false
    end

    local ok, result = pcall(function()
        local chat = MGSA_GetRefObject(MGSA_CChat.RefChat)

        if chat == nil or chat == MGSA_FFI.NULL then
            return false
        end

        local message = tostring(text or "")
        local argbColor = normalizeColor(color)

        chat:AddEntry(
            CHAT_TYPE_DEBUG,
            message,
            "",
            argbColor,
            0xFFFFFFFF
        )

        return true
    end)

    if not ok then
        print("[MGSA] sampAddChatMessage error: " .. tostring(result))
        return false
    end

    return result
end


---------------------------------------------------------------

function __MGSAAPI__.sampShowDialog(dialogId, title, text, button1, button2, dialogStyle)
    if not __MGSAAPI__.isSampAvailable() then
        return false
    end

    local ok, result = pcall(function()
        local dialog = MGSA_GetRefObject(MGSA_CDialog.RefDialog)

        if dialog == nil or dialog == MGSA_FFI.NULL then
            return false
        end

        dialog:Show(
            tonumber(dialogId) or 0,
            tonumber(dialogStyle) or 0,
            tostring(title or ""),
            tostring(text or ""),
            tostring(button1 or ""),
            tostring(button2 or ""),
            1
        )
        MGSA_DIALOG_OPEN = true

        return true
    end)

    if not ok then
        print("[MGSA] sampShowDialog error: " .. tostring(result))
        return false
    end

    return result
end

-------------------------------------------------------------------

function __MGSAAPI__.sampIsPlayerConnected(playerId)
    if not __MGSAAPI__.isSampAvailable() then
        return false
    end

    playerId = tonumber(playerId)

    if not playerId or playerId < 0 or playerId > 1003 or playerId % 1 ~= 0 then
        return false
    end

    local ok, result = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)

        if netGame == nil or netGame == MGSA_FFI.NULL then
            return false
        end

        local playerPool = netGame:GetPlayerPool()

        if playerPool == nil or playerPool == MGSA_FFI.NULL then
            return false
        end

        return playerPool:IsConnected(playerId) ~= 0
    end)

    if not ok then
        return false
    end

    return result
end

function __MGSAAPI__.sampGetCharHandleBySampPlayerId(playerId)
    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, 0
    end

    local ok, ped = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if not MGSA_IsValidPointer(netGame) then return 0 end

        local playerPool = netGame:GetPlayerPool()
        if not MGSA_IsValidPointer(playerPool) then return 0 end

        local remotePlayer = playerPool:GetPlayer(playerId)

        local remotePlayer = playerPool:GetPlayer(playerId)

        if remotePlayer == nil or remotePlayer == MGSA_FFI.NULL then
            return 0
        end

        local sampPed = remotePlayer.m_pPed

        if sampPed == nil or sampPed == MGSA_FFI.NULL then
            return 0
        end

        local gamePed = sampPed.m_pGamePed

        if gamePed == nil or gamePed == MGSA_FFI.NULL then
            return 0
        end

        return getCharPointerHandle(tonumber(MGSA_FFI.cast("uintptr_t", gamePed)))
    end)

    if not ok or not ped or ped == 0 then
        return false, 0
    end

    return true, ped
end
----------------------------NICK COLOR--------------------------------

function __MGSAAPI__.sampGetPlayerColor(playerId)
    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, 0
    end

    local ok, color = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if netGame == nil or netGame == MGSA_FFI.NULL then
            return 0
        end

        local playerPool = netGame:GetPlayerPool()
        if playerPool == nil or playerPool == MGSA_FFI.NULL then
            return 0
        end

        local remotePlayer = playerPool:GetPlayer(playerId)
        if remotePlayer == nil or remotePlayer == MGSA_FFI.NULL then
            return 0
        end

        return tonumber(remotePlayer:GetColorAsARGB())
    end)

    if not ok or not color or color == 0 then
        return false, 0
    end

    return true, color
end
----------------------------ARMOR AND HEALTH--------------------------------

function __MGSAAPI__.sampGetPlayerHealthComplex(playerId)
    playerId = tonumber(playerId)

    if not playerId or playerId < 0 or playerId > 1003 or playerId % 1 ~= 0 then
        return false, 0
    end

    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, 0
    end

    local ok, health = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if netGame == nil or netGame == MGSA_FFI.NULL then
            return nil
        end

        local playerPool = netGame:GetPlayerPool()
        if playerPool == nil or playerPool == MGSA_FFI.NULL then
            return nil
        end

        local remotePlayer = playerPool:GetPlayer(playerId)
        if remotePlayer == nil or remotePlayer == MGSA_FFI.NULL then
            return nil
        end

        local sampPed = remotePlayer.m_pPed
        if sampPed == nil or sampPed == MGSA_FFI.NULL then
            return nil
        end

        return tonumber(remotePlayer.m_fReportedHealth)--tonumber(sampPed:GetHealth())
    end)

    if not ok or health == nil then
        return false, 0
    end

    return true, health
end


function __MGSAAPI__.sampGetPlayerHealth(pid)
    local ok, hp = __MGSAAPI__.sampGetPlayerHealthComplex(pid)
    if ok then return hp end
    return 0
end

function __MGSAAPI__.sampGetPlayerArmorComplex(playerId)
    playerId = tonumber(playerId)

    if not playerId or playerId < 0 or playerId > 1003 or playerId % 1 ~= 0 then
        return false, 0
    end

    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, 0
    end

    local ok, armor = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if netGame == nil or netGame == MGSA_FFI.NULL then
            return nil
        end

        local playerPool = netGame:GetPlayerPool()
        if playerPool == nil or playerPool == MGSA_FFI.NULL then
            return nil
        end

        local remotePlayer = playerPool:GetPlayer(playerId)
        if remotePlayer == nil or remotePlayer == MGSA_FFI.NULL then
            return nil
        end

        local sampPed = remotePlayer.m_pPed
        if sampPed == nil or sampPed == MGSA_FFI.NULL then
            return nil
        end

        return tonumber(remotePlayer.m_fReportedArmour) --tonumber(sampPed:GetArmour())
    end)

    if not ok then
        print("[MGSA] Armor error: " .. tostring(armor))
        return false, 0
    end

    if not ok or armor == nil then
        return false, 0
    end

    return true, armor
end


function __MGSAAPI__.sampGetPlayerArmor(pid)
    local ok, hp = __MGSAAPI__.sampGetPlayerArmorComplex(pid)
    if ok then return hp end
    return 0
end
----------------------------NICKNAME--------------------------------


function __MGSAAPI__.sampGetPlayerNicknameComplexOld(playerId)
    playerId = tonumber(playerId)

    if not playerId or playerId < 0 or playerId > 1003 or playerId % 1 ~= 0 then
        return false, ""
    end

    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, ""
    end

    local ok, nickname = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if not MGSA_IsValidPointer(netGame) then return nil end

        local playerPool = netGame:GetPlayerPool()
        if not MGSA_IsValidPointer(playerPool) then return nil end

        local r5nick = MGSA_FFI.string(playerPool:GetName(playerId))
        if r5nick then
            return r5nick
        end

        local playerInfo = playerPool:GetAt(playerId)
        if not MGSA_IsValidPointer(playerInfo) then return nil end

        local nick = playerInfo.m_szNick
        local length = tonumber(nick.length)

        if not length or length <= 0 or length > 256 then
            return ""
        end

        local buffer

        if tonumber(nick.allocated) < 16 then
            buffer = nick.str
        else
            if nick.pstr == nil or nick.pstr == MGSA_FFI.NULL then
                return nil
            end

            buffer = nick.pstr
        end

        return MGSA_FFI.string(buffer, length)
    end)

    if not ok then
        print("[MGSA] Nickname error: " .. tostring(nickname))
        return false, ""
    end

    if nickname == nil then
        return false, ""
    end

    return true, nickname
end


function __MGSAAPI__.sampGetPlayerNicknameComplex(playerId)
    playerId = tonumber(playerId)

    if not playerId or playerId < 0 or playerId > 1003 or playerId % 1 ~= 0 then
        return false, ""
    end

    if not __MGSAAPI__.sampIsPlayerConnected(playerId) then
        return false, ""
    end

    local ok, nickname = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if not MGSA_IsValidPointer(netGame) then
            return nil
        end

        local playerPool = netGame:GetPlayerPool()
        if not MGSA_IsValidPointer(playerPool) then
            return nil
        end

        local namePointer = playerPool:GetName(playerId)
        if not MGSA_IsValidPointer(namePointer) then
            return nil
        end

        return MGSA_FFI.string(namePointer)
    end)

    if not ok then
        print("[MGSA] Nickname error: " .. tostring(nickname))
        return false, ""
    end

    if nickname == nil or nickname == "" then
        return false, ""
    end

    return true, nickname
end

function __MGSAAPI__.sampGetPlayerNickname(pid)
    local ok, res = __MGSAAPI__.sampGetPlayerNicknameComplex(pid)
    if ok then return res end
    return ""
end
----------------------------PING AND SCORE--------------------------------
function __MGSAAPI__.sampGetPlayerScoreComplex(pid)
    pid = tonumber(pid)
    if not __MGSAAPI__.sampIsPlayerConnected(pid) then
        return false, 0
    end
    local ok, ss = pcall(function ()
        local ng = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if not MGSA_IsValidPointer(ng) then return nil end
        local pp = ng:GetPlayerPool()
        if not MGSA_IsValidPointer(pp) then return nil end
        return tonumber(pp:GetScore(pid))
    end)

    if not ok or ss == nil then
        print("Score error: "..tostring(ss))
        return false, 0
    end

    return true,ss
end

function __MGSAAPI__.sampGetPlayerScore(pid)
    local ok, res = __MGSAAPI__.sampGetPlayerScoreComplex(pid)
    if ok then return res end
    return 0
end

function __MGSAAPI__.sampGetPlayerPingComplex(pid)
    pid = tonumber(pid)

    if not __MGSAAPI__.sampIsPlayerConnected(pid) then
        return false, 0
    end

    local ok, ping = pcall(function()
        local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
        if not MGSA_IsValidPointer(netGame) then return nil end

        local playerPool = netGame:GetPlayerPool()
        if not MGSA_IsValidPointer(playerPool) then return nil end

        local remotePlayer = playerPool:GetPlayer(pid)
        if not MGSA_IsValidPointer(remotePlayer) then return nil end
        return tonumber(playerPool:GetPing(pid))
    end)

    if not ok or ping == nil then
        print("[MGSA] Ping error: " .. tostring(ping))
        return false, 0
    end

    return true, ping
end

function __MGSAAPI__.sampGetPlayerPing(pid)
    local ok, res = __MGSAAPI__.sampGetPlayerPingComplex(pid)
    if ok then return res end
    return 0
end

----------------------------COMMANDS/CHAT--------------------------------
---------------------------------------------------------
-- SA-MP INPUT CONTROL
---------------------------------------------------------

MGSA_SAMP_CHAT_ENABLED = true

function __MGSAAPI__.sampSetChatInputEnabled(w)
    MGSA_SAMP_CHAT_ENABLED = w
end

local MGSA_PreviousChatInputState = nil

function __MGSAAPI__.setPlayerControllable(what)
    setPlayerControl(PLAYER_HANDLE, what)
    __MGSAAPI__.sampSetChatInputEnabled(what)
end

function __MGSAAPI__.sampCloseChatInput()
    if not __MGSAAPI__.isSampLoaded() or not MGSA_CInput then
        return false
    end

    local ok, result = pcall(function()
        local input = MGSA_GetRefObject(MGSA_CInput.RefInputBox)

        if not MGSA_IsValidPointer(input) then
            return false
        end

        input:Close()
        MGSA_CHAT_OPEN = false
        return true
    end)

    return ok and result == true
end

function __MGSAAPI__.isSampChatOpened()
    return MGSA_CHAT_OPEN
end
function __MGSAAPI__.isSampDialogOnScreen()
    return MGSA_DIALOG_OPEN
end
---------------------------------------------------
function __MGSAAPI__.sampGetPlayerSkinModel(id)
    local r, ped = MGSA_API.sampGetCharHandleBySampPlayerId(id)
    if not r then
        return 0
    end
    if not doesCharExist(ped) then return 0 end
    return getCharModel(ped)
end
------------------------------------------------------
function __MGSAAPI__.sampGetPlayerWeaponInfo(id)
    local ok, ped = __MGSAAPI__.sampGetCharHandleBySampPlayerId(id)
    if not ok then
        return -1, "Nepoznato"
    end
    if not doesCharExist(ped) then
        return -1,"Nepoznato"
    end

    local weapon = getCurrentCharWeapon(ped)

    local weapons = {
        [0] = "Sake - Nije naoruzan",
        [1] = "Brass Knuckles",
        [2] = "Golf Club",
        [3] = "Pendrek",
        [4] = "Noz",
        [5] = "Baseball Bat",
        [6] = "Lopata",
        [7] = "Pool Cue",
        [8] = "Katana",
        [9] = "Chainsaw",
        [10] = "Ljubicasti Dildo",
        [11] = "Dildo",
        [12] = "Vibrator",
        [13] = "Sivi Vibrator",
        [14] = "Cvijece",
        [15] = "Cane",
        [16] = "Granata",
        [17] = "Tear Gas",
        [18] = "Molotov",
        [22] = "Pistol",
        [23] = "Silenced Pistol",
        [24] = "Desert Eagle",
        [25] = "Shotgun",
        [26] = "Sawed-off",
        [27] = "Combat Shotgun",
        [28] = "Micro SMG",
        [29] = "MP5",
        [30] = "AK-47",
        [31] = "M4",
        [32] = "Tec-9",
        [33] = "Rifle",
        [34] = "Sniper Rifle",
        [35] = "RPG",
        [36] = "HS Rocket",
        [37] = "Flamethrower",
        [38] = "Minigun",
        [39] = "Satchel Charge",
        [40] = "Detonator",
        [41] = "Sprej",
        [42] = "Fire Extinguisher",
        [43] = "Kamera",
        [46] = "Padobran"
    }

    return weapon or -1, weapons[weapon] or "Nepoznato (" .. weapon .. ")"
end

------------------------------------------------------------------

local MGSA_AFK_PLAYER_LIST = {}
local MGSA_AFK_SECONDS = 10
local MGSA_AFK_RADIUS = 0.45

function __MGSAAPI__.sampIsPlayerPossiblyAway(id)
    if not __MGSAAPI__.sampIsPlayerConnected(id) then
        MGSA_AFK_PLAYER_LIST[id] = nil
        return false
    end

    local result, ped = __MGSAAPI__.sampGetCharHandleBySampPlayerId(id)

    if not result or not doesCharExist(ped) then
        return false
    end

    local x, y, z = getCharCoordinates(ped)
    local now = os.clock()

    if not MGSA_AFK_PLAYER_LIST[id] then
        MGSA_AFK_PLAYER_LIST[id] = {
            x = x,
            y = y,
            z = z,
            lastMovement = now
        }

        return false
    end

    local data = MGSA_AFK_PLAYER_LIST[id]

    local distance = getDistanceBetweenCoords3d(
        x, y, z,
        data.x, data.y, data.z
    )

    if distance > MGSA_AFK_RADIUS then
        data.x = x
        data.y = y
        data.z = z
        data.lastMovement = now
    end

    return (now - data.lastMovement) >= MGSA_AFK_SECONDS
end

--------------------------------------------------------
MGSA_CHRONO.task(
    3.0, function(id)
        local n = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame) if MGSA_IsValidPointer(n) then
            n:UpdatePlayers()
        end
    end, true
)

function __MGSAAPI__.__LOOP_SAMP_CHAT()
    if not MGSA_SAMP_CHAT_ENABLED then
        __MGSAAPI__.sampCloseChatInput()
    end

    -----------------------------------------
    local ok, cin = pcall(MGSA_GetRefObject, MGSA_CInput.RefInputBox)
    if ok then
        if cin ~= nil then
            MGSA_CHAT_OPEN = cin.m_bEnabled ~= 0
        end
    end
    -----------------------------------
    local ok, dialog = pcall(MGSA_GetRefObject, MGSA_CDialog.RefDialog)
    if ok then
        if dialog ~= nil then
            MGSA_DIALOG_OPEN = dialog.m_bIsActive ~= 0
        end
    end
end
---------------------------------------------------------
local MGSA_PLAYERS_INFO = {
    POOL = {},
    ONLINE_PLAYERS = {},
    LARGEST_PLAYER_ID = 10
}

local MGSA_PLAYER_POOL_MAX_ID = 1003
local MGSA_PLAYER_POOL_BATCH_SIZE = 20
local MGSA_PLAYER_POOL_CURSOR = 0

function __MGSAAPI__.sampGetPlayerPool()
    return MGSA_PLAYERS_INFO.POOL
end

function __MGSAAPI__.sampGetOnlinePlayers()
    return MGSA_PLAYERS_INFO.ONLINE_PLAYERS
end

local function MGSA_GET_LARGESTID()
    if not __MGSAAPI__.isSampAvailable() then
        return 10
    end
    for id = 1003, MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID + 1, -1 do
        if __MGSAAPI__.sampIsPlayerConnected(id) then
            MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID = id
            return id
        end
    end
    for id = MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID, 0, -1 do
        if __MGSAAPI__.sampIsPlayerConnected(id) then
            MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID = id
            return id
        end
    end
    MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID = 10
    return 10
end

function __MGSAAPI__.sampGetLargestPlayerId()
    return MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID
end

local function updatePlayerPoolBatch()
    if not __MGSAAPI__.isSampAvailable() then return end
    local pool = MGSA_PLAYERS_INFO.POOL
    for _ = 1, MGSA_PLAYER_POOL_BATCH_SIZE do
        local id = MGSA_PLAYER_POOL_CURSOR
        MGSA_PLAYER_POOL_CURSOR = MGSA_PLAYER_POOL_CURSOR + 1
        if MGSA_PLAYER_POOL_CURSOR > MGSA_PLAYER_POOL_MAX_ID then
            MGSA_PLAYER_POOL_CURSOR = 0
        end
        if __MGSAAPI__.sampIsPlayerConnected(id) then
            local nickname = __MGSAAPI__.sampGetPlayerNickname(id)
            local ping = __MGSAAPI__.sampGetPlayerPing(id)
            local score = __MGSAAPI__.sampGetPlayerScore(id)
            local armor = __MGSAAPI__.sampGetPlayerArmor(id)
            local health = __MGSAAPI__.sampGetPlayerHealth(id)
            local pedres, ped = __MGSAAPI__.sampGetCharHandleBySampPlayerId(id)
            if not pedres then
                ped = nil
            end
            local skin = __MGSAAPI__.sampGetPlayerSkinModel(id)
            local colres, col = __MGSAAPI__.sampGetPlayerColor(id)
            if not colres then
                col = 0xffffff
            end
            local weapid, weapname = __MGSAAPI__.sampGetPlayerWeaponInfo(id)
            local afk = __MGSAAPI__.sampIsPlayerPossiblyAway(id)
            pool[id] = {
                id = id,
                nickname = nickname,
                ping = ping,
                score = score,
                armor = armor,
                health = health,
                ped = ped,
                skin = skin,
                color = col,
                weapid = weapid,
                weapname = weapname,
                afk = afk
            }
        else
            pool[id] = nil
        end
    end
end

MGSA_CHRONO.task(
    0.5,
    function (id)
        MGSA_PLAYERS_INFO.LARGEST_PLAYER_ID = MGSA_GET_LARGESTID()
    end,
    true
)

MGSA_CHRONO.task(
    0.05,
    updatePlayerPoolBatch,
    true
)

function __MGSAAPI__.sampGetPlayerPingFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.ping
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerNicknameFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.nickname
    end
    return "-"
end
function __MGSAAPI__.sampGetPlayerScoreFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.score
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerSkinModelFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.skin
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerArmorFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.armor
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerHealthFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.health
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerColorFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.color
    end
    return 0
end
function __MGSAAPI__.sampGetPlayerWeaponInfoFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.weapid, player.weapname
    end
    return -1,"Nepoznato"
end
function __MGSAAPI__.sampIsPlayerPossiblyAwayFromPool(id)
    local player = MGSA_PLAYERS_INFO.POOL[id]
    if player then
        return player.afk
    end
    return true
end
-------------------------------------------------------
function __MGSAAPI__.sampGetPickupPool()
    local net = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
    if not MGSA_IsValidPointer(net) then return {} end
    local pool = net:GetPickupPool()
    if pool == nil then return {} end
    local result = {}
    for i = 0, 4095 do
        local pickup = pool.m_object[i]
        local model = pickup.m_nModel
        local pickupType = pickup.m_nType
        local pos = pickup.m_position
        local id = pool.m_nId[i]

        if id ~= -1 then
            result[#result + 1] = {
                id = id,
                model = model,
                type = pickupType,

                x = pos.x,
                y = pos.y,
                z = pos.z
            }
        end
    end

    return result
end

local function B(...)
    local result = {}

    for _, row in ipairs({...}) do
        result[#result + 1] = tonumber(row, 2)
    end

    return result
end

function __MGSAAPI__.sampGetPickupModelBitmaps()
    local house_bitmap = B(
        "00011010",
        "00111110",
        "01111110",
        "11111111",
        "10011001",
        "10011001",
        "10011111",
        "11111111"
    )
    return {
        --white arrow pointing downwards
        [1318] = {
            color = 0xffd1cfcf,
            bitmap = B(
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "11111111",
                "01111110",
                "00111100",
                "00011000"
            )
        },
        --red arrow pointing downwards
        [19133] = {
            color = 0xffdb1428,
            bitmap = B(
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "11111111",
                "01111110",
                "00111100",
                "00011000"
            )
        },
        --orange arrow pointing downwards
        [19132] = {
            color = 0xffa85400,
            bitmap = B(
                "00111100",
                "00000000",
                "00111100",
                "00000000",
                "00111100",
                "00111100",
                "11111111",
                "01111110",
                "00111100",
                "00011000"
            )
        },
        -- HORSESHOE
        [954] = {
            color = 0xffffd700,
            bitmap = B(
                "00111100",
                "01100110",
                "11000011",
                "11000000",
                "11000000",
                "11000011",
                "01100110",
                "00111100"
            )
        },

        -- BRIEFCASE
        [1210] = {
            color = 0xffa87942,
            bitmap = B(
                "01111110",
                "01000010",
                "11111111",
                "11111111",
                "11111111",
                "11111111",
                "11111111",
                "11111111"
            )
        },

        -- MONEY
        [1212] = {
            color = 0xff35d66f,
            bitmap = B(
                "00111100",
                "01100110",
                "11000011",
                "11011011",
                "11011011",
                "11000011",
                "01100110",
                "00111100"
            )
        },

        -- INFORMATION
        [1239] = {
            color = 0xfff0e441,
            bitmap = B(
                "00001100",
                "00001100",
                "00000000",
                "00011000",
                "00110000",
                "00110000",
                "01100000",
                "01100000",
                "00110000"
            )
        },

        -- HEART
        [1240] = {
            color = 0xffff4040,
            bitmap = B(
                "01100110",
                "11111111",
                "11111111",
                "11111111",
                "01111110",
                "00111100",
                "00011000",
                "00000000"
            )
        },

        -- PILL
        [1241] = {
            color = 0xffd8a0ff,
            bitmap = B(
                "00011110",
                "00111111",
                "01111110",
                "11111100",
                "11111000",
                "01110000",
                "00100000",
                "00000000"
            )
        },

        -- BODY ARMOUR
        [1242] = {
            color = 0xff55bbff,
            bitmap = B(
                "01111110",
                "11111111",
                "11011011",
                "11011011",
                "11111111",
                "01111110",
                "00111100",
                "00011000"
            )
        },

        -- STAR
        [1247] = {
            color = 0xffffff00,
            bitmap = B(
                "00011000",
                "00011000",
                "10111101",
                "01111110",
                "00111100",
                "01100110",
                "11000011",
                "00000000"
            )
        },

        -- SKULL
        [1254] = {
            color = 0xffeeeeee,
            bitmap = B(
                "00111100",
                "01111110",
                "11011011",
                "11011011",
                "01111110",
                "01111110",
                "01011010"
            )
        },

        -- BLUE HOUSE
        [1272] = {
            color = 0xff1cb5d4,
            bitmap = house_bitmap
        },

        -- GREEN HOUSE
        [1273] = {
            color = 0xff5ce32b,
            bitmap = house_bitmap
        },
        -- ORANGE HOUSE
        [19523] = {
            color = 0xffa85400,
            bitmap = house_bitmap
        },
        -- RED HOUSE
        [19522] = {
            color = 0xffa80000,
            bitmap = house_bitmap
        },
        -- yellow HOUSE
        [19524] = {
            color = 0xffd9c704,
            bitmap = house_bitmap
        },

        -- DOLLAR
        [1274] = {
            color = 0xff39e65c,
            bitmap = B(
                "00011000",
                "01111110",
                "11000000",
                "01111100",
                "00000110",
                "11000110",
                "01111100",
                "00011000"
            )
        },

        -- SHIRT
        [1275] = {
            color = 0xffff66cc,
            bitmap = B(
                "00011000",
                "01111110",
                "11111111",
                "10111101",
                "00111100",
                "00111100",
                "00111100",
                "00111100"
            )
        },

        -- SAVE DISK
        [1277] = {
            color = 0xff253eba,
            bitmap = B(
                "11111111",
                "10000001",
                "10111101",
                "10100101",
                "10111101",
                "10000001",
                "11111111",
                "00000000"
            )
        },
        --red man
        [1314] = {
            color = 0xff910614,
            bitmap = B(
            "00111100",
            "00111100",
            "00011000",
            "11111110",
            "10011011",
            "00100100",
            "01100110",
            "11000011"
        )
        },
        -- PARACHUTE
        [1310] = {
            color = 0xffff5555,
            bitmap = B(
                "00111100",
                "01111110",
                "11011011",
                "11011011",
                "10011001",
                "00011000",
                "00100100",
                "01000010"
            )
        },

        -- MONEY BAG
        [1550] = {
            color = 0xff38db63,
            bitmap = B(
                "00011000",
                "00111100",
                "01111110",
                "01111110",
                "11111111",
                "11111111",
                "01111110",
                "00111100"
            )
        },

        -- DRUG PACKAGE
        [1575] = {
            color = 0xffdddddd,
            bitmap = B(
                "00111100",
                "01111110",
                "11000011",
                "10011001",
                "10111101",
                "10011001",
                "11000011",
                "01111110"
            )
        },

        -- KEYCARD
        [1581] = {
            color = 0xffffff55,
            bitmap = B(
                "01111110",
                "11000011",
                "10011001",
                "10011001",
                "10000001",
                "10011001",
                "11000011",
                "01111110"
            )
        },

        -- PIZZA
        [1582] = {
            color = 0xffffaa33,
            bitmap = B(
                "00011000",
                "00111100",
                "01111110",
                "11111111",
                "11011011",
                "10011001",
                "00011000",
                "00000000"
            )
        },

        -- PETROL CAN
        [1650] = {
            color = 0xffff5555,
            bitmap = B(
                "00111100",
                "00100110",
                "00100010",
                "00111110",
                "00111110",
                "00111110",
                "00111110",
                "00111110"
            )
        },

        -- FIRE EXTINGUISHER
        [2690] = {
            color = 0xffff4444,
            bitmap = B(
                "00011000",
                "00111100",
                "00011000",
                "00111100",
                "00111100",
                "00111100",
                "00111100",
                "00011000"
            )
        },

        -- MEDICAL SATCHEL
        [11736] = {
            color = 0xffeeeeee,
            bitmap = B(
                "00111100",
                "01111110",
                "11011011",
                "11011011",
                "11111111",
                "11111111",
                "01111110",
                "00111100"
            )
        },

        --arrow type 2
        [19131] = {
            color = 0xff2e7eb8,
            bitmap = B(
                "00111100",
                "01000010",
                "10010001",
                "10001101",
                "10010001",
                "01000010",
                "00111100"
            )
        }
    }
end
--------------------------------KEY DETECTION
local comboCooldown = 0.0
function __MGSAAPI__.isKeyCombinationUsed(keys)
    if not keys or #keys == 0 then return false end
    local cooldownSec = 1
    local now = os.clock()
    if cooldownSec and (now - comboCooldown) < cooldownSec then
        return false
    end
    local allDown = true
    local anyJustPressed = false
    for _, key in ipairs(keys) do
        if not isKeyDown(key) then
            allDown = false
            break
        end
        if isKeyJustPressed(key) then
            anyJustPressed = true
        end
    end
    if allDown and anyJustPressed then
        comboCooldown = now
        return true
    end
    return false
end

----------------------------TESTZ--------------------------------


local function MGSA_DebugChat()
    local chat = MGSA_GetRefObject(MGSA_CChat.RefChat)

    print("[MGSA DEBUG] RefChat OK: " .. tostring(ok))
    print("[MGSA DEBUG] RefChat result: " .. tostring(chat))

    if chat == nil or chat == MGSA_FFI.NULL then
        print("[MGSA DEBUG] Chat is not initialized")
        return
    end

    print("[MGSA DEBUG] Chat type: " .. type(chat))

    local ok2, chatObject = pcall(function()
        return MGSA_CChat.new()
    end)

    print("[MGSA DEBUG] CChat.new OK: " .. tostring(ok2))
    print("[MGSA DEBUG] CChat.new result: " .. tostring(chatObject))

    if ok2 and chatObject then
        for name, value in pairs(chatObject) do
            print("[MGSA DEBUG] Chat object: " ..
                tostring(name) .. " = " .. type(value))
        end
    end
end


function MGSA_TestChat()
    print("========== MGSA CHAT TEST ==========")

    print("SAMP Available: " ..
        tostring(__MGSAAPI__.isSampAvailable()))

    local netgame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
    local chat = MGSA_GetRefObject(MGSA_CChat.RefChat)

    print("NetGame pointer: " .. tostring(netgame))

    print("Chat pointer: " .. tostring(chat))

    print("SAMP Base: " ..
        tostring(MGSA_SAMP_API.GetBase()))

    print("====================================")
    
    local ok, chat = pcall(function()
        return MGSA_GetRefObject(MGSA_CChat.RefChat)
    end)

    if not ok or chat == nil or chat == MGSA_FFI.NULL then
        print("[CHAT] Neispravan chat pointer")
        return
    end

    print("[CHAT] Pointer: " .. tostring(chat))
    print("[CHAT] Metatable: " .. tostring(getmetatable(chat)))
    print("[CHAT] CType: " .. tostring(MGSA_FFI.typeof(chat)))

    local methods = {
        "AddEntry",
        "AddMessage",
        "AddChatMessage",
        "AddChatEntry",
        "PushBack",
        "Add"
    }

    for _, name in ipairs(methods) do
        local success, value = pcall(function()
            return chat[name]
        end)

        if success then
            print("[CHAT] " .. name .. " = " .. type(value))
        else
            print("[CHAT] " .. name .. " = access error")
        end
    end


end


function MGSA_InspectChatMethods()
    local chat = MGSA_GetRefObject(MGSA_CChat.RefChat)

    if chat == nil or chat == MGSA_FFI.NULL then
        print("[CHAT] Invalid pointer")
        return
    end

    local methods = {
        "AddEntry",
        "AddMessage",
        "AddChatMessage"
    }

    for _, name in ipairs(methods) do
        local ok, method = pcall(function()
            return chat[name]
        end)

        if ok and method ~= nil then
            local typeOk, methodType = pcall(function()
                return MGSA_FFI.typeof(method)
            end)

            print("[CHAT] " .. name .. " value: " .. tostring(method))

            if typeOk then
                print("[CHAT] " .. name .. " signature: " .. tostring(methodType))
            end
        else
            print("[CHAT] " .. name .. " unavailable")
        end
    end
end
function MGSA_PingAccessTest()
    local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)

    if not MGSA_IsValidPointer(netGame) then
        print("[PING DEBUG] NetGame nije validan")
        return
    end

    local pool = netGame:GetPlayerPool()

    if not MGSA_IsValidPointer(pool) then
        print("[PING DEBUG] PlayerPool nije validan")
        return
    end

    for id = 0, 1003 do
        if pool:IsConnected(id) ~= 0 then
            local info = pool:GetAt(id)

            if info ~= nil and info ~= MGSA_FFI.NULL then
                pool:SetPing(id, 12345)
                print(string.format(
                    "[PING DEBUG] ID: %d | Ping: %d | Score: %d | Pointer: %s",
                    id,
                    tonumber(info.m_nPing),
                    tonumber(info.m_nScore),
                    tostring(info)
                ))
            end
        end
    end
end

function MGSA_MASSDEBUG()
    print("---------------------MASS DEBUG----------------------")
    print(
        "[MGSA DEBUG] SCPlayerInfo size: " ..
        MGSA_FFI.sizeof("struct SCPlayerInfo")
    )

    print(
        "[MGSA DEBUG] Nick offset: " ..
        MGSA_FFI.offsetof("struct SCPlayerInfo", "m_szNick")
    )

    print(
        "[MGSA DEBUG] Score offset: " ..
        MGSA_FFI.offsetof("struct SCPlayerInfo", "m_nScore")
    )

    print(
        "[MGSA DEBUG] Ping offset: " ..
        MGSA_FFI.offsetof("struct SCPlayerInfo", "m_nPing")
    )

    

    print('-----------------------------------------------')
end

function MGSA_TestVersion()

    print("========== MGSA VERSION TEST ==========")

    print("SAMP Base: " ..
        tostring(MGSA_SAMP_API.GetBase()))

    local ok, version = pcall(
        MGSA_SAMP_API.GetSAMPVersion
    )

    print("Version detected: " .. tostring(ok))
    print("Version value: " .. tostring(version))

    print("CNetGame: " .. tostring(MGSA_CNetGame))
    print("CChat: " .. tostring(MGSA_CChat))
    print("CDialog: " .. tostring(MGSA_CDialog))
    print("CPlayerPool: " .. tostring(MGSA_CPlayerPool))
    print("CRemotePlayer: " .. tostring(MGSA_CRemotePlayer))
    print("CPed: " .. tostring(MGSA_CPed))
    print("CInput: " .. tostring(MGSA_CInput))

    print("SAMP Available: " ..
        tostring(__MGSAAPI__.isSampAvailable()))

    print("=======================================")

end

function MGSA_DebugPlayer(pid)
    local netGame = MGSA_GetRefObject(MGSA_CNetGame.RefNetGame)
    if not MGSA_IsValidPointer(netGame) then
        print("[MGSA DEBUG] NetGame nije validan!")
        return
    end

    local playerPool = netGame:GetPlayerPool()
    if not MGSA_IsValidPointer(playerPool) then
        print("[MGSA DEBUG] PlayerPool nije validan!")
        return
    end

    local remotePlayer = playerPool:GetPlayer(pid)
    if not MGSA_IsValidPointer(remotePlayer) then
        print("[MGSA DEBUG] RemotePlayer nije validan!")
        return
    end
    if not MGSA_IsValidPointer(remotePlayer) then
        print("[MGSA DEBUG] RemotePlayer nije validan!")
        return
    end

    print("================================")
    print("Igrac: " .. __MGSAAPI__.sampGetPlayerNickname(pid))

    print("Reported Health: " .. tostring(remotePlayer.m_fReportedHealth))
    print("Reported Armor: " .. tostring(remotePlayer.m_fReportedArmour))

    local sampPed = remotePlayer.m_pPed

    print("SAMP Ped: " .. tostring(sampPed))

    if MGSA_IsValidPointer(sampPed) then
        print("GTA GamePed: " .. tostring(sampPed.m_pGamePed))

        local rawHealth = tonumber(sampPed:GetHealth())
        local rawArmor = tonumber(sampPed:GetArmour())

        print("Raw Health: " .. tostring(rawHealth))
        print("Raw Armor: " .. tostring(rawArmor))

        local okHealth, complexHealth =
            __MGSAAPI__.sampGetPlayerHealthComplex(pid)

        local okArmor, complexArmor =
            __MGSAAPI__.sampGetPlayerArmorComplex(pid)

        print("Complex Health: " .. tostring(okHealth) .. " / " .. tostring(complexHealth))
        print("Complex Armor: " .. tostring(okArmor) .. " / " .. tostring(complexArmor))
    end

    print("================================")
end


return __MGSAAPI__