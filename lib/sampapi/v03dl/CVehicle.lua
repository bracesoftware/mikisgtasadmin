
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CEntity'
shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
enum {
    MAX_LICENSE_PLATE_TEXT = 32,
};

typedef struct SCVehicle SCVehicle;

struct CEntity;
struct CVehicle;
struct IDirect3DTexture9;

#pragma pack(push, 1)
struct SCVehicle {
    // CEntity base fields (flattened for LuaJIT FFI)
    void** m_lpVtbl;
    char pad_4[60];
    struct CEntity* m_pGameEntity;
    GTAREF m_handle;

    // CVehicle fields
    SCVehicle* m_pTrailer;
    struct CVehicle* m_pGameVehicle;
    BOOL m_bEngineOn;
    BOOL m_bIsLightsOn;
    BOOL m_bIsInvulnerable;
    int pad_5c;
    BOOL m_bIsLocked;
    bool m_bIsObjective;
    BOOL m_bObjectiveBlipCreated;
    TICK m_timeSinceLastDriven;
    BOOL m_bHasBeenDriven;
    int pad_71;
    BOOL m_bEngineState;
    unsigned char m_nPrimaryColor;
    unsigned char m_nSecondaryColor;
    BOOL m_bNeedsToUpdateColor;
    BOOL m_bUnoccupiedSync;
    BOOL m_bRemoteUnocSync;
    BOOL m_bKeepModelLoaded;
    BOOL m_bHasSiren;
    struct IDirect3DTexture9* m_pLicensePlate;
    char m_szLicensePlateText[MAX_LICENSE_PLATE_TEXT + 1];
    GTAREF m_marker;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCVehicle', 0xB8)

local CVehicle_constructor = ffi.cast(
    'void(__thiscall*)(SCVehicle*, int, SCVector, float, BOOL, BOOL)',
    sampapi.GetAddress(0xB7F00)
)

local function CVehicle_new(nModel, position, fRotation, bKeepModelLoaded, bHasSiren)
    local obj = ffi.new('struct SCVehicle[1]')
    CVehicle_constructor(
        obj,
        nModel,
        position,
        fRotation,
        bKeepModelLoaded,
        bHasSiren
    )
    return obj
end

local SCVehicle_mt = {
    ChangeInterior = ffi.cast(
        'void(__thiscall*)(SCVehicle*, int)',
        sampapi.GetAddress(0xB6BD0)
    ),

    ResetPointers = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6C00)
    ),

    HasDriver = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6C20)
    ),

    IsOccupied = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6C70)
    ),

    SetInvulnerable = ffi.cast(
        'void(__thiscall*)(SCVehicle*, BOOL)',
        sampapi.GetAddress(0xB6CD0)
    ),

    SetLocked = ffi.cast(
        'void(__thiscall*)(SCVehicle*, BOOL)',
        sampapi.GetAddress(0xB6D70)
    ),

    GetHealth = ffi.cast(
        'float(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6DE0)
    ),

    SetHealth = ffi.cast(
        'void(__thiscall*)(SCVehicle*, float)',
        sampapi.GetAddress(0xB6E00)
    ),

    SetColor = ffi.cast(
        'void(__thiscall*)(SCVehicle*, NUMBER, NUMBER)',
        sampapi.GetAddress(0xB6E20)
    ),

    UpdateColor = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6E70)
    ),

    GetSubtype = ffi.cast(
        'int(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6ED0)
    ),

    IsSunk = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6EF0)
    ),

    IsWrecked = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6F10)
    ),

    DriverIsPlayerPed = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6F30)
    ),

    HasPlayerPed = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6F60)
    ),

    IsTrainPart = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6FA0)
    ),

    HasTurret = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB6FE0)
    ),

    EnableSiren = ffi.cast(
        'void(__thiscall*)(SCVehicle*, bool)',
        sampapi.GetAddress(0xB7080)
    ),

    SirenEnabled = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB70A0)
    ),

    SetLandingGearState = ffi.cast(
        'void(__thiscall*)(SCVehicle*, BOOL)',
        sampapi.GetAddress(0xB70E0)
    ),

    GetLandingGearState = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7170)
    ),

    SetHydraThrusters = ffi.cast(
        'void(__thiscall*)(SCVehicle*, int)',
        sampapi.GetAddress(0xB71E0)
    ),

    GetHydraThrusters = ffi.cast(
        'int(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7200)
    ),

    ProcessMarkers = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7220)
    ),

    Lock = ffi.cast(
        'void(__thiscall*)(SCVehicle*, BOOL)',
        sampapi.GetAddress(0xB7380)
    ),

    UpdateLastDrivenTime = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB73B0)
    ),

    GetTrainSpeed = ffi.cast(
        'float(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7420)
    ),

    SetTrainSpeed = ffi.cast(
        'void(__thiscall*)(SCVehicle*, float)',
        sampapi.GetAddress(0xB7440)
    ),

    SetTires = ffi.cast(
        'void(__thiscall*)(SCVehicle*, char)',
        sampapi.GetAddress(0xB7480)
    ),

    GetTires = ffi.cast(
        'char(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7570)
    ),

    UpdateDamage = ffi.cast(
        'void(__thiscall*)(SCVehicle*, int, int, char)',
        sampapi.GetAddress(0xB7600)
    ),

    GetPanelsDamage = ffi.cast(
        'int(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB76C0)
    ),

    GetDoorsDamage = ffi.cast(
        'int(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB76F0)
    ),

    GetLightsDamage = ffi.cast(
        'char(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7720)
    ),

    AttachTrailer = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7750)
    ),

    DetachTrailer = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7770)
    ),

    SetTrailer = ffi.cast(
        'void(__thiscall*)(SCVehicle*, SCVehicle*)',
        sampapi.GetAddress(0xB77C0)
    ),

    GetTrailer = ffi.cast(
        'SCVehicle*(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB77D0)
    ),

    GetTractor = ffi.cast(
        'SCVehicle*(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7830)
    ),

    IsTrailer = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB78B0)
    ),

    IsTowtruck = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7910)
    ),

    IsRC = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7940)
    ),

    EnableLights = ffi.cast(
        'void(__thiscall*)(SCVehicle*, bool)',
        sampapi.GetAddress(0xB7990)
    ),

    RemovePassengers = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7A20)
    ),

    AddComponent = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*, unsigned short)',
        sampapi.GetAddress(0xB7B00)
    ),

    RemoveComponent = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*, unsigned short)',
        sampapi.GetAddress(0xB7BE0)
    ),

    SetPaintjob = ffi.cast(
        'void(__thiscall*)(SCVehicle*, NUMBER)',
        sampapi.GetAddress(0xB7C20)
    ),

    DoesExist = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7C70)
    ),

    SetLicensePlateText = ffi.cast(
        'void(__thiscall*)(SCVehicle*, const char*)',
        sampapi.GetAddress(0xB7C80)
    ),

    SetRotation = ffi.cast(
        'void(__thiscall*)(SCVehicle*, float)',
        sampapi.GetAddress(0xB7CA0)
    ),

    ConstructLicensePlate = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7CD0)
    ),

    ShutdownLicensePlate = ffi.cast(
        'void(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7D20)
    ),

    HasSiren = ffi.cast(
        'BOOL(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7E60)
    ),

    GetMaxPassengers = ffi.cast(
        'char(__thiscall*)(SCVehicle*)',
        sampapi.GetAddress(0xB7E70)
    ),

    SetWindowOpenFlag = ffi.cast(
        'void(__thiscall*)(SCVehicle*, NUMBER)',
        sampapi.GetAddress(0xB7EA0)
    ),

    ClearWindowOpenFlag = ffi.cast(
        'void(__thiscall*)(SCVehicle*, NUMBER)',
        sampapi.GetAddress(0xB7ED0)
    ),

    EnableEngine = ffi.cast(
        'void(__thiscall*)(SCVehicle*, BOOL)',
        sampapi.GetAddress(0xB85A0)
    ),
}

mt.set_handler('struct SCVehicle', '__index', SCVehicle_mt)

return {
    new = CVehicle_new,
}
