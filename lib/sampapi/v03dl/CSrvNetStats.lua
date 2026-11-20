
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCSrvNetStats SCSrvNetStats;

struct IDirect3DDevice9;

#pragma pack(push, 1)
struct SCSrvNetStats {
    unsigned long m_dwLastTotalBytesSent;
    unsigned long m_dwLastTotalBytesRecv;
    unsigned long m_dwLastUpdateTick;
    unsigned long m_dwBPSUpload;
    unsigned long m_dwBPSDownload;
    struct IDirect3DDevice9* m_pDevice;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCSrvNetStats', 0x18)

local CSrvNetStats_constructor = ffi.cast(
    'void(__thiscall*)(SCSrvNetStats*, struct IDirect3DDevice9*)',
    sampapi.GetAddress(0x70CC0)
)

local function CSrvNetStats_new(pDevice)
    local obj = ffi.new('struct SCSrvNetStats[1]')
    CSrvNetStats_constructor(obj, pDevice)
    return obj
end

local SCSrvNetStats_mt = {
    Draw = ffi.cast(
        'void(__thiscall*)(SCSrvNetStats*)',
        sampapi.GetAddress(0x70D00)
    ),
}

mt.set_handler('struct SCSrvNetStats', '__index', SCSrvNetStats_mt)

local function RefServerNetStatistics()
    return ffi.cast(
        'SCSrvNetStats**',
        sampapi.GetAddress(0x2ACA00)
    )
end

return {
    new = CSrvNetStats_new,
    RefServerNetStatistics = RefServerNetStatistics,
}
