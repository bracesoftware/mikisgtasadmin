
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
enum {
    MAX_MENU_ITEMS = 12,
    MAX_COLUMNS = 2,
    MAX_MENU_LINE = 32,
};

typedef struct SInteraction SInteraction;
#pragma pack(push, 1)
struct SInteraction {
    BOOL m_bMenu;
    BOOL m_bRow[MAX_MENU_ITEMS];
    BOOL m_bPadding[3];
};
#pragma pack(pop)

typedef struct SCMenu SCMenu;
#pragma pack(push, 1)
struct SCMenu {
    unsigned char m_nId;
    char m_szTitle[MAX_MENU_LINE];
    char m_szItems[MAX_MENU_ITEMS][MAX_COLUMNS][MAX_MENU_LINE];
    char m_szHeader[MAX_COLUMNS][MAX_MENU_LINE];
    float m_fPosX;
    float m_fPosY;
    float m_fFirstColumnWidth;
    float m_fSecondColumnWidth;
    unsigned char m_nColumns;
    SInteraction m_interaction;
    unsigned char m_nColumnCount[MAX_COLUMNS];
    GTAREF m_panel;
};
#pragma pack(pop)
]]

shared.validate_size('struct SInteraction', 0x40)
shared.validate_size('struct SCMenu', 0x3B8)

local CMenu_constructor = ffi.cast(
    'void(__thiscall*)(SCMenu*, float, float, char, float, float, const SInteraction*)',
    sampapi.GetAddress(0xA7160)
)

local CMenu_Hide = ffi.cast(
    'void(__thiscall*)(SCMenu*)',
    sampapi.GetAddress(0xA7260)
)

local function CMenu_new(...)
    local obj = ffi.new('struct SCMenu[1]')

    if select('#', ...) == 0 then
        -- Default constructor: CMenu() { Hide(); }
        CMenu_Hide(obj)
    else
        CMenu_constructor(obj, ...)
    end

    return obj
end

local SCMenu_mt = {
    AddItem = ffi.cast(
        'void(__thiscall*)(SCMenu*, NUMBER, NUMBER, const char*)',
        sampapi.GetAddress(0xA7200)
    ),

    SetColumnTitle = ffi.cast(
        'void(__thiscall*)(SCMenu*, NUMBER, const char*)',
        sampapi.GetAddress(0xA7230)
    ),

    Hide = CMenu_Hide,

    GetItem = ffi.cast(
        'char*(__thiscall*)(SCMenu*, NUMBER, NUMBER)',
        sampapi.GetAddress(0xA7280)
    ),

    GetTitle = ffi.cast(
        'char*(__thiscall*)(SCMenu*)',
        sampapi.GetAddress(0xA72A0)
    ),

    MS = ffi.cast(
        'char*(__thiscall*)(SCMenu*, NUMBER, NUMBER)',
        sampapi.GetAddress(0xA72D0)
    ),

    GetActiveRow = ffi.cast(
        'char(__thiscall*)(SCMenu*)',
        sampapi.GetAddress(0xA7300)
    ),

    Show = ffi.cast(
        'void(__thiscall*)(SCMenu*)',
        sampapi.GetAddress(0xA7330)
    ),
}

mt.set_handler('struct SCMenu', '__index', SCMenu_mt)

return {
    new = CMenu_new,
}
