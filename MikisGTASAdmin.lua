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

dofile(getWorkingDirectory() .. "MikisGTASAdmin/entry.lua")