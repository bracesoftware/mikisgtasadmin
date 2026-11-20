
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CMenu'

shared.ffi.cdef[[
enum {
    MAX_MENUS = 128,
};

typedef struct SCMenuPool SCMenuPool;

#pragma pack(push, 1)
struct SCMenuPool {
    SCMenu* m_pObject[MAX_MENUS];
    BOOL m_bNotEmpty[MAX_MENUS];
    NUMBER m_nCurrent;
    bool m_bCanceled;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCMenuPool', 0x402)

local CMenuPool_constructor = ffi.cast(
    'void(__thiscall*)(SCMenuPool*)',
    sampapi.GetAddress(0x7B40)
)

local CMenuPool_destructor = ffi.cast(
    'void(__thiscall*)(SCMenuPool*)',
    sampapi.GetAddress(0x7EB0)
)

local function CMenuPool_new()
    local obj = ffi.gc(
        ffi.new('struct SCMenuPool[1]'),
        CMenuPool_destructor
    )

    CMenuPool_constructor(obj)
    return obj
end

local SCMenuPool_mt = {
    Create = ffi.cast(
        'SCMenu*(__thiscall*)(SCMenuPool*, NUMBER, float, float, char, float, float, const SInteraction*)',
        sampapi.GetAddress(0x7B90)
    ),

    Delete = ffi.cast(
        'BOOL(__thiscall*)(SCMenuPool*, NUMBER)',
        sampapi.GetAddress(0x7C60)
    ),

    Show = ffi.cast(
        'void(__thiscall*)(SCMenuPool*, NUMBER)',
        sampapi.GetAddress(0x7CB0)
    ),

    Hide = ffi.cast(
        'void(__thiscall*)(SCMenuPool*, NUMBER)',
        sampapi.GetAddress(0x7D10)
    ),

    GetTextPointer = ffi.cast(
        'char*(__thiscall*)(SCMenuPool*, const char*)',
        sampapi.GetAddress(0x7D50)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCMenuPool*)',
        sampapi.GetAddress(0x7EF0)
    ),
}

mt.set_handler('struct SCMenuPool', '__index', SCMenuPool_mt)

return {
    new = CMenuPool_new,
}
