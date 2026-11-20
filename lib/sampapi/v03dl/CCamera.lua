
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
shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCCamera SCCamera;
#pragma pack(push, 1)
struct SCCamera {
    SCEntity* m_pAttachedTo;
    SCMatrix* m_pMatrix;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCCamera', 0x8)

local CCamera_constructor = ffi.cast(
    'void(__thiscall*)(SCCamera*)',
    sampapi.GetAddress(0x9FDA0)
)

local CCamera_destructor = ffi.cast(
    'void(__thiscall*)(SCCamera*)',
    sampapi.GetAddress(0x9FDB0)
)

local function CCamera_new(...)
    local obj = ffi.gc(ffi.new('struct SCCamera[1]'), CCamera_destructor)
    CCamera_constructor(obj, ...)
    return obj
end

local SCCamera_mt = {
    Fade = ffi.cast(
        'void(__thiscall*)(SCCamera*, BOOL)',
        sampapi.GetAddress(0x9D280)
    ),

    GetMatrix = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCMatrix*)',
        sampapi.GetAddress(0x9D2A0)
    ),

    SetMatrix = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCMatrix)',
        sampapi.GetAddress(0x9D320)
    ),

    TakeControl = ffi.cast(
        'void(__thiscall*)(SCCamera*, struct CEntity*, short, short)',
        sampapi.GetAddress(0x9D3B0)
    ),

    SetMoveVector = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCVector*, SCVector*, int, bool)',
        sampapi.GetAddress(0x9D3D0)
    ),

    SetTrackVector = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCVector*, SCVector*, int, bool)',
        sampapi.GetAddress(0x9D440)
    ),

    Attach = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCEntity*)',
        sampapi.GetAddress(0x9D4A0)
    ),

    SetToOwner = ffi.cast(
        'void(__thiscall*)(SCCamera*)',
        sampapi.GetAddress(0x9D4F0)
    ),

    GetDistanceToPoint = ffi.cast(
        'float(__thiscall*)(SCCamera*, SCVector*)',
        sampapi.GetAddress(0x9D540)
    ),

    Restore = ffi.cast(
        'void(__thiscall*)(SCCamera*)',
        sampapi.GetAddress(0x9D580)
    ),

    Set = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCVector, SCVector)',
        sampapi.GetAddress(0x9D5C0)
    ),

    PointAt = ffi.cast(
        'void(__thiscall*)(SCCamera*, SCVector, int)',
        sampapi.GetAddress(0x9D620)
    ),

    Detach = ffi.cast(
        'void(__thiscall*)(SCCamera*)',
        sampapi.GetAddress(0x9D670)
    ),
}

mt.set_handler('struct SCCamera', '__index', SCCamera_mt)

return {
    new = CCamera_new,
}
