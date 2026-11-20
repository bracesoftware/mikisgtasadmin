
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCObjectSelection SCObjectSelection;
#pragma pack(push, 1)
struct SCObjectSelection {
    BOOL m_bIsActive;
    ID m_nHoveredObject;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCObjectSelection', 0x6)

local CObjectSelection_constructor = ffi.cast(
    'void(__thiscall*)(SCObjectSelection*)',
    sampapi.GetAddress(0x6D440)
)

local function CObjectSelection_new(...)
    local obj = ffi.new('struct SCObjectSelection[1]')
    CObjectSelection_constructor(obj, ...)
    return obj
end

local SCObjectSelection_mt = {
    DefineObject = ffi.cast(
        'ID(__thiscall*)(SCObjectSelection*)',
        sampapi.GetAddress(0x6D450)
    ),

    DrawLabels = ffi.cast(
        'void(__thiscall*)(SCObjectSelection*)',
        sampapi.GetAddress(0x6D4A0)
    ),

    Enable = ffi.cast(
        'void(__thiscall*)(SCObjectSelection*, BOOL)',
        sampapi.GetAddress(0x6D5C0)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCObjectSelection*)',
        sampapi.GetAddress(0x6D640)
    ),

    SendNotification = ffi.cast(
        'void(__thiscall*)(SCObjectSelection*)',
        sampapi.GetAddress(0x6D710)
    ),

    MsgProc = ffi.cast(
        'BOOL(__thiscall*)(SCObjectSelection*, int, int, int)',
        sampapi.GetAddress(0x6D880)
    ),
}

mt.set_handler('struct SCObjectSelection', '__index', SCObjectSelection_mt)

local function RefObjectSelection()
    return ffi.cast(
        'SCObjectSelection**',
        sampapi.GetAddress(0x2AC9F4)
    )
end

return {
    new = CObjectSelection_new,
    RefObjectSelection = RefObjectSelection,
}
