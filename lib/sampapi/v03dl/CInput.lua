
--[[
    Project: SAMP-API.lua
    SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CRect'
shared.require 'v03dl.Commands'

shared.ffi.cdef[[
enum {
    MAX_CLIENT_CMDS = 144,
    MAX_CMD_LENGTH = 32,
};

typedef struct SCInput SCInput;

#pragma pack(push, 1)
struct SCInput {
    struct IDirect3DDevice9* m_pDevice;
    struct CDXUTDialog* m_pGameUi;
    struct CDXUTEditBox* m_pEditbox;
    CMDPROC m_pCommandProc[144];
    char m_szCommandName[144][33];
    int m_nCommandCount;
    BOOL m_bEnabled;
    char m_szInput[129];
    char m_szRecallBufffer[10][129];
    char m_szCurrentBuffer[129];
    int m_nCurrentRecall;
    int m_nTotalRecall;
    CMDPROC m_pDefaultCommand;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCInput', 0x1AFC)

local function RefInputBox()
    return ffi.cast(
        'SCInput**',
        sampapi.GetAddress(0x2ACA14)
    )
end

local CInput_constructor = ffi.cast(
    'void(__thiscall*)(SCInput*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x68E10)
)

local function CInput_new(...)
    local obj = ffi.new('struct SCInput[1]')
    CInput_constructor(obj, ...)
    return obj
end

local SCInput_mt = {
    GetRect = ffi.cast(
        'void(__thiscall*)(SCInput*, SCRect*)',
        sampapi.GetAddress(0x68E80)
    ),

    Open = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x68EC0)
    ),

    Close = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x68FC0)
    ),

    AddRecall = ffi.cast(
        'void(__thiscall*)(SCInput*, const char*)',
        sampapi.GetAddress(0x69010)
    ),

    RecallUp = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x69070)
    ),

    RecallDown = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x690E0)
    ),

    EnableCursor = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x69130)
    ),

    GetCommandHandler = ffi.cast(
        'CMDPROC(__thiscall*)(SCInput*, const char*)',
        sampapi.GetAddress(0x69150)
    ),

    SetDefaultCommand = ffi.cast(
        'void(__thiscall*)(SCInput*, CMDPROC)',
        sampapi.GetAddress(0x691A0)
    ),

    AddCommand = ffi.cast(
        'void(__thiscall*)(SCInput*, const char*, CMDPROC)',
        sampapi.GetAddress(0x691B0)
    ),

    MsgProc = ffi.cast(
        'BOOL(__thiscall*)(SCInput*, int, int, int)',
        sampapi.GetAddress(0x69210)
    ),

    ResetDialogControls = ffi.cast(
        'void(__thiscall*)(SCInput*, CDXUTDialog*)',
        sampapi.GetAddress(0x69280)
    ),

    Send = ffi.cast(
        'void(__thiscall*)(SCInput*, const char*)',
        sampapi.GetAddress(0x69340)
    ),

    ProcessInput = ffi.cast(
        'void(__thiscall*)(SCInput*)',
        sampapi.GetAddress(0x69410)
    ),
}

mt.set_handler('struct SCInput', '__index', SCInput_mt)

return {
    RefInputBox = RefInputBox,
    new = CInput_new,
}
