
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCPad SCPad;
]]

-- Globalne CPad promenljive

local function RefLocalPlayerKeys()
    return ffi.cast(
        'SCPad*',
        sampapi.GetAddress(0x190660)
    )
end

local function ArrayPlayerKeys()
    return ffi.cast(
        'SCPad*',
        sampapi.GetAddress(0x190798)
    )
end

local function RefInternalKeys()
    return ffi.cast(
        'SCPad**',
        sampapi.GetAddress(0x152AC0)
    )
end

local function RefDriveByLeft()
    return ffi.cast(
        'bool**',
        sampapi.GetAddress(0x152AC4)
    )
end

local function RefDriveByRight()
    return ffi.cast(
        'bool**',
        sampapi.GetAddress(0x152AC8)
    )
end

local function RefSavedDriveByLeft()
    return ffi.cast(
        'bool*',
        sampapi.GetAddress(0x1A0440)
    )
end

local function RefSavedDriveByRight()
    return ffi.cast(
        'bool*',
        sampapi.GetAddress(0x1A0441)
    )
end

-- Funkcije

local Initialize = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xA6FE0)
)

local UpdateKeys = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xA7000)
)

local ApplyKeys = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xA7040)
)

local SetKeys = ffi.cast(
    'void(__cdecl*)(int, const SCPad*)',
    sampapi.GetAddress(0xA7080)
)

local ApplyKeysForPlayer = ffi.cast(
    'void(__cdecl*)(int)',
    sampapi.GetAddress(0xA70A0)
)

local GetInternalKeys = ffi.cast(
    'SCPad*(__cdecl*)()',
    sampapi.GetAddress(0xA70F0)
)

local GetKeys = ffi.cast(
    'SCPad*(__cdecl*)()',
    sampapi.GetAddress(0xA7100)
)

local GetKeysForPlayer = ffi.cast(
    'SCPad*(__cdecl*)(int)',
    sampapi.GetAddress(0xA7110)
)

local ResetKeys = ffi.cast(
    'void(__cdecl*)(int)',
    sampapi.GetAddress(0xA7120)
)

local ResetInternalKeys = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0xA7140)
)

return {
    RefLocalPlayerKeys = RefLocalPlayerKeys,
    ArrayPlayerKeys = ArrayPlayerKeys,
    RefInternalKeys = RefInternalKeys,
    RefDriveByLeft = RefDriveByLeft,
    RefDriveByRight = RefDriveByRight,
    RefSavedDriveByLeft = RefSavedDriveByLeft,
    RefSavedDriveByRight = RefSavedDriveByRight,

    Initialize = Initialize,
    UpdateKeys = UpdateKeys,
    ApplyKeys = ApplyKeys,
    SetKeys = SetKeys,
    ApplyKeysForPlayer = ApplyKeysForPlayer,
    GetInternalKeys = GetInternalKeys,
    GetKeys = GetKeys,
    GetKeysForPlayer = GetKeysForPlayer,
    ResetKeys = ResetKeys,
    ResetInternalKeys = ResetInternalKeys,
}
