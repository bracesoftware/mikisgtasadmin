
--[[
    Project: SAMP-API.lua <https://github.com/imring/SAMP-API.lua>
    Developers: imring, LUCHARE, FYP

    Special thanks:
        SAMemory (https://www.blast.hk/threads/20472/) for implementing the basic functions.
        SAMP-API (https://github.com/BlastHackNet/SAMP-API) for the structures and addresses.
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCEntity SCEntity;

struct CEntity;
struct RwObject;

#pragma pack(push, 1)
struct SCEntity {
    void** m_lpVtbl;
    char pad_4[60];
    struct CEntity* m_pGameEntity;
    GTAREF m_handle;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCEntity', 0x48)

local CEntity_constructor = ffi.cast(
    'void(__thiscall*)(SCEntity*)',
    sampapi.GetAddress(0x9BCE0)
)

local function CEntity_new(...)
    local obj = ffi.new('struct SCEntity[1]')
    CEntity_constructor(obj, ...)
    return obj
end

local SCEntity_mt = {
    GetMatrix = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCMatrix*)',
        sampapi.GetAddress(0x9E950)
    ),

    SetMatrix = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCMatrix)',
        sampapi.GetAddress(0x9EA00)
    ),

    GetSpeed = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector*)',
        sampapi.GetAddress(0x9EB20)
    ),

    SetSpeed = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector)',
        sampapi.GetAddress(0x9EB50)
    ),

    GetTurnSpeed = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector*)',
        sampapi.GetAddress(0x9EC70)
    ),

    SetTurnSpeed = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector)',
        sampapi.GetAddress(0x9ECA0)
    ),

    ApplyTurnSpeed = ffi.cast(
        'void(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9ECD0)
    ),

    GetDistanceFromCentreOfMassToBaseOfModel = ffi.cast(
        'float(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9ECF0)
    ),

    GetBoundCentre = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector*)',
        sampapi.GetAddress(0x9ED30)
    ),

    SetModelIndex = ffi.cast(
        'void(__thiscall*)(SCEntity*, int)',
        sampapi.GetAddress(0x9ED90)
    ),

    GetModelIndex = ffi.cast(
        'int(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9EE70)
    ),

    Teleport = ffi.cast(
        'void(__thiscall*)(SCEntity*, SCVector)',
        sampapi.GetAddress(0x9EE80)
    ),

    GetDistanceToLocalPlayer = ffi.cast(
        'float(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9EF00)
    ),

    GetDistanceToCamera = ffi.cast(
        'float(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9EFD0)
    ),

    GetDistanceToPoint = ffi.cast(
        'float(__thiscall*)(SCEntity*, SCVector)',
        sampapi.GetAddress(0x9F0F0)
    ),

    DoesExist = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9F210)
    ),

    EnforceWorldBoundries = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*, float, float, float, float)',
        sampapi.GetAddress(0x9F260)
    ),

    HasExceededWorldBoundries = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*, float, float, float, float)',
        sampapi.GetAddress(0x9F400)
    ),

    GetEulerInverted = ffi.cast(
        'void(__thiscall*)(SCEntity*, float*, float*, float*)',
        sampapi.GetAddress(0x9F730)
    ),

    IsIgnored = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9FB20)
    ),

    IsStationary = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9FC20)
    ),

    GetCollisionFlag = ffi.cast(
        'BOOL(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9F4A0)
    ),

    SetCollisionFlag = ffi.cast(
        'void(__thiscall*)(SCEntity*, BOOL)',
        sampapi.GetAddress(0x9F470)
    ),

    GetRwObject = ffi.cast(
        'struct RwObject*(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9F8A0)
    ),

    DeleteRwObject = ffi.cast(
        'void(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9F9F0)
    ),

    UpdateRwFrame = ffi.cast(
        'void(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9EAC0)
    ),

    GetDistanceToLocalPlayerNoHeight = ffi.cast(
        'float(__thiscall*)(SCEntity*)',
        sampapi.GetAddress(0x9F030)
    ),

    SetCollisionProcessed = ffi.cast(
        'void(__thiscall*)(SCEntity*, BOOL)',
        sampapi.GetAddress(0x9F4C0)
    ),
}

mt.set_handler('struct SCEntity', '__index', SCEntity_mt)

return {
    new = CEntity_new,
}
