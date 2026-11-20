
local sampapi = require 'sampapi'
local shared = sampapi.shared
local mt = require 'sampapi.metatype'
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SGangZone SGangZone;
typedef struct SCGangZonePool SCGangZonePool;

#pragma pack(push, 1)
struct SGangZone {
    struct {
        float left;
        float bottom;
        float right;
        float top;
    } m_rect;

    D3DCOLOR m_color;
    D3DCOLOR m_altColor;
};

enum {
    MAX_GANGZONES = 1024,
};

struct SCGangZonePool {
    SGangZone* m_pObject[MAX_GANGZONES];
    BOOL m_bNotEmpty[MAX_GANGZONES];
};
#pragma pack(pop)
]]

shared.validate_size('struct SGangZone', 0x18)
shared.validate_size('struct SCGangZonePool', 0x2000)

local CGangZonePool_constructor = ffi.cast(
    'void(__thiscall*)(SCGangZonePool*)',
    sampapi.GetAddress(0x2150)
)

local CGangZonePool_destructor = ffi.cast(
    'void(__thiscall*)(SCGangZonePool*)',
    sampapi.GetAddress(0x2180)
)

local function CGangZonePool_new()
    local obj = ffi.gc(
        ffi.new('struct SCGangZonePool[1]'),
        CGangZonePool_destructor
    )

    CGangZonePool_constructor(obj)
    return obj
end

local SCGangZonePool_mt = {
    Create = ffi.cast(
        'void(__thiscall*)(SCGangZonePool*, ID, float, float, float, float, D3DCOLOR)',
        sampapi.GetAddress(0x21B0)
    ),

    StartFlashing = ffi.cast(
        'void(__thiscall*)(SCGangZonePool*, ID, D3DCOLOR)',
        sampapi.GetAddress(0x2230)
    ),

    StopFlashing = ffi.cast(
        'void(__thiscall*)(SCGangZonePool*, ID)',
        sampapi.GetAddress(0x2250)
    ),

    Delete = ffi.cast(
        'void(__thiscall*)(SCGangZonePool*, ID)',
        sampapi.GetAddress(0x2270)
    ),

    Draw = ffi.cast(
        'void(__thiscall*)(SCGangZonePool*)',
        sampapi.GetAddress(0x22A0)
    ),
}

mt.set_handler('struct SCGangZonePool', '__index', SCGangZonePool_mt)

return {
    new = CGangZonePool_new,
}
