
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CPlayerInfo'
shared.require 'v03dl.CRemotePlayer'

shared.ffi.cdef[[
enum {
    MAX_PLAYERS = 1004,
};

typedef struct SCLocalPlayer SCLocalPlayer;
typedef struct SCPlayerPool SCPlayerPool;
typedef struct SCGamePed SCGamePed;
typedef struct SCGameObject SCGameObject;
typedef struct SCObject SCObject;

#pragma pack(push, 1)
struct SCPlayerPool {
    ID m_nLocalPlayerId;
    int __align;
    unsigned char m_szLocalPlayerName[28];
    SCLocalPlayer* pLocalPlayer;
    int m_nLargestId;
    SCPlayerInfo* m_pObject[1004];
    BOOL m_bNotEmpty[1004];
    BOOL m_bPrevCollisionFlag[1004];
    int m_nLocalPlayerPing;
    int m_nLocalPlayerScore;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCPlayerPool', 0x2F42)

local CPlayerPool_constructor = ffi.cast(
    'void(__thiscall*)(SCPlayerPool*)',
    sampapi.GetAddress(0x13E80)
)

local CPlayerPool_destructor = ffi.cast(
    'void(__thiscall*)(SCPlayerPool*)',
    sampapi.GetAddress(0x13FD0)
)

local function CPlayerPool_new()
    local obj = ffi.gc(
        ffi.new('struct SCPlayerPool[1]'),
        CPlayerPool_destructor
    )
    CPlayerPool_constructor(obj)
    return obj
end

local SCPlayerPool_mt = {
    UpdateLargestId = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x13650)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x136C0)
    ),

    Find = ffi.cast(
        'ID(__thiscall*)(SCPlayerPool*, SCGamePed*)',
        sampapi.GetAddress(0x137C0)
    ),

    Deactivate = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x139F0)
    ),

    ForceCollision = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x13B50)
    ),

    RestoreCollision = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x13BD0)
    ),

    Delete = ffi.cast(
        'BOOL(__thiscall*)(SCPlayerPool*, ID, int)',
        sampapi.GetAddress(0x13F40)
    ),

    Create = ffi.cast(
        'BOOL(__thiscall*)(SCPlayerPool*, ID, const char*, BOOL)',
        sampapi.GetAddress(0x14100)
    ),

    GetPlayer = ffi.cast(
        'SCRemotePlayer*(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x10F0)
    ),

    GetLocalPlayerName = ffi.cast(
        'const char*(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0xA1D0)
    ),

    IsDisconnected = ffi.cast(
        'BOOL(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x10D0)
    ),

    IsConnected = ffi.cast(
        'BOOL(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x10B0)
    ),

    SetLocalPlayerName = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*, const char*)',
        sampapi.GetAddress(0xB580)
    ),

    SetAt = ffi.cast(
        'void(__thiscall*)(SCPlayerPool*, ID, SCPlayerInfo*)',
        sampapi.GetAddress(0x13630)
    ),

    GetScore = ffi.cast(
        'int(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x6E290)
    ),

    GetPing = ffi.cast(
        'int(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x6E2B0)
    ),

    GetName = ffi.cast(
        'const char*(__thiscall*)(SCPlayerPool*, ID)',
        sampapi.GetAddress(0x170D0)
    ),

    GetLocalPlayerPing = ffi.cast(
        'int(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x6E2F0)
    ),

    GetLocalPlayerScore = ffi.cast(
        'int(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x6E2E0)
    ),

    GetCount = ffi.cast(
        'int(__thiscall*)(SCPlayerPool*, BOOL)',
        sampapi.GetAddress(0x138C0)
    ),

    GetLocalPlayer = ffi.cast(
        'SCLocalPlayer*(__thiscall*)(SCPlayerPool*)',
        sampapi.GetAddress(0x1A80)
    ),

    FindAccessory = ffi.cast(
        'SCObject*(__thiscall*)(SCPlayerPool*, SCGameObject*)',
        sampapi.GetAddress(0x13A40)
    ),
}

mt.set_handler('struct SCPlayerPool', '__index', SCPlayerPool_mt)

return {
    new = CPlayerPool_new,
}
