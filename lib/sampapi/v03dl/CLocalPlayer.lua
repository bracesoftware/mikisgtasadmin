
--[[
    Project: SAMP-API.lua
    Class: CLocalPlayer
    Version: SA-MP 0.3.DL-1

    Based on BlastHack / LUCHARE SAMP-API 0.3.DL-1.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CPed'
shared.require 'v03dl.CVehicle'
shared.require 'v03dl.Animation'
shared.require 'v03dl.ControllerState'
shared.require 'v03dl.Synchronization'
shared.require 'CVector'

shared.ffi.cdef[[
enum SSpectatingMode {
    SPECTATING_MODE_VEHICLE = 3,
    SPECTATING_MODE_PLAYER = 4,
    SPECTATING_MODE_FIXED = 15,
    SPECTATING_MODE_SIDE = 14,
};
typedef enum SSpectatingMode SSpectatingMode;

enum SSpectatingType {
    SPEC_TYPE_NONE = 0,
    SPEC_TYPE_PLAYER = 1,
    SPEC_TYPE_VEHICLE = 2,
};
typedef enum SSpectatingType SSpectatingType;

enum SSurfingMode {
    SURF_MODE_NONE = 0,
    SURF_MODE_UNFIXED = 1,
    SURF_MODE_FIXED = 2,
};
typedef enum SSurfingMode SSurfingMode;

typedef struct SCameraTarget SCameraTarget;
#pragma pack(push, 1)
struct SCameraTarget {
    ID m_nObject;
    ID m_nVehicle;
    ID m_nPlayer;
    ID m_nActor;
};
#pragma pack(pop)

typedef struct SSpawnInfo SSpawnInfo;
#pragma pack(push, 1)
struct SSpawnInfo {
    NUMBER m_nTeam;
    int m_nSkin;
    int m_nCustomSkin;
    char field_9;
    SCVector m_position;
    float m_fRotation;
    int m_aWeapon[3];
    int m_aAmmo[3];
};
#pragma pack(pop)

typedef struct SCLocalPlayer SCLocalPlayer;
#pragma pack(push, 1)
struct SCLocalPlayer {
    SCPed* m_pPed;

    STrailerData m_trailerData;
    SOnfootData m_onfootData;
    SPassengerData m_passengerData;
    SIncarData m_incarData;
    SAimData m_aimData;

    BOOL m_bIsActive;
    BOOL m_bIsWasted;
    ID m_nCurrentVehicle;
    ID m_nLastVehicle;

    SAnimation m_animation;
    int field_104;

    SCameraTarget m_cameraTarget;
    TICK m_lastCameraTargetUpdate;

    struct {
        SCVector m_direction;
        TICK m_lastUpdate;
        TICK m_lastLook;
    } m_head;

    TICK m_lastAnyUpdate;
    BOOL m_bDoesSpectating;
    NUMBER m_nTeam;
    short field_131;

    TICK m_lastUpdate;
    TICK m_lastSpecUpdate;
    TICK m_lastAimUpdate;
    TICK m_lastStatsUpdate;

    BOOL m_bClearedToSpawn;
    TICK m_lastSelectionTick;
    TICK m_initialSelectionTick;

    SSpawnInfo m_spawnInfo;

    BOOL m_bHasSpawnInfo;
    TICK m_lastWeaponsUpdate;

    struct {
        ID m_nAimedPlayer;
        ID m_nAimedActor;
        NUMBER m_nCurrentWeapon;
        NUMBER m_aLastWeapon[13];
        int m_aLastWeaponAmmo[13];
    } m_weaponsData;

    BOOL m_bPassengerDriveBy;
    char m_nCurrentInterior;
    BOOL m_bInRCMode;
    char m_szName[256];

    struct {
        ID m_nEntityId;
        TICK m_lastUpdate;

        union {
            SCVehicle* m_pVehicle;
            SCObject* m_pObject;
        };

        BOOL m_bStuck;
        BOOL m_bIsActive;
        SCVector m_position;
        int field_1E;
        int m_nMode;
    } m_surfing;

    struct {
        BOOL m_bEnableAfterDeath;
        int m_nSelected;
        BOOL m_bWaitingForSpawnRequestReply;
        BOOL m_bIsActive;
    } m_classSelection;

    TICK m_zoneDisplayingEnd;

    struct {
        char m_nMode;
        char m_nType;
        int m_nObject;
        BOOL m_bProcessed;
    } m_spectating;

    struct {
        ID m_nVehicleUpdating;
        int m_nBumper;
        int m_nDoor;
        char m_bLight;
        char m_bWheel;
    } m_damage;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCameraTarget', 0x8)
shared.validate_size('struct SSpawnInfo', 0x35)

local function CLocalPlayer_new(...)
    local obj = ffi.new('struct SCLocalPlayer[1]')
    ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x4AF0)
    )(obj, ...)
    return obj
end

-- Static references.
-- These functions return pointers to the original game variables.
-- Use [0] to read or write their values.

local function RefIncarSendrate()
    return ffi.cast('int*', sampapi.GetAddress(0x13C0AC))
end

local function RefOnfootSendrate()
    return ffi.cast('int*', sampapi.GetAddress(0x13C0A8))
end

local function RefFiringSendrate()
    return ffi.cast('int*', sampapi.GetAddress(0x13C0B0))
end

local function RefSendMultiplier()
    return ffi.cast('int*', sampapi.GetAddress(0x13C0B4))
end

local SCLocalPlayer_mt = {
    GetPed = ffi.cast(
        'SCPed* (__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x2DA0)
    ),

    ResetData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x2EC0)
    ),

    ProcessHead = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x2FD0)
    ),

    SetSpecialAction = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, char)',
        sampapi.GetAddress(0x3110)
    ),

    GetSpecialAction = ffi.cast(
        'char(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3390)
    ),

    UpdateSurfing = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x34B0)
    ),

    SetSurfing = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, SCVehicle*, BOOL)',
        sampapi.GetAddress(0x3630)
    ),

    ProcessSurfing = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3650)
    ),

    NeedsToUpdate = ffi.cast(
        'BOOL(__thiscall*)(SCLocalPlayer*, const void*, const void*, unsigned int)',
        sampapi.GetAddress(0x3970)
    ),

    GetIncarSendRate = ffi.cast(
        'int(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x39C0)
    ),

    GetOnfootSendRate = ffi.cast(
        'int(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3A00)
    ),

    GetUnoccupiedSendRate = ffi.cast(
        'int(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3A40)
    ),

    SetSpawnInfo = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, const SSpawnInfo*)',
        sampapi.GetAddress(0x3AF0)
    ),

    Spawn = ffi.cast(
        'BOOL(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3B20)
    ),

    SetColor = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, D3DCOLOR)',
        sampapi.GetAddress(0x3DE0)
    ),

    GetColorAsRGBA = ffi.cast(
        'D3DCOLOR(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3E00)
    ),

    GetColorAsARGB = ffi.cast(
        'D3DCOLOR(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3E20)
    ),

    ProcessOnfootWorldBounds = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3E40)
    ),

    ProcessIncarWorldBounds = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3EA0)
    ),

    RequestSpawn = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3F40)
    ),

    PrepareForClassSelection = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x3F60)
    ),

    PrepareForClassSelection_Outcome = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, BOOL)',
        sampapi.GetAddress(0x3FB0)
    ),

    EnableSpectating = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, BOOL)',
        sampapi.GetAddress(0x4080)
    ),

    SpectateForVehicle = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, ID)',
        sampapi.GetAddress(0x40F0)
    ),

    SpectateForPlayer = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, ID)',
        sampapi.GetAddress(0x4140)
    ),

    NeedsToSendOnfootData = ffi.cast(
        'BOOL(__thiscall*)(SCLocalPlayer*, short, short, short)',
        sampapi.GetAddress(0x41C0)
    ),

    NeedsToSendIncarData = ffi.cast(
        'BOOL(__thiscall*)(SCLocalPlayer*, short, short, short)',
        sampapi.GetAddress(0x41F0)
    ),

    DefineCameraTarget = ffi.cast(
        'bool(__thiscall*)(SCLocalPlayer*, SCameraTarget*)',
        sampapi.GetAddress(0x4300)
    ),

    UpdateCameraTarget = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x45C0)
    ),

    DrawCameraTargetLabel = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x4710)
    ),

    SendUnoccupiedData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, ID, char)',
        sampapi.GetAddress(0x4BD0)
    ),

    SendOnfootData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x4DB0)
    ),

    SendAimData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5090)
    ),

    SendTrailerData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, ID)',
        sampapi.GetAddress(0x5240)
    ),

    SendPassengerData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5400)
    ),

    WastedNotification = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5660)
    ),

    RequestClass = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, int)',
        sampapi.GetAddress(0x5720)
    ),

    ChangeInterior = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, char)',
        sampapi.GetAddress(0x57C0)
    ),

    Chat = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, const char*)',
        sampapi.GetAddress(0x5860)
    ),

    EnterVehicle = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, int, BOOL)',
        sampapi.GetAddress(0x5920)
    ),

    ExitVehicle = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, int)',
        sampapi.GetAddress(0x5A40)
    ),

    SendStats = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5B50)
    ),

    UpdateVehicleDamage = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, ID)',
        sampapi.GetAddress(0x5C20)
    ),

    NextClass = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5E30)
    ),

    PrevClass = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5EC0)
    ),

    ProcessClassSelection = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5F40)
    ),

    UpdateWeapons = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x5F40)
    ),

    ProcessSpectating = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x6360)
    ),

    SendTakeDamage = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, int, float, int, int)',
        sampapi.GetAddress(0x66B0)
    ),

    SendGiveDamage = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*, int, float, int, int)',
        sampapi.GetAddress(0x67C0)
    ),

    ProcessUnoccupiedSync = ffi.cast(
        'bool(__thiscall*)(SCLocalPlayer*, ID, SCVehicle*)',
        sampapi.GetAddress(0x6C10)
    ),

    EnterVehicleAsPassenger = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x6DE0)
    ),

    SendIncarData = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x6E80)
    ),

    Process = ffi.cast(
        'void(__thiscall*)(SCLocalPlayer*)',
        sampapi.GetAddress(0x72D0)
    ),
}

mt.set_handler('struct SCLocalPlayer', '__index', SCLocalPlayer_mt)

local Synchronization = {}
local AimStuff = {}

return {
    new = CLocalPlayer_new,

    RefIncarSendrate = RefIncarSendrate,
    RefOnfootSendrate = RefOnfootSendrate,
    RefFiringSendrate = RefFiringSendrate,
    RefSendMultiplier = RefSendMultiplier,

    Synchronization = Synchronization,
    AimStuff = AimStuff,
}
