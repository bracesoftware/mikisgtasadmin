
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CRect'

shared.ffi.cdef[[
typedef struct SCScoreboard SCScoreboard;

struct IDirect3DDevice9;
struct CDXUTDialog;
struct CDXUTListBox;

#pragma pack(push, 1)
struct SCScoreboard {
    BOOL m_bIsEnabled;
    int m_nPlayerCount;
    float m_position[2];
    float m_fScalar;
    float m_size[2];
    float pad[5];
    struct IDirect3DDevice9* m_pDevice;
    struct CDXUTDialog* m_pDialog;
    struct CDXUTListBox* m_pListBox;
    int m_nCurrentOffset;
    BOOL m_bIsSorted;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCScoreboard', 0x44)

local CScoreboard_constructor = ffi.cast(
    'void(__thiscall*)(SCScoreboard*, struct IDirect3DDevice9*)',
    sampapi.GetAddress(0x6E460)
)

local function CScoreboard_new(pDevice)
    local obj = ffi.new('struct SCScoreboard[1]')
    CScoreboard_constructor(obj, pDevice)
    return obj
end

local SCScoreboard_mt = {
    Recalc = ffi.cast(
        'void(__thiscall*)(SCScoreboard*)',
        sampapi.GetAddress(0x6E360)
    ),

    GetRect = ffi.cast(
        'void(__thiscall*)(SCScoreboard*, SCRect*)',
        sampapi.GetAddress(0x6E3C0)
    ),

    Close = ffi.cast(
        'void(__thiscall*)(SCScoreboard*, bool)',
        sampapi.GetAddress(0x6E410)
    ),

    ResetDialogControls = ffi.cast(
        'void(__thiscall*)(SCScoreboard*, struct CDXUTDialog*)',
        sampapi.GetAddress(0x6E4E0)
    ),

    SendNotification = ffi.cast(
        'void(__thiscall*)(SCScoreboard*)',
        sampapi.GetAddress(0x6E640)
    ),

    UpdateList = ffi.cast(
        'void(__thiscall*)(SCScoreboard*)',
        sampapi.GetAddress(0x6E760)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCScoreboard*)',
        sampapi.GetAddress(0x6EAF0)
    ),

    Enable = ffi.cast(
        'void(__thiscall*)(SCScoreboard*)',
        sampapi.GetAddress(0x6EE10)
    ),
}

mt.set_handler('struct SCScoreboard', '__index', SCScoreboard_mt)

local function RefScoreboard()
    return ffi.cast(
        'SCScoreboard**',
        sampapi.GetAddress(0x2AC9DC)
    )
end

return {
    new = CScoreboard_new,
    RefScoreboard = RefScoreboard,
}
