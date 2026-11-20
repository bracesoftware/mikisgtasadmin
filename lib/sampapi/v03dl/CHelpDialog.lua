
--[[
    Project: SAMP-API.lua
    SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCHelpDialog SCHelpDialog;

#pragma pack(push, 1)
struct SCHelpDialog {
    struct IDirect3DDevice9* m_pDevice;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCHelpDialog', 0x4)

local CHelpDialog_constructor = ffi.cast(
    'void(__thiscall*)(SCHelpDialog*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x6B566)
)

local function CHelpDialog_new(...)
    local obj = ffi.new('struct SCHelpDialog[1]')
    CHelpDialog_constructor(obj, ...)
    return obj
end

local SCHelpDialog_mt = {
    Show = ffi.cast(
        'void(__thiscall*)(SCHelpDialog*)',
        sampapi.GetAddress(0x6B570)
    ),
}

mt.set_handler('struct SCHelpDialog', '__index', SCHelpDialog_mt)

local function RefHelpDialog()
    return ffi.cast(
        'SCHelpDialog**',
        sampapi.GetAddress(0x2ACA04)
    )
end

return {
    new = CHelpDialog_new,
    RefHelpDialog = RefHelpDialog,
}
