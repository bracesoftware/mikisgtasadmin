
local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CRect'
shared.require 'v03dl.CFont'

shared.ffi.cdef[[
typedef struct ID3DXSprite ID3DXSprite;
typedef struct IDirect3DDevice9 IDirect3DDevice9;

typedef struct SCFonts SCFonts;

#pragma pack(push, 1)
struct SCFonts {
    SCFont* m_pFont;
    SCFont* m_pLittleFont;
    SCFont* m_pShadow;
    SCFont* m_pLittleShadow;
    SCFont* m_pLicensePlateFont;
    ID3DXSprite* m_pDefaultSprite;
    IDirect3DDevice9* m_pDevice;
    char* m_szTempBuffer;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCFonts', 0x20)

local function RefFontRenderer()
    return ffi.cast(
        'SCFonts**',
        sampapi.GetAddress(0x2ACA2C)
    )
end

local CFonts_constructor = ffi.cast(
    'void(__thiscall*)(SCFonts*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x6B530)
)

local CFonts_destructor = ffi.cast(
    'void(__thiscall*)(SCFonts*)',
    sampapi.GetAddress(0x6AB40)
)

local function CFonts_new(pDevice)
    local obj = ffi.gc(
        ffi.new('struct SCFonts[1]'),
        CFonts_destructor
    )

    CFonts_constructor(obj, pDevice)
    return obj
end

local SCFonts_mt = {
    OnLostDevice = ffi.cast(
        'void(__thiscall*)(SCFonts*)',
        sampapi.GetAddress(0x6ABC0)
    ),

    OnResetDevice = ffi.cast(
        'void(__thiscall*)(SCFonts*)',
        sampapi.GetAddress(0x6AC00)
    ),

    GetTextScreenSize = ffi.cast(
        'void(__thiscall*)(SCFonts*, void*, const char*, int)',
        sampapi.GetAddress(0x6AC40)
    ),

    GetLittleTextScreenSize = ffi.cast(
        'void(__thiscall*)(SCFonts*, void*, const char*, int)',
        sampapi.GetAddress(0x6ACF0)
    ),

    DrawText = ffi.cast(
        'void(__thiscall*)(SCFonts*, ID3DXSprite*, const char*, SCRect, D3DCOLOR, BOOL)',
        sampapi.GetAddress(0x6ADA0)
    ),

    DrawLittleText = ffi.cast(
        'void(__thiscall*)(SCFonts*, ID3DXSprite*, const char*, SCRect, int, D3DCOLOR, BOOL)',
        sampapi.GetAddress(0x6AF20)
    ),

    DrawLicensePlateText = ffi.cast(
        'void(__thiscall*)(SCFonts*, const char*, SCRect, D3DCOLOR)',
        sampapi.GetAddress(0x6B090)
    ),

    Reset = ffi.cast(
        'void(__thiscall*)(SCFonts*)',
        sampapi.GetAddress(0x6B320)
    ),
}

mt.set_handler('struct SCFonts', '__index', SCFonts_mt)

return {
    RefFontRenderer = RefFontRenderer,
    new = CFonts_new,
}
