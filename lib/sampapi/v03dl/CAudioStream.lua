
--[[
    Project: SAMP-API.lua <https://github.com/imring/SAMP-API.lua>
    Developers: imring, LUCHARE, FYP

    SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'

shared.ffi.cdef[[
enum {
    AUDIOSTREAM_MAX_STRING = 256,
};

typedef struct SCAudioStream SCAudioStream;
#pragma pack(push, 1)
struct SCAudioStream {
    bool m_bInitialized;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCAudioStream', 0x1)

-- Static references
local function RefStream()
    return ffi.cast('int*', sampapi.GetAddress(0x16C7CC))
end

local function RefIsPlaying()
    return ffi.cast('bool*', sampapi.GetAddress(0x16C7D0))
end

local function RefPosition()
    return ffi.cast('SCVector*', sampapi.GetAddress(0x16C7D4))
end

local function RefIs3d()
    return ffi.cast('bool*', sampapi.GetAddress(0x16C7E0))
end

-- Static arrays
local function ArrayIcyUrl()
    return ffi.cast('char*', sampapi.GetAddress(0x16C6C8))
end

local function ArrayInfo()
    return ffi.cast('char*', sampapi.GetAddress(0x16C5C0))
end

local function ArrayUrl()
    return ffi.cast('char*', sampapi.GetAddress(0x16C4B8))
end

local function RefNeedsToDestroy()
    return ffi.cast('bool*', sampapi.GetAddress(0x1407BA))
end

local function RefRadius()
    return ffi.cast('float*', sampapi.GetAddress(0x1407BC))
end

local function ArrayIcyName()
    return ffi.cast('char*', sampapi.GetAddress(0x16C3B0))
end

-- Static functions
local ConstructInfo = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0x66040)
)

local SyncProc = ffi.cast(
    'void(__stdcall*)(int, int, int, void*)',
    sampapi.GetAddress(0x66170)
)

local Process = ffi.cast(
    'void(__cdecl*)(void*)',
    sampapi.GetAddress(0x66180)
)

-- Instance methods
local SCAudioStream_mt = {
    Reset = ffi.cast(
        'BOOL(__thiscall*)(SCAudioStream*)',
        sampapi.GetAddress(0x65F00)
    ),

    Stop = ffi.cast(
        'BOOL(__thiscall*)(SCAudioStream*, bool)',
        sampapi.GetAddress(0x65FE0)
    ),

    Play = ffi.cast(
        'BOOL(__thiscall*)(SCAudioStream*, const char*, SCVector, float, bool)',
        sampapi.GetAddress(0x663E0)
    ),

    ControlGameRadio = ffi.cast(
        'void(__thiscall*)(SCAudioStream*)',
        sampapi.GetAddress(0x66500)
    ),

    DrawInfo = ffi.cast(
        'void(__thiscall*)(SCAudioStream*)',
        sampapi.GetAddress(0x66530)
    ),
}

mt.set_handler('struct SCAudioStream', '__index', SCAudioStream_mt)

local function RefAudioStream()
    return ffi.cast('SCAudioStream**', sampapi.GetAddress(0x2ACA1C))
end

return {
    RefStream = RefStream,
    RefIsPlaying = RefIsPlaying,
    RefPosition = RefPosition,
    RefIs3d = RefIs3d,

    ArrayIcyUrl = ArrayIcyUrl,
    ArrayInfo = ArrayInfo,
    ArrayUrl = ArrayUrl,

    RefNeedsToDestroy = RefNeedsToDestroy,
    RefRadius = RefRadius,
    ArrayIcyName = ArrayIcyName,

    ConstructInfo = ConstructInfo,
    SyncProc = SyncProc,
    Process = Process,

    RefAudioStream = RefAudioStream,
}
