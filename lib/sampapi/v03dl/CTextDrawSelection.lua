
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCTextDrawSelection SCTextDrawSelection;

#pragma pack(push, 1)
struct SCTextDrawSelection {
    BOOL m_bIsActive;
    D3DCOLOR m_hoveredColor;
    ID m_nHoveredId;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCTextDrawSelection', 0x0A)

local SCTextDrawSelection_mt = {
    ResetTextDraws = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*)',
        sampapi.GetAddress(0x70D50)
    ),

    RawProcess = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*)',
        sampapi.GetAddress(0x70DB0)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*)',
        sampapi.GetAddress(0x70EB0)
    ),

    Enable = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*, D3DCOLOR)',
        sampapi.GetAddress(0x70EE0)
    ),

    SendNotification = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*)',
        sampapi.GetAddress(0x70F20)
    ),

    Disable = ffi.cast(
        'void(__thiscall*)(SCTextDrawSelection*)',
        sampapi.GetAddress(0x70FC0)
    ),

    MsgProc = ffi.cast(
        'BOOL(__thiscall*)(SCTextDrawSelection*, int, int, int)',
        sampapi.GetAddress(0x71010)
    ),
}

mt.set_handler('struct SCTextDrawSelection', '__index', SCTextDrawSelection_mt)

local function CTextDrawSelection_new()
    local obj = ffi.new('struct SCTextDrawSelection[1]')
    obj[0].m_bIsActive = 0
    obj[0].m_hoveredColor = 0xFFFFFFFF
    obj[0].m_nHoveredId = -1
    return obj
end

local function RefTextDrawSelection()
    return ffi.cast(
        'SCTextDrawSelection**',
        sampapi.GetAddress(0x2AC9F8)
    )
end

return {
    new = CTextDrawSelection_new,
    RefTextDrawSelection = RefTextDrawSelection,
}
