
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCPlayerTags SCPlayerTags;

struct IDirect3DDevice9;
struct IDirect3DStateBlock9;
struct ID3DXSprite;

#pragma pack(push, 1)
struct SCPlayerTags {
    struct IDirect3DDevice9* m_pDevice;
    struct IDirect3DStateBlock9* m_pStates;
    struct ID3DXSprite* m_pSprite;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCPlayerTags', 0xC)

local CPlayerTags_constructor = ffi.cast(
    'void(__thiscall*)(SCPlayerTags*, struct IDirect3DDevice9*)',
    sampapi.GetAddress(0x6C730)
)

local CPlayerTags_destructor = ffi.cast(
    'void(__thiscall*)(SCPlayerTags*)',
    sampapi.GetAddress(0x6C760)
)

local function CPlayerTags_new(pDevice)
    local obj = ffi.gc(
        ffi.new('struct SCPlayerTags[1]'),
        CPlayerTags_destructor
    )
    CPlayerTags_constructor(obj, pDevice)
    return obj
end

local SCPlayerTags_mt = {
    EndHealthBar = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6C790)
    ),

    BeginLabel = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6C7C0)
    ),

    EndLabel = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6C7D0)
    ),

    DrawLabel = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*, SCVector*, const char*, D3DCOLOR, float, bool, int)',
        sampapi.GetAddress(0x6C7E0)
    ),

    DrawHealthBar = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*, SCVector*, float, float, float)',
        sampapi.GetAddress(0x6CAE0)
    ),

    OnLostDevice = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6D090)
    ),

    OnResetDevice = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6D0C0)
    ),

    BeginHealthBar = ffi.cast(
        'void(__thiscall*)(SCPlayerTags*)',
        sampapi.GetAddress(0x6D0F0)
    ),
}

mt.set_handler('struct SCPlayerTags', '__index', SCPlayerTags_mt)

local function RefPlayerTags()
    return ffi.cast(
        'SCPlayerTags**',
        sampapi.GetAddress(0x2AC9D8)
    )
end

return {
    new = CPlayerTags_new,
    RefPlayerTags = RefPlayerTags,
}
