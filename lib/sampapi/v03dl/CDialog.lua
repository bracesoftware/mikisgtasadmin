
--[[
    Project: SAMP-API.lua <https://github.com/imring/SAMP-API.lua>
    Developers: imring, LUCHARE, FYP

    Special thanks:
        SAMemory (https://www.blast.hk/threads/20472/) for implementing the basic functions.
        SAMP-API (https://github.com/BlastHackNet/SAMP-API) for the structures and addresses.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CRect'

shared.ffi.cdef[[
enum SDialogType {
    DIALOG_MESSAGEBOX = 0,
    DIALOG_INPUT = 1,
    DIALOG_LIST = 2,
    DIALOG_PASSWORD = 3,
    DIALOG_TABLIST = 4,
    DIALOG_HEADERSLIST = 5,
};
typedef enum SDialogType SDialogType;

typedef struct SCDialog SCDialog;

#pragma pack(push, 1)
struct SCDialog {
    struct IDirect3DDevice9* m_pDevice;
    unsigned long m_position[2];
    unsigned long m_size[2];
    unsigned long m_buttonOffset[2];
    struct CDXUTDialog* m_pDialog;
    struct CDXUTListBox* m_pListbox;
    struct CDXUTIMEEditBox* m_pEditbox;
    BOOL m_bIsActive;
    int m_nType;
    int m_nId;
    char* m_szText;
    unsigned long m_textSize[2];
    char m_szCaption[65];
    BOOL m_bServerside;
};
#pragma pack(pop)
]]

local CDialog_constructor = ffi.cast(
    'void(__thiscall*)(SCDialog*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x6EEC0)
)

local function CDialog_new(...)
    local obj = ffi.new('struct SCDialog[1]')
    CDialog_constructor(obj, ...)
    return obj
end

local SCDialog_mt = {
    GetScreenRect = ffi.cast(
        'void(__thiscall*)(SCDialog*, SCRect*)',
        sampapi.GetAddress(0x6F0F0)
    ),

    GetTextScreenLength = ffi.cast(
        'int(__thiscall*)(SCDialog*, const char*)',
        sampapi.GetAddress(0x6F120)
    ),

    Hide = ffi.cast(
        'void(__thiscall*)(SCDialog*)',
        sampapi.GetAddress(0x6F2A0)
    ),

    ResetDialogControls = ffi.cast(
        'void(__thiscall*)(SCDialog*, CDXUTDialog*)',
        sampapi.GetAddress(0x6F460)
    ),

    Show = ffi.cast(
        'void(__thiscall*)(SCDialog*, int, int, const char*, const char*, const char*, const char*, BOOL)',
        sampapi.GetAddress(0x6FA50)
    ),

    Close = ffi.cast(
        'void(__thiscall*)(SCDialog*, char)',
        sampapi.GetAddress(0x700D0)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCDialog*)',
        sampapi.GetAddress(0x6F2D0)
    ),
}

mt.set_handler('struct SCDialog', '__index', SCDialog_mt)

local function RefDialog()
    return ffi.cast('SCDialog**', sampapi.GetAddress(0x2AC9E0))
end

return {
    new = CDialog_new,
    RefDialog = RefDialog,
}
