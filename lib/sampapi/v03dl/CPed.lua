
--[[
    Project: SAMP-API.lua <https://github.com/imring/SAMP-API.lua>
    Developers: imring, LUCHARE, FYP

    SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'v03dl.CEntity'
shared.require 'v03dl.AimStuff'
shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCObject SCObject;
typedef struct SCVehicle SCVehicle;
typedef struct SCWeapon SCWeapon;
typedef struct SCWeaponInfo SCWeaponInfo;

enum {
    MAX_ACCESSORIES = 10,
};

enum SStuffType {
    STUFF_TYPE_NONE = 0,
    STUFF_TYPE_BEER = 1,
    STUFF_TYPE_DYN_BEER = 2,
    STUFF_TYPE_PINT_GLASS = 3,
    STUFF_TYPE_CIGGI = 4,
};
typedef enum SStuffType SStuffType;

typedef struct SAccessory SAccessory;
#pragma pack(push, 1)
struct SAccessory {
    int m_nModel;
    int m_nBone;
    SCVector m_offset;
    SCVector m_rotation;
    SCVector m_scale;
    D3DCOLOR m_firstMaterialColor;
    D3DCOLOR m_secondMaterialColor;
};
#pragma pack(pop)

typedef struct SCPed SCPed;
#pragma pack(push, 1)
struct SCPed : SCEntity {
    BOOL m_bUsingCellphone;

    struct {
        BOOL m_bNotEmpty[MAX_ACCESSORIES];
        SAccessory m_info[MAX_ACCESSORIES];
        SCObject* m_pObject[MAX_ACCESSORIES];
    } m_accessories;

    struct CPed* m_pGamePed;
    unsigned int pad_2a8[2];
    unsigned char m_nPlayerNumber;
    unsigned int pad_2b1[2];
    GTAREF m_parachuteObject;
    GTAREF m_urinatingParticle;

    struct {
        int m_nType;
        GTAREF m_object;
        unsigned int m_nDrunkLevel;
    } m_stuff;

    GTAREF m_arrow;
    unsigned char field_2de;
    BOOL m_bDoesDancing;
    unsigned int m_nDanceStyle;
    unsigned int m_nLastDanceMove;
    unsigned char pad_2de[20];
    BOOL m_bDoesUrinating;
    unsigned char pad[55];
};
#pragma pack(pop)
]]

shared.validate_size('struct SAccessory', 0x34)
shared.validate_size('struct SCPed', 0x32D)

local CPed_constructor = ffi.cast(
    'void(__thiscall*)(SCPed*)',
    sampapi.GetAddress(0xAB690)
)

local CPed_constructorWithModel = ffi.cast(
    'void(__thiscall*)(SCPed*, int, int, SCVector, float)',
    sampapi.GetAddress(0xB08E0)
)

local function CPed_new()
    local obj = ffi.new('struct SCPed[1]')
    CPed_constructor(obj)
    return obj
end

local function CPed_newWithModel(nPlayerNumber, nModel, position, fRotation)
    local obj = ffi.new('struct SCPed[1]')
    CPed_constructorWithModel(obj, nPlayerNumber, nModel, position, fRotation)
    return obj
end

local SCPed_mt = {
    ResetPointers = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB7D0)),
    SetInitialState = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB7F0)),

    GetAim = ffi.cast('SAim*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB810)),
    SetAim = ffi.cast('void(__thiscall*)(SCPed*, const SAim*)',
        sampapi.GetAddress(0xAB850)),

    GetCurrentWeapon = ffi.cast('char(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB870)),
    GetVehicleRef = ffi.cast('GTAREF(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB8B0)),
    DeleteArrow = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB8D0)),
    IsOnScreen = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB900)),

    SetImmunities = ffi.cast(
        'void(__thiscall*)(SCPed*, BOOL, BOOL, BOOL, BOOL, BOOL)',
        sampapi.GetAddress(0xAB920)
    ),

    GetHealth = ffi.cast('float(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB970)),
    SetHealth = ffi.cast('void(__thiscall*)(SCPed*, float)',
        sampapi.GetAddress(0xAB990)),
    GetArmour = ffi.cast('float(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB9B0)),
    SetArmour = ffi.cast('void(__thiscall*)(SCPed*, float)',
        sampapi.GetAddress(0xAB9D0)),
    GetFlags = ffi.cast('int(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAB9F0)),
    SetFlags = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xABA10)),
    IsDead = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABA30)),
    GetState = ffi.cast('char(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABA60)),
    SetState = ffi.cast('void(__thiscall*)(SCPed*, char)',
        sampapi.GetAddress(0xABA70)),

    GetRotation = ffi.cast('float(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABAB0)),
    ForceRotation = ffi.cast('void(__thiscall*)(SCPed*, float)',
        sampapi.GetAddress(0xABB30)),
    SetRotation = ffi.cast('void(__thiscall*)(SCPed*, float)',
        sampapi.GetAddress(0xABB80)),
    IsPassenger = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABBE0)),
    GetVehicle = ffi.cast('SCVehicle*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABC20)),
    ClearWeapons = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABC30)),
    SetArmedWeapon = ffi.cast('void(__thiscall*)(SCPed*, int, bool)',
        sampapi.GetAddress(0xABC80)),
    RemoveWeaponWhenEnteringVehicle = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABD30)),
    GetCurrentWeaponSlot = ffi.cast('SCWeapon*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABD60)),
    CurrentWeaponHasAmmo = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABD80)),

    GetDistanceToEntity = ffi.cast(
        'float(__thiscall*)(SCPed*, const SCEntity*)',
        sampapi.GetAddress(0xABDC0)
    ),

    GetVehicleSeatIndex = ffi.cast('int(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xABE20)),
    PutIntoVehicle = ffi.cast('void(__thiscall*)(SCPed*, GTAREF, int)',
        sampapi.GetAddress(0xABEB0)),
    EnterVehicle = ffi.cast('void(__thiscall*)(SCPed*, GTAREF, BOOL)',
        sampapi.GetAddress(0xAC030)),
    ExitVehicle = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC100)),
    WarpFromVehicle = ffi.cast('void(__thiscall*)(SCPed*, SCVector)',
        sampapi.GetAddress(0xAC190)),
    SetSpawnInfo = ffi.cast('void(__thiscall*)(SCPed*, const SCVector*, float)',
        sampapi.GetAddress(0xAC370)),
    SetControllable = ffi.cast('void(__thiscall*)(SCPed*, BOOL)',
        sampapi.GetAddress(0xAC3B0)),
    GetDeathInfo = ffi.cast('char(__thiscall*)(SCPed*, ID*)',
        sampapi.GetAddress(0xAC470)),

    GetFloor = ffi.cast('SCEntity*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC630)),
    GetCurrentWeaponInfo = ffi.cast('SCWeaponInfo*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC6E0)),
    HandsUp = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC730)),
    DoesHandsUp = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC780)),

    EnableJetpack = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC930)),
    DisableJetpack = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC980)),
    HasJetpack = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAC9E0)),

    EnablePassengerDrivebyMode = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xACF90)),
    Extinguish = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD0F0)),
    GetCurrentWeaponAmmo = ffi.cast('unsigned short(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD150)),
    GetWeaponSlot = ffi.cast('SCWeapon*(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xACDB0)),

    SetWalkStyle = ffi.cast('void(__thiscall*)(SCPed*, const char*)',
        sampapi.GetAddress(0xACDF0)),
    PerformAnimation = ffi.cast(
        'void(__thiscall*)(SCPed*, const char*, const char*, float, int, int, int, int, int)',
        sampapi.GetAddress(0xACE50)
    ),
    LinkToInterior = ffi.cast('void(__thiscall*)(SCPed*, char, BOOL)',
        sampapi.GetAddress(0xACF60)),
    DestroyParachute = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD000)),
    OpenParachute = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD0F0)),
    ProcessParachuteEvent = ffi.cast('void(__thiscall*)(SCPed*, const char*)',
        sampapi.GetAddress(0xAD240)),
    IsOnGround = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD480)),
    ResetDamageEntity = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD4A0)),
    RemoveWeaponModel = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAD4D0)),
    GetAimZ = ffi.cast('float(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD510)),
    SetAimZ = ffi.cast('void(__thiscall*)(SCPed*, float)',
        sampapi.GetAddress(0xAD550)),

    GetContactEntity = ffi.cast('SCEntity*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD5A0)),
    GetContactVehicle = ffi.cast('SCVehicle*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD5B0)),
    GetStat = ffi.cast('int(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD5E0)),
    PerformingCustomAnimation = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD600)),
    StartDancing = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAD6D0)),
    StopDancing = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD720)),
    DoesDancing = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD760)),
    GetAnimationForDance = ffi.cast('const char*(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAD770)),

    DropStuff = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD800)),
    GetStuff = ffi.cast('int(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD890)),
    ApplyStuff = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD8A0)),
    ProcessDrunk = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAD9F0)),
    GetDrunkLevel = ffi.cast('int(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADBA0)),
    SetDrunkLevel = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xADBB0)),

    ApplyCommandTask = ffi.cast(
        'void(__thiscall*)(SCPed*, const char*, int, int, int, int, int, int, int, int, int)',
        sampapi.GetAddress(0xADBD0)
    ),
    DestroyCommandTask = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADC20)),
    EnableCellphone = ffi.cast('void(__thiscall*)(SCPed*, BOOL)',
        sampapi.GetAddress(0xADC70)),
    UsingCellphone = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADCA0)),
    SetFightingStyle = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xADCD0)),
    StartUrinating = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADD00)),
    StopUrinating = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADDE0)),
    DoesUrinating = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADE60)),
    GetLoadedShoppingDataSubsection = ffi.cast('const char*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xADEE0)),
    LoadShoppingDataSubsection = ffi.cast('void(__thiscall*)(SCPed*, const char*)',
        sampapi.GetAddress(0xADF00)),

    GetAimedPed = ffi.cast('struct CPed*(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAEB60)),
    SetKeys = ffi.cast('void(__thiscall*)(SCPed*, short, short, short)',
        sampapi.GetAddress(0xAEF40)),
    GetKeys = ffi.cast('short(__thiscall*)(SCPed*, short*, short*)',
        sampapi.GetAddress(0xAF1D0)),
    CreateArrow = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAF330)),
    SetModelIndex = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAFB50)),
    Kill = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAFBD0)),
    SetWeaponAmmo = ffi.cast('void(__thiscall*)(SCPed*, unsigned char, unsigned short)',
        sampapi.GetAddress(0xAFC80)),
    ProcessDancing = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAFCB0)),
    GiveStuff = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAFED0)),
    Destroy = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xB0BA0)),

    SetCameraMode = ffi.cast('void(__thiscall*)(SCPed*, char)',
        sampapi.GetAddress(0x141E0)),
    SetCameraExtZoomAndAspectRatio = ffi.cast('void(__thiscall*)(SCPed*, float, float)',
        sampapi.GetAddress(0x14200)),

    HasAccessory = ffi.cast('BOOL(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xAEA30)),
    DeleteAccessory = ffi.cast('void(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAEA50)),
    GetAccessoryState = ffi.cast('BOOL(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0xAEAB0)),
    DeleteAllAccessories = ffi.cast('void(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0xB06B0)),
    AddAccessory = ffi.cast('void(__thiscall*)(SCPed*, int, const SAccessory*)',
        sampapi.GetAddress(0xB0710)),
    GetAccessory = ffi.cast('SCObject*(__thiscall*)(SCPed*, int)',
        sampapi.GetAddress(0x13580)),
    GetCameraMode = ffi.cast('char(__thiscall*)(SCPed*)',
        sampapi.GetAddress(0x2D00)),
    GetBonePosition = ffi.cast('void(__thiscall*)(SCPed*, unsigned int, SCVector*)',
        sampapi.GetAddress(0xAE080)),
}

mt.set_handler('struct SCPed', '__index', SCPed_mt)

return {
    new = CPed_new,
    newWithModel = CPed_newWithModel,
    StuffType = SStuffType,
}
