
--[[
    Project: SAMP-API.lua
    Developers: imring, LUCHARE, FYP

    SA-MP 0.3.DL-1
    Based on BlastHack SAMP-API C++ implementation.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = shared.ffi

shared.require 'v03dl.CEntity'
shared.require 'v03dl.CActor'
shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SActorInfo SActorInfo;

#pragma pack(push, 1)
struct SActorInfo {
    ID m_nId;
    int m_nModel;
    int pad_1;
    SCVector m_position;
    float m_fRotation;
    float m_fHealth;
    bool m_bInvulnerable;
};
#pragma pack(pop)

enum {
    MAX_ACTORS = 1000,
};

typedef struct SCActorPool SCActorPool;

#pragma pack(push, 1)
struct SCActorPool {
    int m_nLargestId;
    SCActor* m_pObject[1000];
    BOOL m_bNotEmpty[1000];
    struct CPed* m_pGameObject[1000];
    int pad_2ee4[1000];
    int pad_3e84[1000];
};
#pragma pack(pop)
]]

shared.validate_size('struct SActorInfo', 0x1F)
shared.validate_size('struct SCActorPool', 0x4E24)

-- Constructor / Destructor

local CActorPool_constructor =
    ffi.cast(
        'void(__thiscall*)(SCActorPool*)',
        sampapi.GetAddress(0x16C0)
    )

local CActorPool_destructor =
    ffi.cast(
        'void(__thiscall*)(SCActorPool*)',
        sampapi.GetAddress(0x18E0)
    )

local function CActorPool_new(...)
    local obj = ffi.gc(
        ffi.new('struct SCActorPool[1]'),
        CActorPool_destructor
    )

    CActorPool_constructor(obj, ...)

    return obj
end

-- Methods

local SCActorPool_mt = {
    Get = ffi.cast(
        'SCActor*(__thiscall*)(SCActorPool*, ID)',
        sampapi.GetAddress(0x1615)
    ),

    DoesExist = ffi.cast(
        'BOOL(__thiscall*)(SCActorPool*, ID)',
        sampapi.GetAddress(0x1640)
    ),

    UpdateLargestId = ffi.cast(
        'void(__thiscall*)(SCActorPool*)',
        sampapi.GetAddress(0x1660)
    ),

    Delete = ffi.cast(
        'BOOL(__thiscall*)(SCActorPool*, ID)',
        sampapi.GetAddress(0x16F0)
    ),

    Find = ffi.cast(
        'ID(__thiscall*)(SCActorPool*, struct CPed*)',
        sampapi.GetAddress(0x18B0)
    ),

    Create = ffi.cast(
        'BOOL(__thiscall*)(SCActorPool*, SActorInfo*)',
        sampapi.GetAddress(0x1900)
    ),
}

mt.set_handler('struct SCActorPool', '__index', SCActorPool_mt)

return {
    new = CActorPool_new,
}
