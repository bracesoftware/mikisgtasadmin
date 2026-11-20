
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SPickup SPickup;
#pragma pack(push, 1)
struct SPickup {
    int m_nModel;
    int m_nType;
    SCVector m_position;
};
#pragma pack(pop)

typedef struct SWeaponPickup SWeaponPickup;
#pragma pack(push, 1)
struct SWeaponPickup {
    bool m_bExists;
    ID m_nExOwner;
};
#pragma pack(pop)

enum {
    MAX_PICKUPS = 4096,
};

typedef struct SCPickupPool SCPickupPool;
#pragma pack(push, 1)
struct SCPickupPool {
    int m_nCount;
    GTAREF m_handle[MAX_PICKUPS];
    int m_nId[MAX_PICKUPS];
    unsigned long m_nTimer[MAX_PICKUPS];
    SWeaponPickup m_weapon[MAX_PICKUPS];
    SPickup m_object[MAX_PICKUPS];
};
#pragma pack(pop)
]]

shared.validate_size('struct SPickup', 0x14)
shared.validate_size('struct SWeaponPickup', 0x3)
shared.validate_size('struct SCPickupPool', 0x23004)

local CPickupPool_constructor = ffi.cast(
    'void(__thiscall*)(SCPickupPool*)',
    sampapi.GetAddress(0x8190)
)

local CPickupPool_destructor = ffi.cast(
    'void(__thiscall*)(SCPickupPool*)',
    sampapi.GetAddress(0x13310)
)

local function CPickupPool_new()
    local obj = ffi.gc(
        ffi.new('struct SCPickupPool[1]'),
        CPickupPool_destructor
    )
    CPickupPool_constructor(obj)
    return obj
end

local SCPickupPool_mt = {
    Create = ffi.cast(
        'void(__thiscall*)(SCPickupPool*, SPickup*, int)',
        sampapi.GetAddress(0x13170)
    ),

    CreateWeapon = ffi.cast(
        'void(__thiscall*)(SCPickupPool*, int, SCVector, int, ID)',
        sampapi.GetAddress(0x13080)
    ),

    Delete = ffi.cast(
        'void(__thiscall*)(SCPickupPool*, int)',
        sampapi.GetAddress(0x13220)
    ),

    DeleteWeapon = ffi.cast(
        'void(__thiscall*)(SCPickupPool*, ID)',
        sampapi.GetAddress(0x13280)
    ),

    GetIndex = ffi.cast(
        'int(__thiscall*)(SCPickupPool*, int)',
        sampapi.GetAddress(0x132E0)
    ),

    SendNotification = ffi.cast(
        'void(__thiscall*)(SCPickupPool*, int)',
        sampapi.GetAddress(0x13340)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCPickupPool*)',
        sampapi.GetAddress(0x13420)
    ),
}

mt.set_handler('struct SCPickupPool', '__index', SCPickupPool_mt)

return {
    new = CPickupPool_new,
}
