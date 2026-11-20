
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CTextDraw'

shared.ffi.cdef[[
enum {
    MAX_TEXTDRAWS = 2048,
    MAX_LOCAL_TEXTDRAWS = 256,
};

typedef struct SCTextDrawPool SCTextDrawPool;

#pragma pack(push, 1)
struct SCTextDrawPool {
    BOOL m_bNotEmpty[MAX_TEXTDRAWS + MAX_LOCAL_TEXTDRAWS];
    SCTextDraw* m_pObject[MAX_TEXTDRAWS + MAX_LOCAL_TEXTDRAWS];
};
#pragma pack(pop)
]]

shared.validate_size('struct SCTextDrawPool', 0x4800)

local CTextDrawPool_constructor = ffi.cast(
    'void(__thiscall*)(SCTextDrawPool*)',
    sampapi.GetAddress(0x1E260)
)

local CTextDrawPool_destructor = ffi.cast(
    'void(__thiscall*)(SCTextDrawPool*)',
    sampapi.GetAddress(0x1E390)
)

local function CTextDrawPool_new()
    local obj = ffi.gc(
        ffi.new('struct SCTextDrawPool[1]'),
        CTextDrawPool_destructor
    )

    CTextDrawPool_constructor(obj)
    return obj
end

local SCTextDrawPool_mt = {
    Delete = ffi.cast(
        'void(__thiscall*)(SCTextDrawPool*, ID)',
        sampapi.GetAddress(0x1E2B0)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCTextDrawPool*)',
        sampapi.GetAddress(0x1E2F0)
    ),

    Create = ffi.cast(
        'SCTextDraw*(__thiscall*)(SCTextDrawPool*, int, STransmit*, const char*)',
        sampapi.GetAddress(0x1E3D0)
    ),
}

mt.set_handler('struct SCTextDrawPool', '__index', SCTextDrawPool_mt)

return {
    new = CTextDrawPool_new,
}
