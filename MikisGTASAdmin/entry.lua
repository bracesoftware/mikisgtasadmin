
function MGSA_DUMP_STACK(label)
    MGSA_TRACE("========== STACK: " .. tostring(label) .. " ==========")

    local level = 2

    while true do
        local info = debug.getinfo(level, "nSl")

        if not info then
            break
        end

        MGSA_TRACE(string.format(
            "#%d | function=%s | source=%s | line=%s | what=%s",
            level - 1,
            tostring(info.name),
            tostring(info.short_src),
            tostring(info.currentline),
            tostring(info.what)
        ))

        level = level + 1
    end

    MGSA_TRACE(debug.traceback("TRACEBACK:", 2))
    MGSA_TRACE("========== END STACK ==========")
end

local MGSA_TRACE_FILE = getWorkingDirectory() .. "\\MGSA_trace.log"

function MGSA_TRACE(message)
    local file = io.open(MGSA_TRACE_FILE, "a")
    if not file then
        print("[MGSA TRACE] Ne mogu otvoriti trace fajl!")
        return
    end

    file:write(
        os.date("[%Y-%m-%d %H:%M:%S] "),
        string.format("[%.3f] ", os.clock()),
        tostring(message),
        "\n"
    )

    file:close()
    return
end


-- Definiranje boja za SA-MP chat
COLOR_YELLOW     = "{FFFF33}"
COLOR_RED        = "{FF0000}"
COLOR_GREEN      = "{33FF33}"
COLOR_ORANGE     = "{FFA500}"
COLOR_SKYBLUE    = "{33CCFF}"
COLOR_WHITE      = "{FFFFFF}"
COLOR_GRAY       = "{CCCCCC}"
COLOR_DARK_GREEN = "{0B6623}" -- Bogata tamnozelena / šumska zelena
COLOR_PINK       = "{FF66CC}"
COLOR_PURPLE     = "{9933FF}"
COLOR_GOLD       = "{FFD700}"
COLOR_PEACH      = "{FFDAB9}" -- Blaga pastelna breskva
COLOR_NEON_PURPLE = "{E040FB}" -- Čista fluorescentna neon ljubičasta
COLOR_ELECTRIC_VIOLET = "{8A2BE2}" -- Jarka električna ljubičasta
COLOR_MAGENTA_GLOW  = "{FF00FF}" -- Jarka neon magenta/roza-ljubičasta
COLOR_BEAUTIFUL_BLUE = "{d4fffe}"
-----------KOMANDE_----------------
MGSA = "mgsa"
MIKIS_GTASADMIN_HELP = "mikisgtasadmin"
MGSA_PLAYER_POS = {
    x = 0, y = 0, z = 0
}
--KOMANDE
SET_SKIN = "setskin"
TOGGLE_RECORD_OBS = "obs"
RECORD_STATUS = "obss"
SPRINT = "sprint"
WALLHACK = "wh"
CRASH = "c"
SPEC = "spec"
SPECOFF = "specoff"
ALTC = "altc"
BIKE = "bike"
STATUS = "status"

--------------LIBRARIES-----------
function MGSA_LOADED_MODULE(module)
    table.insert(MGSA_LOADED_MODULES, module)
end

function MGSA_STATIC_INCLUDE(text)
    return dofile(getWorkingDirectory().."\\MikisGTASAdmin\\"..text)
end

MGSA_VERSION = MGSA_STATIC_INCLUDE("version.lua")
MGSA_PROJECT_NAME = "Miki's GTASAdmin"
---------------------------
script_name(MGSA_PROJECT_NAME)
script_authors("Mikhail Elyfterov aka Bioxemicar aka DEntisT")
script_version(MGSA_VERSION)

function MGSA_SAFE_GUARD_THAT_IS_SAFE(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        sendErrorMessage("Kritična greška u skripti! Automatski restartujem modul...")
        sendWarningMessage("Detalji: " .. tostring(err))
        lua_thread.create(function()
            wait(2000)
            thisScript():reload()
        end)
        return nil
    end
    return err
end

function MGSA_SAFE_GUARD_THAT_ISNT_SO_SAFE(func, ...)
    local success, err = pcall(func, ...)

    if not success then
        print("[MGSA SAFE_GUARD] GRESKA: " .. tostring(err))
        print("[MGSA SAFE_GUARD] Automatski restart je PRIVREMENO ISKLJUCEN!")
        return false, err
    end

    return true, err
end

MGSA_SAFE = MGSA_SAFE_GUARD_THAT_ISNT_SO_SAFE

MGSA_CHRONO = MGSA_STATIC_INCLUDE("chrono.lua")
MGSA_KEYS = MGSA_STATIC_INCLUDE("keys.lua")
MGSA_API = MGSA_STATIC_INCLUDE("api.lua")

--------------------------------------------------------

MGSA_DIALOG_OPEN = false
MGSA_CHAT_OPEN = false

MESSAGE_HEADER = COLOR_PURPLE..".:!"..COLOR_SKYBLUE.."Miki's"..COLOR_PEACH.." GTASAdmin"..COLOR_PURPLE .."!:."
--------MODULI
MGSA_SPRINTHOOK = true
MGSA_ALT_CHAT = true
MGSA_BIKE_TWEAKS = true
MGSA_WALLHACK = true
MGSA_OBS = true
MGSA_MINIRADAR = true

--*************************************************************
MGSA_TAB = "   "
--*************************************************************
MGSA_LOADED_MODULES = {}
--*************************************************************
function sendFormattedChat(fullMessage)
    fullMessage = tostring(fullMessage) 
    local maxLength = 100
    local lines = {}
    if #fullMessage <= maxLength then
        MGSA_API.sampAddChatMessage(fullMessage, -1)
        return
    end
    local i = 1
    while i <= #fullMessage do
        local chunk = fullMessage:sub(i, i + maxLength - 1)
        i = i + maxLength 
        if i <= #fullMessage then
            table.insert(lines, chunk .. "..")
        else
            table.insert(lines, chunk)
        end
    end
    for index, line in ipairs(lines) do
        if index == 1 then
            MGSA_API.sampAddChatMessage(line, -1)
        else
            MGSA_API.sampAddChatMessage(".." .. line, -1)
        end
    end
end
--*************************************************************
--*************************************************************
-- ***************************************************

function sendInfoMessage(text)
    MGSA_API.sampAddChatMessage(
        MESSAGE_HEADER .. COLOR_GRAY,-1
    )
    sendFormattedChat(COLOR_ELECTRIC_VIOLET.."- "..COLOR_GRAY..text)
end

function sendErrorMessage(text)
    MGSA_API.sampAddChatMessage(
        MESSAGE_HEADER ..
        COLOR_RED .. " [Greska] ",-1
    )
    sendFormattedChat(COLOR_ELECTRIC_VIOLET.."* "..COLOR_GRAY..text)
end

function sendWarningMessage(text)
    MGSA_API.sampAddChatMessage(
        MESSAGE_HEADER ..
        COLOR_ORANGE .. " [Upozorenje] ",-1
    )
    sendFormattedChat(COLOR_ELECTRIC_VIOLET.."* "..COLOR_GRAY..text)
end

function sendSuccessMessage(text)
    MGSA_API.sampAddChatMessage(
        MESSAGE_HEADER ..
        COLOR_GREEN .. " [OK!] ",-1
    )
    sendFormattedChat(COLOR_ELECTRIC_VIOLET.."- "..COLOR_GRAY..text)
end

function safe_call(func, ...)
    local results = {pcall(func, ...)}
    local success = table.remove(results, 1)

    if not success then
        sendErrorMessage("Neuspjesno pozvana funkcija!")
        sendWarningMessage("LUA Greska -> " .. tostring(results[1]))
        return nil
    end

    return unpack(results)
end

--*************************************************************
--*************************************************************
function MGSA_CRASH()
    os.execute("taskkill /f /im gta_sa.exe")
end
--*************************************************************
--*************************************************************

MGSARender = MGSA_STATIC_INCLUDE("modules/render.lua")
MGSA_STICKMAN_COLOR = TIRKIZNA
MGSAAltChat = MGSA_STATIC_INCLUDE("modules/alt.lua")
MGSACommandInput = MGSA_STATIC_INCLUDE("cmdin.lua")
MGSADialog = MGSA_STATIC_INCLUDE("modules/dialog.lua")
MGSAAutoBikeSprint = MGSA_STATIC_INCLUDE("modules/bikesprint.lua")
MGSASprinthookHandle = MGSA_STATIC_INCLUDE("modules/sprinthook.lua")
MGSASkin = MGSA_STATIC_INCLUDE("modules/skin.lua")
MGSAWallhack = MGSA_STATIC_INCLUDE("modules/wh.lua")
MGSASpecHack = MGSA_STATIC_INCLUDE("modules/spec.lua")

MGSA_STATIC_INCLUDE("dynamic/obscfg.lua")
MGSAObsConnect = MGSA_STATIC_INCLUDE("modules/obsconnect.lua")
MGSAMiniRadar = MGSA_STATIC_INCLUDE("modules/radar.lua")

-------------------------------------------------------
---  MGSA ---------------------------------------------
--- ---------------------------------------------------

MGSA_COMMANDS = {}
function MGSA_REGISTER_COMMAND(cmd)
    if not cmd or type(cmd) ~= "table" then return end

    if (
        cmd.name == nil or
        type(cmd.name) ~= "string"
    ) then
        print("Name for the command isnt valid")
        return
    end

    if (
        cmd.func == nil or
        type(cmd.func) ~= "function"
    ) then
        print("Function for the command isnt valid")
        return
    end

    if (
        cmd.warn == nil or
        type(cmd.warn) ~= "boolean"
    ) then
        print("Warning for the command isnt valid")
        return
    end

    if (
        cmd.args == nil or
        type(cmd.args) ~= "boolean"
    ) then
        print("Args for the command isnt valid")
        return
    end

    if (
        cmd.desc == nil or
        type(cmd.desc) ~= "string"
    ) then
        print("Name for the command isnt valid")
        return
    end

    table.insert(MGSA_COMMANDS, cmd)
end
function MGSA_COMMAND_EXECUTE(name, ...)
    local cmd = nil
    for i, what in ipairs(MGSA_COMMANDS) do
        if what.name then
            if what.name == name then
                cmd = what
                break
            end
        end
    end

    if cmd == nil then
        return false
    end

    if cmd.warn then
        MGSAAltChat.send(
            {
                {
                    text = "[BAN WARN] ",
                    color = BLUE_LOL
                },
                {
                    text = "Upotreba ove komande moze uzrokovati da vas banuju!",
                    color = NARANDZASTA
                }
            }
        )
    end

    local ok, err
    if cmd.args then
        ok, err = pcall(cmd.func, ...)
    else
        ok, err = pcall(cmd.func)
    end

    if not ok then
        print("[MGSA - Command Error] -> " .. tostring(name) ..": "..tostring(err))
        return false
    end

    print("[MGSA COMMAND] Zavrsena: " .. tostring(name))

    return true
end

local function ISKLJUCENO(locstring)
    return locstring..MGSA_TAB..MGSA_TAB..COLOR_PEACH.."[ "..COLOR_RED.."Iskljuceno"..COLOR_PEACH.." ]"
end
local function UKLJUCENO(locstring)
    return locstring..MGSA_TAB..MGSA_TAB..COLOR_PEACH.."[ "..COLOR_GREEN.."Ukljuceno"..COLOR_PEACH.." ]"
end
local function MODUL(locstring,nnn)
    return locstring..'\n'..COLOR_PINK.." * "..MGSA_TAB..COLOR_NEON_PURPLE..nnn..MGSA_TAB
end

function MGSA_STATUS()
    INFO = COLOR_BEAUTIFUL_BLUE.."Aktivnost modula:"
    --------------------------------WALLHACK
    INFO = MODUL(INFO, "Wallhack") if MGSA_WALLHACK then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------BIKETWEAKS
    INFO = MODUL(INFO, "Bike Tweaks") if MGSA_BIKE_TWEAKS then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------SPRINTHOOK
    INFO = MODUL(INFO, "Sprinthook") if MGSA_SPRINTHOOK then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------ALTCHAT
    INFO = MODUL(INFO, "Alt Chat") if MGSA_ALT_CHAT then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------OBS
    INFO = MODUL(INFO, "SAMP-OBS") if MGSA_OBS then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------OBS
    INFO = MODUL(INFO, "MiniRadar") if MGSA_MINIRADAR then INFO = UKLJUCENO(INFO) else INFO = ISKLJUCENO(INFO) end
    --------------------------------
    INFO = INFO..'\n\n'..COLOR_SKYBLUE.."* Ovaj dijalog obuhvata iskljucivo promjenjive odnosno varijabilne komponente sistema."
    ..'\n'.."Pod 'varijabilne' misli se na module koji se mogu gasiti-paliti po potrebi!"
    ..'\n'.."Sve ucitane module mozete pregledati klikom na 'Z' pa 'Enter'."

    safe_call(MGSADialog.show, "Aktivnost sistema",INFO)
end

function MGSA_KOMANDE(params)
    MGSA_TRACE("MGSA_KOMANDE ENTER: "..tostring(params))
    local args = {}
    for word in tostring(params):gmatch("%S+") do table.insert(args, word:lower()) end

    local command = args[1]
    local other = args[2] or ""

    MGSA_TRACE("PARSED COMMAND: " .. tostring(command))
    MGSA_TRACE("COMMAND ARGUMENT: " .. tostring(other))

    INFO = COLOR_PEACH .. "Dostupne komande:\n\n"
    for i, what in ipairs(MGSA_COMMANDS) do
        INFO = INFO..COLOR_PINK.."* "..COLOR_SKYBLUE..(what.name)..MGSA_TAB..MGSA_TAB..COLOR_PEACH..(what.desc)..'\n'
    end

    INFO = INFO..'\n'..COLOR_SKYBLUE.."Sve navedene komande koriste se iskljucivo preko Z konzole!".."\n"

    INFO = INFO..'\n'..COLOR_ORANGE.."Ucitani moduli ("..COLOR_RED..tostring(#MGSA_LOADED_MODULES)..COLOR_ORANGE.."):\n"
    for i, modul in ipairs(MGSA_LOADED_MODULES) do
        if modul.name and modul.desc then
            INFO = INFO..MGSA_TAB..COLOR_YELLOW..'* '..COLOR_DARK_GREEN..modul.name..MGSA_TAB..COLOR_PEACH..modul.desc..'\n'
        end
    end

    INFO = INFO..'\n\n'..COLOR_BEAUTIFUL_BLUE.."Trenutno instalirana verzija: "..COLOR_RED.."v"..tostring(MGSA_VERSION)

    if not command or command == "" then
        MGSA_TRACE("OTVOREN HELP DIJALOG")
        safe_call(MGSADialog.show,"Informacije",INFO)
        MGSA_TRACE("ZATVOREN HELP DIJALOG")
        return
    end

    MGSA_TRACE("PRIJE IZVRSAVANJA KOMANDE: "..command)

    local res = MGSA_COMMAND_EXECUTE(command, other)

    MGSA_TRACE("NAKON IZVRSAVANJA KOMANDE: "..command)

    if not res then sendErrorMessage("Nepoznata komanda, stisnite Z pa ENTER za info!") end

    MGSA_TRACE("ZAVRSEN MGSA_KOMANDE")
    return
end
-------------------------------------------------------
---  MGSA ---------------------------------------------
--- ---------------------------------------------------
MGSA_LOADED = false

function MGSA_UPDATE()
    MGSA_PLAYER_POS.x, MGSA_PLAYER_POS.y, MGSA_PLAYER_POS.z = getCharCoordinates(PLAYER_PED)
end

function MGSA_ENTRY()
    MGSA_DUMP_STACK("ENTRY POZIV")
    if MGSA_LOADED then return end
    MGSA_LOADED = true

    MGSA_MAIN_CALLS = (MGSA_MAIN_CALLS or 0) + 1

    MGSA_TRACE("================================")
    MGSA_TRACE("MAIN START #" .. MGSA_MAIN_CALLS)
    MGSA_TRACE("MAIN STACK:\n" .. debug.traceback("", 2))
    MGSA_TRACE("SAMP AVAILABLE: " .. tostring(MGSA_API.isSampAvailable()))
    print("[MGSA LIFECYCLE] MAIN START #" .. MGSA_MAIN_CALLS)

    print("[MGSA LIFECYCLE] MAIN START: " .. tostring(os.clock()))
    print("DOBRODOSLI U MIKI'S GTASADMIN!!!!! ------------------")
    print(MGSA_API.isSampAvailable())
    repeat MGSA_API.wait(50) until MGSA_API.isSampAvailable()
    print(MGSA_API.isSampAvailable())

    MGSA_TestChat()
    MGSA_InspectChatMethods()
    MGSA_MASSDEBUG()
    MGSA_TestVersion()

    sendInfoMessage(COLOR_ELECTRIC_VIOLET.."v"..MGSA_VERSION..COLOR_GOLD.." by Mikhail Elyfterov")
    sendInfoMessage("Koristite tipku Z pa ENTER za pomoc! "..COLOR_RED.."[konzola]")

    --sampRegisterChatCommand(MIKIS_GTASADMIN_HELP, MGSA_KOMANDE)
    --sampRegisterChatCommand(MGSA, MGSA_KOMANDE)

    MGSA_REGISTER_COMMAND({
        name = RECORD_STATUS,
        func = MGSAObsConnect.status,
        warn = false,
        args = false,
        desc = "Provjerite status snimanja preko OBS servera!"
    })
    MGSA_REGISTER_COMMAND({
        name = TOGGLE_RECORD_OBS,
        func = MGSAObsConnect.toggle,
        warn = false,
        args = false,
        desc = "Ukljucite/iskljucite snimanje preko OBS."
    })
    MGSA_REGISTER_COMMAND({
        name = CRASH,
        func = MGSA_CRASH,
        warn = false,
        args = false,
        desc = "Srusite igru."
    })
    MGSA_REGISTER_COMMAND({
        name = WALLHACK,
        func = MGSAWallhack.toggle,
        warn = true,
        args = false,
        desc = "Ukljucite/iskljucite wallhack."
    })
    MGSA_REGISTER_COMMAND({
        name = SPRINT,
        func = MGSASprinthookHandle.toggle,
        warn = true,
        args = false,
        desc = "Ukljucite/iskljucite sprint modul-hackove sa sprintovanjem!"
    })
    MGSA_REGISTER_COMMAND({
        name = SPECOFF,
        func = MGSASpecHack.specoff,
        warn = true,
        args = false,
        desc = "Izadjite iz speca."
    })
    MGSA_REGISTER_COMMAND({
        name = SPEC,
        func = MGSASpecHack.spec,
        warn = true,
        args = true,
        desc = "Udjite u spec."
    })
    MGSA_REGISTER_COMMAND({
        name = SET_SKIN,
        func = MGSASkin.set,
        warn = true,
        args = true,
        desc = "Postavite sebi zeljeni skin!"
    })
    MGSA_REGISTER_COMMAND(
        {
            name = ALTC,
            func = MGSAAltChat.toggle,
            warn = false,
            args = false,
            desc = "Ukljucite/iskljucite alternativni chat."
        }
    )
    MGSA_REGISTER_COMMAND(
        {
            name = BIKE,
            func = MGSAAutoBikeSprint.toggle,
            warn = true,
            args = false,
            desc = "Ukljucite/iskljucite bike tweaks-hackove sa biciklom!"
        }
    )
    MGSA_REGISTER_COMMAND(
        {
            name = STATUS,
            func = MGSA_STATUS,
            warn = false,
            args = false,
            desc = "Pregledajte aktivnost promjenjivih modula!"
        }
    )
    MGSA_REGISTER_COMMAND(
        {
            name = "obsm",
            func = MGSAObsConnect.toggleModule,
            warn = false,
            args = false,
            desc = "Ukljucite/iskljucite SAMP-OBS modul."
        }
    )
    MGSA_REGISTER_COMMAND(
        {
            name = "radar",
            func = MGSAMiniRadar.toggle,
            warn = false,
            args = false,
            desc = "Ukljucite/iskljucite mini-radar modul."
        }
    )
    -------------------------

    MGSA_SAFE(function()
        MGSARender.load()
        MGSADialog.load()
        MGSAAltChat.load()
        MGSAObsConnect.load()
        MGSAWallhack.load()
        MGSAAutoBikeSprint.load()
        MGSASprinthookHandle.load()
        MGSASpecHack.load()
        MGSACommandInput.load()
        MGSAMiniRadar.load()
    end)

    sendSuccessMessage(COLOR_PEACH.."Uspjesno ucitano "..tostring(#MGSA_LOADED_MODULES).." modula i "..tostring(#MGSA_COMMANDS).." komandi!")

    MGSAAltChat.send(
        {{
            text = "Dobrodosli u ",
            color = ZLATNA
        },
        {
            text = MGSA_PROJECT_NAME.." ",
            color = TAMNO_ZELENA
        },
        {
            text = "kolekciju esencijalnih skripti!",
            color = ZUTA
        }}
    )

    MGSAAltChat.send(
        {
            {
                text = "Instalirana verzija: ",
                color = LJUBICASTA
            },
            {
                text = string.format("v%s", MGSA_VERSION),
                color = BLUE_AS_SEA
            }
        }
    )

    while true do
        MGSA_UPDATE()
        --
        wait(0)
        MGSAWallhack.render()
        MGSASprinthookHandle.loop()
        MGSAAutoBikeSprint.loop()
        MGSAWallhack.update()
        MGSASpecHack.update()
        MGSAAltChat.loop()
        MGSAAltChat.update()
        MGSAAutoBikeSprint.bikeJump()
        MGSACommandInput.loop()
        MGSACommandInput.render()
        MGSAMiniRadar.loop()
        --
        MGSA_API.__LOOP_SAMP_CHAT()
        MGSA_CHRONO.__PROC()
        --MGSA_PingAccessTest()
    end
end

--Ulazna funkcija bracala
function MGSA_ENTRY__()
    MGSA_DUMP_STACK("main()")
    MGSA_ENTRY()
end
