
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
shared.require 'CMatrix'
shared.require 'CVector'

shared.ffi.cdef[[
typedef struct SCActor SCActor;

#pragma pack(push, 1)
struct SCActor : SCEntity {
    struct CPed* m_pGamePed;
    GTAREF m_marker;
    GTAREF m_arrow;
    bool m_bNeedsToCreateMarker;
    bool m_bInvulnerable;
};
#pragma pack(pop)
]]

shared.validate_size('struct SCActor', 0x56)

-- Constructor

local CActor_constructor =
    ffi.cast(
        'void(__thiscall*)(SCActor*, int, SCVector, float)',
        sampapi.GetAddress(0x9BD30)
    )

local function CActor_new(...)
    local obj = ffi.new('struct SCActor[1]')
    CActor_constructor(obj, ...)
    return obj
end

-- Methods

local SCActor_mt = {
    Destroy = ffi.cast(
        'void(__thiscall*)(SCActor*)',
        sampapi.GetAddress(0x9BE80)
    ),

    PerformAnimation = ffi.cast(
        'void(__thiscall*)(SCActor*, const char*, const char*, float, int, int, int, int, int)',
        sampapi.GetAddress(0x9BEE0)
    ),

    SetRotation = ffi.cast(
        'void(__thiscall*)(SCActor*, float)',
        sampapi.GetAddress(0x9BFF0)
    ),

    GetHealth = ffi.cast(
        'float(__thiscall*)(SCActor*)',
        sampapi.GetAddress(0x9C030)
    ),

    SetHealth = ffi.cast(
        'void(__thiscall*)(SCActor*, float)',
        sampapi.GetAddress(0x9C050)
    ),

    SetInvulnerable = ffi.cast(
        'void(__thiscall*)(SCActor*, bool)',
        sampapi.GetAddress(0x9C180)
    ),
}

mt.set_handler('struct SCActor', '__index', SCActor_mt)

return {
    new = CActor_new,
}
