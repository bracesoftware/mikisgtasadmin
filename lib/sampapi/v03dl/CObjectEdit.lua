
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CPoint'
shared.require 'CRect'
shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
struct IDirect3DDevice9;
struct ID3DXLine;
struct ID3DXFont;

enum SObjectEditType {
    OBJECT_EDIT_TYPE_NONE = 0,
    OBJECT_EDIT_TYPE_ATTACHEDOBJECT = 2,
    OBJECT_EDIT_TYPE_OBJECT = 1,
};
typedef enum SObjectEditType SObjectEditType;

enum SObjectEditMode {
    OBJECT_EDIT_MODE_POSITION = 0,
    OBJECT_EDIT_MODE_ROTATION = 1,
    OBJECT_EDIT_MODE_SCALE = 2,
};
typedef enum SObjectEditMode SObjectEditMode;

enum SObjectEditProcessType {
    OBJECT_EDIT_PROCESS_TYPE_XAXIS = 0,
    OBJECT_EDIT_PROCESS_TYPE_YAXIS = 1,
    OBJECT_EDIT_PROCESS_TYPE_ZAXIS = 2,
    OBJECT_EDIT_PROCESS_TYPE_SETPOSITION = 3,
    OBJECT_EDIT_PROCESS_TYPE_SETROTATION = 4,
    OBJECT_EDIT_PROCESS_TYPE_SETSCALE = 5,
    OBJECT_EDIT_PROCESS_TYPE_SAVE = 10,
};
typedef enum SObjectEditProcessType SObjectEditProcessType;

typedef struct SCObjectEdit SCObjectEdit;
#pragma pack(push, 1)
struct SCObjectEdit {
    SCPoint m_CharMaxSize;

    SCRect m_xAxisButtonRect;
    SCRect m_yAxisButtonRect;
    SCRect m_zAxisButtonRect;
    SCRect m_PositionButtonRect;
    SCRect m_RotationButtonRect;
    SCRect m_ScaleButtonRect;
    SCRect m_SaveButtonRect;

    int m_nEditType;
    int m_nEditMode;
    BOOL m_bEnabled;
    BOOL m_bRenderedThisFrame;
    ID m_nEditObjectId;
    unsigned int m_nAttachedObjectIndex;
    BOOL m_bIsPlayerObject;

    SCVector m_vRotation;
    unsigned int m_nLastSentNotificationTick;

    bool m_bRenderScaleButton;
    bool m_bEditingRightNow;
    bool m_bTopXOfObjectIsOnLeftOfScreen;
    bool m_bTopYOfObjectIsOnLeftOfScreen;
    bool m_bTopZOfObjectIsOnLeftOfScreen;

    SCPoint m_EditStartPos;
    SCPoint m_CursorPosInGame;

    BOOL m_bObjectXSizeYCoordDiffMoreThanX;
    BOOL m_bObjectYSizeYCoordDiffMoreThanX;
    BOOL m_bObjectZSizeYCoordDiffMoreThanX;

    SCMatrix m_entityMatrix;

    struct IDirect3DDevice9* m_pDevice;
    struct ID3DXLine* m_pLine;
    struct ID3DXFont* m_pIconFontSmall;
    struct ID3DXFont* m_pIconFontBig;

    int m_nProcessType;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCObjectEdit', 0x117)

local CObjectEdit_constructor = ffi.cast(
    'void(__thiscall*)(SCObjectEdit*, IDirect3DDevice9*)',
    sampapi.GetAddress(0x71600)
)

local function CObjectEdit_new(...)
    local obj = ffi.new('struct SCObjectEdit[1]')
    CObjectEdit_constructor(obj, ...)
    return obj
end

local SCObjectEdit_mt = {
    WorldToScreen = ffi.cast(
        'float(__thiscall*)(SCObjectEdit*, SCVector*, float*)',
        sampapi.GetAddress(0x716C0)
    ),

    RenderAxes = ffi.cast(
        'int(__thiscall*)(SCObjectEdit*, SCMatrix*, float)',
        sampapi.GetAddress(0x717C0)
    ),

    GetRenderChar = ffi.cast(
        'const char*(__thiscall*)(SCObjectEdit*, BOOL)',
        sampapi.GetAddress(0x71A40)
    ),

    TryChangeProcessType = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*)',
        sampapi.GetAddress(0x71B40)
    ),

    SetEditMode = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, SObjectEditMode)',
        sampapi.GetAddress(0x71C90)
    ),

    ResetMousePos = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*)',
        sampapi.GetAddress(0x71E60)
    ),

    EnterEditObject = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, ID, BOOL)',
        sampapi.GetAddress(0x71EC0)
    ),

    SendEditEndNotification = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, int)',
        sampapi.GetAddress(0x72350)
    ),

    SendAttachedEditEndNotification = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, int)',
        sampapi.GetAddress(0x72560)
    ),

    Disable = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, BOOL)',
        sampapi.GetAddress(0x72660)
    ),

    RenderControlsForObject = ffi.cast(
        'BOOL(__thiscall*)(SCObjectEdit*, SCMatrix*, float)',
        sampapi.GetAddress(0x726D0)
    ),

    ApplyChanges = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*, SObjectEditProcessType, float)',
        sampapi.GetAddress(0x72F00)
    ),

    ProcessMouseMove = ffi.cast(
        'float(__thiscall*)(SCObjectEdit*)',
        sampapi.GetAddress(0x72F20)
    ),

    MsgProc = ffi.cast(
        'BOOL(__thiscall*)(SCObjectEdit*, int, int, int)',
        sampapi.GetAddress(0x72FF0)
    ),

    Render = ffi.cast(
        'void(__thiscall*)(SCObjectEdit*)',
        sampapi.GetAddress(0x73220)
    ),
}

mt.set_handler('struct SCObjectEdit', '__index', SCObjectEdit_mt)

local function GetMaxSizeChar()
    return ffi.cast(
        'const char*(__cdecl*)()',
        sampapi.GetAddress(0x71A30)
    )()
end

local function RefObjectEdit()
    return ffi.cast(
        'SCObjectEdit**',
        sampapi.GetAddress(0x2AC9F0)
    )
end

return {
    new = CObjectEdit_new,
    GetMaxSizeChar = GetMaxSizeChar,
    RefObjectEdit = RefObjectEdit,
}
