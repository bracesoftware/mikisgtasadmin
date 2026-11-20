
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CObject'
shared.require 'CVector'

shared.ffi.cdef[[
enum {
    MAX_OBJECTS = 2100,
};

typedef struct SCObjectPool SCObjectPool;
#pragma pack(push, 1)
struct SCObjectPool {
    int m_nLargestId;
    BOOL m_bNotEmpty[MAX_OBJECTS];
    SCObject* m_pObject[MAX_OBJECTS];
};
#pragma pack(pop)
]]

shared.validate_size('struct SCObjectPool', 0x2944)

local CObjectPool_constructor = ffi.cast(
    'void(__thiscall*)(SCObjectPool*)',
    sampapi.GetAddress(0x12700)
)

local CObjectPool_destructor = ffi.cast(
    'void(__thiscall*)(SCObjectPool*)',
    sampapi.GetAddress(0x13060)
)

local function CObjectPool_new(...)
    local obj = ffi.new('struct SCObjectPool[1]')
    CObjectPool_constructor(obj, ...)
    return ffi.gc(obj, CObjectPool_destructor)
end

local SCObjectPool_mt = {
    UpdateLargestId = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x126A0)
    ),

    GetCount = ffi.cast(
        'int(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12730)
    ),

    Delete = ffi.cast(
        'BOOL(__thiscall*)(SCObjectPool*, ID)',
        sampapi.GetAddress(0x12750)
    ),

    Create = ffi.cast(
        'BOOL(__thiscall*)(SCObjectPool*, ID, int, SCVector, SCVector, float)',
        sampapi.GetAddress(0x127D0)
    ),

    Find = ffi.cast(
        'SCObject*(__thiscall*)(SCObjectPool*, SCObject*)',
        sampapi.GetAddress(0x128D0)
    ),

    GetId = ffi.cast(
        'int(__thiscall*)(SCObjectPool*, SCObject*)',
        sampapi.GetAddress(0x12910)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12950)
    ),

    ConstructMaterials = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12A10)
    ),

    ShutdownMaterials = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12A50)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12A90)
    ),

    DrawLast = ffi.cast(
        'void(__thiscall*)(SCObjectPool*)',
        sampapi.GetAddress(0x12AD0)
    ),

    Get = ffi.cast(
        'SCObject*(__thiscall*)(SCObjectPool*, ID)',
        sampapi.GetAddress(0x2E10)
    ),
}

mt.set_handler('struct SCObjectPool', '__index', SCObjectPool_mt)

return {
    new = CObjectPool_new,
}
