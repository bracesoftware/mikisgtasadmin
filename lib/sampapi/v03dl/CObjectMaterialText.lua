
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
struct IDirect3DDevice9;
struct ID3DXSprite;
struct IDirect3DTexture9;

typedef struct SCObjectMaterialText SCObjectMaterialText;
#pragma pack(push, 1)
struct SCObjectMaterialText {
    struct IDirect3DDevice9* m_pDevice;
    struct ID3DXSprite* m_pSprite;
    struct ID3DXSprite* m_pSprite_0;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCObjectMaterialText', 0xC)

local CObjectMaterialText_constructor = ffi.cast(
    'void(__thiscall*)(SCObjectMaterialText*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x70320)
)

local CObjectMaterialText_destructor = ffi.cast(
    'void(__thiscall*)(SCObjectMaterialText*)',
    sampapi.GetAddress(0x70340)
)

local function CObjectMaterialText_new(...)
    local obj = ffi.new('struct SCObjectMaterialText[1]')
    CObjectMaterialText_constructor(obj, ...)
    return ffi.gc(obj, CObjectMaterialText_destructor)
end

local SCObjectMaterialText_mt = {
    OnLostDevice = ffi.cast(
        'void(__thiscall*)(SCObjectMaterialText*)',
        sampapi.GetAddress(0x702D0)
    ),

    OnResetDevice = ffi.cast(
        'void(__thiscall*)(SCObjectMaterialText*)',
        sampapi.GetAddress(0x70300)
    ),

    Create = ffi.cast(
        'IDirect3DTexture9*(__thiscall*)(SCObjectMaterialText*, const char*, const char*, char, int, int, D3DCOLOR, D3DCOLOR, bool, char)',
        sampapi.GetAddress(0x70350)
    ),
}

mt.set_handler('struct SCObjectMaterialText', '__index', SCObjectMaterialText_mt)

local function RefObjectMaterialTextManager()
    return ffi.cast(
        'SCObjectMaterialText**',
        sampapi.GetAddress(0x2ACA34)
    )
end

return {
    new = CObjectMaterialText_new,
    RefObjectMaterialTextManager = RefObjectMaterialTextManager,
}
