
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct CDXUTDialog CDXUTDialog;
typedef struct CDXUTControl CDXUTControl;
typedef struct CDXUTDialogResourceManager CDXUTDialogResourceManager;
typedef struct IDirect3DSurface9 IDirect3DSurface9;
typedef struct IDirect3DDevice9 IDirect3DDevice9;
]]

local function RefResourceMgr()
    return ffi.cast(
        'CDXUTDialogResourceManager**',
        sampapi.GetAddress(0x2ACAB0)
    )
end

local function RefGameUi()
    return ffi.cast(
        'CDXUTDialog**',
        sampapi.GetAddress(0x2ACAB4)
    )
end

local function RefScoreboard()
    return ffi.cast(
        'CDXUTDialog**',
        sampapi.GetAddress(0x2ACAB8)
    )
end

local function RefDialog()
    return ffi.cast(
        'CDXUTDialog**',
        sampapi.GetAddress(0x2ACAC0)
    )
end

local function RefClassSelection()
    return ffi.cast(
        'CDXUTDialog**',
        sampapi.GetAddress(0x2ACABC)
    )
end

local function RefCursor()
    return ffi.cast(
        'IDirect3DSurface9**',
        sampapi.GetAddress(0x2ACACC)
    )
end

local function RefDevice()
    return ffi.cast(
        'IDirect3DDevice9**',
        sampapi.GetAddress(0x2AC9D0)
    )
end

local Initialize = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xC6CE0)
)

local OnLostDevice = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xC5620)
)

local OnResetDevice = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xC5880)
)

local GameUIEventHandler = ffi.cast(
    'void(__stdcall*)(unsigned int, int, CDXUTControl*, void*)',
    sampapi.GetAddress(0xC6BF0)
)

local ScoreboardEventHandler = ffi.cast(
    'void(__stdcall*)(unsigned int, int, CDXUTControl*, void*)',
    sampapi.GetAddress(0xC6C30)
)

local DialogEventHandler = ffi.cast(
    'void(__stdcall*)(unsigned int, int, CDXUTControl*, void*)',
    sampapi.GetAddress(0xC6B60)
)

local ClassSelectionEventHandler = ffi.cast(
    'void(__stdcall*)(unsigned int, int, CDXUTControl*, void*)',
    sampapi.GetAddress(0xC6C60)
)

return {
    RefResourceMgr = RefResourceMgr,
    RefGameUi = RefGameUi,
    RefScoreboard = RefScoreboard,
    RefDialog = RefDialog,
    RefClassSelection = RefClassSelection,
    RefCursor = RefCursor,
    RefDevice = RefDevice,

    Initialize = Initialize,
    OnLostDevice = OnLostDevice,
    OnResetDevice = OnResetDevice,

    GameUIEventHandler = GameUIEventHandler,
    ScoreboardEventHandler = ScoreboardEventHandler,
    DialogEventHandler = DialogEventHandler,
    ClassSelectionEventHandler = ClassSelectionEventHandler,
}
