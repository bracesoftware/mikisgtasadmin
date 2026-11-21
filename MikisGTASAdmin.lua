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
    MANIFEST = "manifest.lua"
}
local MGSA_ROOT = getWorkingDirectory() .. "\\MikisGTASAdmin\\"
local MGSA_FILES = nil

------------------------------------------
local function MGSA_ReadVersion(path)
    local file = io.open(path, "r")

    if not file then
        return 0
    end

    local data = file:read("*a")
    file:close()

    local version = tonumber(data:match("%d+"))

    return version or 0
end

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
local function MGSA_Update()
    createDirectory(MGSA_ROOT)
    local ok
    local result

    print("[MGSA] PROVJERAVAM AZURIRANJA...")

    local VERSION_NOW = 0
    ok, result = pcall(dofile, MGSA_ROOT .. MGSA_GITHUB.VERSION)
    if not ok then
        VERSION_NOW = -1
    end
    VERSION_NOW = result

    local VERSION_ON_SERVER = 0
    print("SKIDAM INFORMACIJE O NAJNOVIJOJ VERZIJI")
    local ver = MGSA_Download(
        MGSA_GITHUB.BASE_URL.."MikisGTASAdmin/".. MGSA_GITHUB.VERSION,
        MGSA_ROOT .. MGSA_GITHUB.MANIFEST
    )

    if not ver then
        print("Nije moguce preuzeti informacije o verziji!")
        return false
    end

    ok, result = pcall(dofile, MGSA_ROOT .. MGSA_GITHUB.VERSION)
    if not ok then
        VERSION_ON_SERVER = -1
    end
    VERSION_ON_SERVER = result

    if VERSION_ON_SERVER == VERSION_NOW then
        print("Nema novih azuriranja!")
        return false
    end

    print("[MGSA] NOVI UPDATE: " .. VERSION_ON_SERVER)
    print("[MGSA] SKIDAM UPDATE...")

    print("SKIDAM MANIFEST")
    local manifest = MGSA_Download(
        MGSA_GITHUB.BASE_URL.."MikisGTASAdmin/"..MGSA_GITHUB.MANIFEST,
        MGSA_ROOT .. MGSA_GITHUB.MANIFEST
    )

    if not manifest then
        print("Nije moguce preuzeti manifest!")
        return false
    end

    ok, result = pcall(dofile, MGSA_ROOT .. MGSA_GITHUB.MANIFEST)

    if not ok or type(result) ~= "table" then
        print("[MGSA] INVALIDAN MANIFEST!")
        return false
    end

    MGSA_FILES = result

    for _, file in ipairs(MGSA_FILES) do

        local rrr = file:gsub(
            "^MikisGTASAdmin/", ""
        )

        local dd = rrr:match("^(.*)/[^/]+$")

        if dd then
            local cc = MGSA_ROOT

            for folder in dd:gmatch("[^/]+") do
                cc = cc .. folder .. "\\"
                createDirectory(cc)
            end
        end

        local d = MGSA_ROOT ..
            rrr:gsub("/", "\\")

        local tt = d .. ".tmp"

        print("[MGSA] SKIDANJE: " .. rrr)


        if not MGSA_Download(
            MGSA_GITHUB.BASE_URL .. file,
            tt
        ) then
            os.remove(tt)

            print("[MGSA] DOWNLOAD ERROR: " .. rrr)
            return false
        end

        local check = io.open(tt, "rb")

        if not check then
            print("[MGSA] FAJL NIJE PRONADJEN: " .. tt)
            return false
        end

        local size = check:seek("end")
        check:close()

        if not size or size == 0 then
            os.remove(tt)

            print("[MGSA] PRAZAN FAJL: " .. rrr)
            return false
        end

        os.remove(d)
        local rr, ee = os.rename(tt,d)

        if not rr then
            print("[MGSA] RENAME ERROR: " .. tostring(ee))
            print("[MGSA] TEMP: " .. tt)
            print("[MGSA] DEST: " .. d)

            return false
        end

        print("[MGSA] INSTALIRAN: " .. rrr)
    end

    local versionFile = io.open(
        MGSA_ROOT .. "version.txt",
        "w"
    )

    if not versionFile then
        print("[MGSA] NE MOGU ZAPISATI VERSION.TXT!")
        return false
    end

    versionFile:write(tostring(remoteVersion))
    versionFile:close()

    print("[MGSA] UPDATE ZAVRSEN!")

    return true
end

----------------------------------------------------------------
function main()

    local updateSuccess = MGSA_Update()

    if not updateSuccess then
        print("[MGSA] UPDATE NIJE USPJEO! ENTRY SE NECE POKRENUTI.")
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