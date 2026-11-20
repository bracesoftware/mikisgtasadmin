
--[[
    Project: SAMP-API.lua
    SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCLabel SCLabel;

#pragma pack(push, 1)
struct SCLabel {
    struct IDirect3DDevice9* m_pDevice;
    struct ID3DXSprite* m_pSprite;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCLabel', 0x8)

local CLabel_constructor = ffi.cast(
    'void(__thiscall*)(SCLabel*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x6B5F0)
)

local CLabel_destructor = ffi.cast(
    'void(__thiscall*)(SCLabel*)',
    sampapi.GetAddress(0x6B610)
)

local function CLabel_new(...)
    local obj = ffi.gc(
        ffi.new('struct SCLabel[1]'),
        CLabel_destructor
    )
    CLabel_constructor(obj, ...)
    return obj
end

local SCLabel_mt = {
    OnLostDevice = ffi.cast(
        'void(__thiscall*)(SCLabel*)',
        sampapi.GetAddress(0x6B630)
    ),

    OnResetDevice = ffi.cast(
        'void(__thiscall*)(SCLabel*)',
        sampapi.GetAddress(0x6B640)
    ),

    HasNoObstacles = ffi.cast(
        'BOOL(__thiscall*)(SCLabel*, SCVector)',
        sampapi.GetAddress(0x6B650)
    ),

    Begin = ffi.cast(
        'void(__thiscall*)(SCLabel*)',
        sampapi.GetAddress(0x6B6B0)
    ),

    End = ffi.cast(
        'void(__thiscall*)(SCLabel*)',
        sampapi.GetAddress(0x6B6C0)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCLabel*, SCVector*, const char*, D3DCOLOR, BOOL, bool)',
        sampapi.GetAddress(0x6B6D0)
    ),
}

mt.set_handler('struct SCLabel', '__index', SCLabel_mt)

local function RefLabel()
    return ffi.cast(
        'SCLabel**',
        sampapi.GetAddress(0x2AC9EC)
    )
end

return {
    new = CLabel_new,
    RefLabel = RefLabel,
}
