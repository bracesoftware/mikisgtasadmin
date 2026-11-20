
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CFonts'

shared.ffi.cdef[[
typedef struct SCSpawnScreen SCSpawnScreen;

struct IDirect3DDevice9;
struct IDirect3DTexture9;
struct IDirect3DStateBlock9;

#pragma pack(push, 1)
struct SCSpawnScreen {
    BOOL m_bEnabled;
    char* m_szSpawnText;
    SCFonts* m_pFont;
    struct IDirect3DDevice9* m_pDevice;
    struct IDirect3DTexture9* m_pTexture;
    struct IDirect3DStateBlock9* m_pStateBlockSaved;
    struct IDirect3DStateBlock9* m_pStateBlockDraw;
    void* m_pSprite;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCSpawnScreen', 0x20)

local CSpawnScreen_constructor = ffi.cast(
    'void(__thiscall*)(SCSpawnScreen*, struct IDirect3DDevice9*)',
    sampapi.GetAddress(0x70990)
)

local CSpawnScreen_destructor = ffi.cast(
    'void(__thiscall*)(SCSpawnScreen*)',
    sampapi.GetAddress(0x709D0)
)

local function CSpawnScreen_new(pDevice)
    local obj = ffi.gc(
        ffi.new('struct SCSpawnScreen[1]'),
        CSpawnScreen_destructor
    )
    CSpawnScreen_constructor(obj, pDevice)
    return obj
end

local SCSpawnScreen_mt = {
    SetText = ffi.cast(
        'void(__thiscall*)(SCSpawnScreen*, const char*)',
        sampapi.GetAddress(0x70630)
    ),

    OnResetDevice = ffi.cast(
        'void(__thiscall*)(SCSpawnScreen*)',
        sampapi.GetAddress(0x70690)
    ),

    OnLostDevice = ffi.cast(
        'void(__thiscall*)(SCSpawnScreen*)',
        sampapi.GetAddress(0x70940)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCSpawnScreen*)',
        sampapi.GetAddress(0x70A30)
    ),
}

mt.set_handler('struct SCSpawnScreen', '__index', SCSpawnScreen_mt)

local function RefSpawnScreen()
    return ffi.cast(
        'SCSpawnScreen**',
        sampapi.GetAddress(0x2ACA20)
    )
end

return {
    RefSpawnScreen = RefSpawnScreen,
    new = CSpawnScreen_new,
}
