
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCNetStats SCNetStats;

#pragma pack(push, 1)
struct SCNetStats {
    unsigned long m_dwLastTotalBytesSent;
    unsigned long m_dwLastTotalBytesRecv;
    unsigned long m_dwLastUpdateTick;
    unsigned long m_dwBPSUpload;
    unsigned long m_dwBPSDownload;
    struct IDirect3DDevice9* m_pDevice;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCNetStats', 0x18)

local CNetStats_constructor = ffi.cast(
    'void(__thiscall*)(SCNetStats*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x607C0)
)

local function CNetStats_new(...)
    local obj = ffi.new('struct SCNetStats[1]')
    CNetStats_constructor(obj, ...)
    return obj
end

local SCNetStats_mt = {
    Draw = ffi.cast(
        'void(__thiscall*)(SCNetStats*)',
        sampapi.GetAddress(0x607F0)
    ),
}

mt.set_handler('struct SCNetStats', '__index', SCNetStats_mt)

local function RefNetStats()
    return ffi.cast('SCNetStats**', sampapi.GetAddress(0x2AC9FC))
end

return {
    new = CNetStats_new,
    RefNetStats = RefNetStats,
}
