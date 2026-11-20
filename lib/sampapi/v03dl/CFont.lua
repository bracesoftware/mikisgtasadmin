
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct ID3DXFont ID3DXFont;
typedef struct SCFont SCFont;

#pragma pack(push, 1)
struct SCFont {
    void** m_lpVtbl;
    ID3DXFont* m_pFont;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCFont', 0x8)

local CFont_constructor = ffi.cast(
    'void(__thiscall*)(SCFont*)',
    sampapi.GetAddress(0x6B8D0)
)

local function CFont_new()
    local obj = ffi.new('struct SCFont[1]')
    CFont_constructor(obj)
    return obj
end

-- Inline CFont(ID3DXFont* pFont) constructor.
local function CFont_newWithFont(pFont)
    local obj = ffi.new('struct SCFont[1]')

    obj[0].m_lpVtbl = ffi.cast(
        'void**',
        sampapi.GetAddress(0xEA410)
    )

    obj[0].m_pFont = pFont

    return obj
end

return {
    new = CFont_new,
    newWithFont = CFont_newWithFont,
}
