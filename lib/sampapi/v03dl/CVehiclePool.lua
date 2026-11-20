
local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CVehicle'
shared.require 'CVector'

shared.ffi.cdef[[
enum {
    MAX_VEHICLES = 2000,
    WAITING_LIST_SIZE = 100,
};

typedef struct SCGameVehicle SCGameVehicle;
typedef struct SVehicleInfo SVehicleInfo;
typedef struct SCVehiclePool SCVehiclePool;

#pragma pack(push, 1)

struct SVehicleInfo {
    ID m_nId;
    int m_nType;
    SCVector m_position;
    float m_fRotation;
    NUMBER m_nPrimaryColor;
    NUMBER m_nSecondaryColor;
    float m_fHealth;
    char m_nInterior;
    int m_nDoorDamageStatus;
    int m_nPanelDamageStatus;
    char m_nLightDamageStatus;
    bool m_bDoorsLocked;
    bool m_bHasSiren;
};

struct SCVehiclePool {
    int m_nCount;

    struct {
        SVehicleInfo m_entry[100];
        BOOL m_bNotEmpty[100];
    } m_waiting;

    SCVehicle* m_pObject[2000];
    BOOL m_bNotEmpty[2000];
    SCGameVehicle* m_pGameObject[2000];
    int pad_6ef4[2000];
    ID m_nLastUndrivenId[2000];
    TICK m_lastUndrivenProcessTick[2000];
    BOOL m_bIsActive[2000];
    BOOL m_bIsDestroyed[2000];
    TICK m_tickWhenDestroyed[2000];
    SCVector m_spawnedAt[2000];
    BOOL m_bNeedsToInitializeLicensePlates;
};

#pragma pack(pop)
]]

shared.validate_size('struct SVehicleInfo', 0x28)
shared.validate_size('struct SCVehiclePool', 0x17898)

local CVehiclePool_constructor =
    ffi.cast('void(__thiscall*)(SCVehiclePool*)', sampapi.GetAddress(0x1E4D0))

local CVehiclePool_destructor =
    ffi.cast('void(__thiscall*)(SCVehiclePool*)', sampapi.GetAddress(0x1EB20))

local function CVehiclePool_new()
    local obj = ffi.gc(
        ffi.new('struct SCVehiclePool[1]'),
        CVehiclePool_destructor
    )
    CVehiclePool_constructor(obj)
    return obj
end

local SCVehiclePool_mt = {
    UpdateCount = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1E470)
    ),

    Delete = ffi.cast(
        'BOOL(__thiscall*)(SCVehiclePool*, ID)',
        sampapi.GetAddress(0x1E540)
    ),

    ChangeInterior = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*, ID, int)',
        sampapi.GetAddress(0x1E5C0)
    ),

    SetParams = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*, ID, bool, bool)',
        sampapi.GetAddress(0x1E5F0)
    ),

    Find = ffi.cast(
        'ID(__thiscall*)(SCVehiclePool*, SCGameVehicle*)',
        sampapi.GetAddress(0x1E650)
    ),

    GetRefById = ffi.cast(
        'GTAREF(__thiscall*)(SCVehiclePool*, int)',
        sampapi.GetAddress(0x1E680)
    ),

    GetRefByGameVehicle = ffi.cast(
        'GTAREF(__thiscall*)(SCVehiclePool*, SCGameVehicle*)',
        sampapi.GetAddress(0x1E6A0)
    ),

    GetNearest = ffi.cast(
        'ID(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1E6C0)
    ),

    GetNearestToPoint = ffi.cast(
        'ID(__thiscall*)(SCVehiclePool*, SCVector)',
        sampapi.GetAddress(0x1E730)
    ),

    AddToWaitingList = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*, const SVehicleInfo*)',
        sampapi.GetAddress(0x1E7D0)
    ),

    ConstructLicensePlates = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1E830)
    ),

    ShutdownLicensePlates = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1E8A0)
    ),

    Create = ffi.cast(
        'BOOL(__thiscall*)(SCVehiclePool*, SVehicleInfo*)',
        sampapi.GetAddress(0x1EB40)
    ),

    SendDestroyNotification = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*, ID)',
        sampapi.GetAddress(0x1ECF0)
    ),

    ProcessWaitingList = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1EDC0)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCVehiclePool*)',
        sampapi.GetAddress(0x1EE80)
    ),

    Get = ffi.cast(
        'SCVehicle*(__thiscall*)(SCVehiclePool*, ID)',
        sampapi.GetAddress(0x1120)
    ),

    DoesExist = ffi.cast(
        'BOOL(__thiscall*)(SCVehiclePool*, ID)',
        sampapi.GetAddress(0x1150)
    ),
}

mt.set_handler('struct SCVehiclePool', '__index', SCVehiclePool_mt)

return {
    new = CVehiclePool_new,
}
