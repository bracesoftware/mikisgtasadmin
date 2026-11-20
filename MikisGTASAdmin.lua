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
    not MGSA_BIT
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
    VERSION = "version.txt"
}

local MGSA_ROOT = getWorkingDirectory() .. "\\MikisGTASAdmin\\"

----------------------------------------

local MGSA_FILES = {
    "MikisGTASAdmin/entry.lua",
    "MikisGTASAdmin/keys.lua",
    "MikisGTASAdmin/cmdin.lua",
    "MikisGTASAdmin/chrono.lua",
    "MikisGTASAdmin/api.lua",

    "MikisGTASAdmin/static/alt.lua",
    "MikisGTASAdmin/static/bikesprint.lua",
    "MikisGTASAdmin/static/dialog.lua",
    "MikisGTASAdmin/static/render.lua",
    "MikisGTASAdmin/static/skin.lua",
    "MikisGTASAdmin/static/spec.lua",
    "MikisGTASAdmin/static/sprinthook.lua",
    "MikisGTASAdmin/static/wh.lua",

    "MikisGTASAdmin/dynamic/obscfg.lua",
    "MikisGTASAdmin/dynamic/obsconnect.lua"
}

---------------------------------

local function MGSA_ReadVersion(path)
    local file = io.open(path, "r")
    if not file then return 0 end

    local version = tonumber(file:read("*a"):match("%d+"))
    file:close()

    return version
end
-------------------------------------------

local function MGSA_Download(url, path)
    local finished = false
    local success = false

    downloadUrlToFile(url, path, function(id, status)
        if status == 6 then
            success = true
            finished = true
        elseif status < 0 then
            finished = true
        end
    end)

    local timeout = os.clock() + 90

    while not finished and os.clock() < timeout do
        wait(100)
    end

    return finished and success
end

--------------------------------------------------

local function MGSA_Update()

    createDirectory(MGSA_ROOT)

    print("PROVJERAVAM AZURIRANJA !!!")

    local remoteVersionPath = MGSA_ROOT .. "version.tmp"

    if not MGSA_Download(
        MGSA_GITHUB.BASE_URL .. MGSA_GITHUB.VERSION,
        remoteVersionPath
    ) then
        os.remove(remoteVersionPath)
        print("GITHUB NEDOSTUPAN")
        return false
    end

    local remoteVersion = MGSA_ReadVersion(remoteVersionPath)
    os.remove(remoteVersionPath)

    if not remoteVersion then
        print("INVALIDNA VERZIJA")
        return false
    end

    local localVersion = MGSA_ReadVersion(
        MGSA_ROOT .. "version.txt"
    )

    if localVersion == remoteVersion then
        print("SVE VEC AZURNO.")
        return true
    end

    print("NOVI UPDATE: " .. remoteVersion)
    print("SKIDAM UPDATE...")

    for _, file in ipairs(MGSA_FILES) do

        local relativePath = file:gsub(
            "^MikisGTASAdmin/", ""
        )

        local directory = relativePath:match("^(.*)/[^/]+$")

        if directory then
            local current = MGSA_ROOT

            for folder in directory:gmatch("[^/]+") do
                current = current .. folder .. "\\"
                createDirectory(current)
            end
        end

        local destination =
            MGSA_ROOT .. relativePath:gsub("/", "\\")

        local temporary = destination .. ".tmp"

        print("[MGSA] SKIDANJE: " .. relativePath)

        if not MGSA_Download(
            MGSA_GITHUB.BASE_URL .. file,
            temporary
        ) then
            os.remove(temporary)
            print("[MGSA] NEUSPJESAN UPDATE: " .. relativePath)
            return false
        end

        local check = io.open(temporary, "rb")

        if not check then
            return false
        end

        local size = check:seek("end")
        check:close()

        if not size or size == 0 then
            os.remove(temporary)
            return false
        end

        os.remove(destination)

        if not os.rename(temporary, destination) then
            os.remove(temporary)
            return false
        end
    end

    local versionFile = io.open(
        MGSA_ROOT .. "version.txt", "w"
    )

    if not versionFile then
        return false
    end

    versionFile:write(tostring(remoteVersion))
    versionFile:close()

    print("[MGSA] UPDATE ZAVRSEN!")

    return true
end

------------------------------------
function main()
    MGSA_Update()

    local entry = MGSA_ROOT .. "entry.lua"

    if doesFileExist(entry) then
        dofile(entry)
        print("[MGSA] GTASAdmin loaded!")
        MGSA_ENTRY__()
    else
        print("[MGSA] entry.lua not found!")
    end
    return
end
