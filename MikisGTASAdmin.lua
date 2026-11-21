--Miki's GTASAdmin
-- Collection of essential scripts


MGSA_MOONLOADER = require("moonloader")
MGSA_MOONADDITIONS = require("MoonAdditions")
MGSA_MEMORY = require("memory")
MGSA_SAMP_API = require("sampapi")
MGSA_FFI = require("ffi")
MGSA_BIT = rawget(_G, "bit")
if not MGSA_BIT then
    local ok, res = pcall(require, "bit")
    if ok then
        MGSA_BIT = res
    end
end
MGSA_BASE64 = require("base64")
MGSA_SHA = require("sha2")
MGSA_WEBSOCKET = require("websocket")
MGSA_UUID = require("uuid")

--API MODULES
MGSA_CNetGame = MGSA_SAMP_API.require("CNetGame", true)
MGSA_CInput = MGSA_SAMP_API.require("CInput", true)
MGSA_CRemotePlayer = MGSA_SAMP_API.require("CRemotePlayer", true)
MGSA_CPed = MGSA_SAMP_API.require("CPed", true)
MGSA_CNetGame = MGSA_SAMP_API.require("CNetGame", true)
MGSA_CPlayerPool = MGSA_SAMP_API.require("CPlayerPool", true)
MGSA_CChat = MGSA_SAMP_API.require("CChat", true)
MGSA_CDialog = MGSA_SAMP_API.require("CDialog", true)

if (
    not MGSA_MOONLOADER or
    not MGSA_MOONADDITIONS or
    not MGSA_MEMORY or
    not MGSA_SAMP_API or
    not MGSA_FFI or
    not MGSA_BIT or
    not MGSA_BASE64 or
    not MGSA_SHA or
    not MGSA_WEBSOCKET or
    not MGSA_UUID
) then
    print("Neki od modula nije ucitan!")
    return
end

if (
    not MGSA_CNetGame or
    not MGSA_CInput or
    not MGSA_CRemotePlayer or
    not MGSA_CPed or
    not MGSA_CNetGame or
    not MGSA_CPlayerPool or
    not MGSA_CChat or
    not MGSA_CDialog
) then
    print("Neki od SAMP API modula nije ucitan!")
    return
end

local MGSA_GITHUB = {
    BASE_URL = "https://raw.githubusercontent.com/bracesoftware/mikisgtasadmin/main/",
    VERSION = "version.lua",
    MANIFEST = "manifest.lua",
    UPDATE = "update.lua"
}
local MGSA_ROOT = getWorkingDirectory() .. "\\MikisGTASAdmin\\"
local MGSA_FILES = nil

------------------------------------------

local function MGSA_Download(url, path)
    local finished = false
    local success = false

    os.remove(path)

    downloadUrlToFile(url, path, function(id, status)
        if status == 6 then
            finished = true
            success = true
        elseif status < 0 then
            finished = true
            success = false
        end
    end)

    local timeout = os.clock() + 90

    while not finished and os.clock() < timeout do
        wait(100)
    end

    if not finished then
        print("[MGSA] DOWNLOAD TIMEOUT: " .. path)
        return false
    end

    if not success then
        print("[MGSA] DOWNLOAD FAILED: " .. path)
        return false
    end

    local fileTimeout = os.clock() + 5

    while not doesFileExist(path) and os.clock() < fileTimeout do
        wait(100)
    end

    if not doesFileExist(path) then
        print("[MGSA] FAJL NIJE KREIRAN: " .. path)
        return false
    end

    return true
end

------------------------------------------

function main()
    local updater = MGSA_Download(
        MGSA_GITHUB.BASE_URL.."MikisGTASAdmin/"..MGSA_GITHUB.UPDATE,
        MGSA_ROOT .. MGSA_GITHUB.UPDATE
    )
    if updater then
        dofile(MGSA_ROOT..MGSA_GITHUB.UPDATE)
    else
        print("Nije moguce skinuti updater!")
    end
    local s = MGSA_Update()
    if not s then
        print("[MGSA] UPDATE NIJE ZAVRSEN! ENTRY SE NECE POKRENUTI.")
        return
    end
    local entry = MGSA_ROOT .. "entry.lua"
    if doesFileExist(entry) then
        dofile(entry)
        print("[MGSA] GTASADMIN UCITAN!")

        if type(MGSA_ENTRY__) == "function" then
            MGSA_ENTRY__()
        end

    else
        print("[MGSA] ULAZNI ENTRY FAJL NIJE DOSTUPAN!")
    end

    return
end