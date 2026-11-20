
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.require 'CVector'
shared.require 'v03dl.CObjectPool'

shared.ffi.cdef[[
enum {
    LINE_BUFFER_LENGTH = 256,
};

typedef struct SCObjectPool SCObjectPool;
]]

local function RefPrivateObjectPool()
    return ffi.cast(
        'SCObjectPool**',
        sampapi.GetAddress(0x18DE44)
    )
end

local function RefObjectCount()
    return ffi.cast(
        'unsigned short*',
        sampapi.GetAddress(0x18DE48)
    )
end

local function RefNewCameraPos()
    return ffi.cast(
        'SCVector*',
        sampapi.GetAddress(0x18DE38)
    )
end

local Initialize = ffi.cast(
    'void(__cdecl*)(const char*)',
    sampapi.GetAddress(0x9E7F0)
)

local ProcessLine = ffi.cast(
    'void(__cdecl*)(const char*)',
    sampapi.GetAddress(0x9E6E0)
)

local GetCommandParams = ffi.cast(
    'char*(__cdecl*)(char*)',
    sampapi.GetAddress(0x9E2F0)
)

local CreateVehicle = ffi.cast(
    'void(__cdecl*)(const char*)',
    sampapi.GetAddress(0x9E450)
)

local CreateObject = ffi.cast(
    'void(__cdecl*)(const char*)',
    sampapi.GetAddress(0x9E340)
)

return {
    RefPrivateObjectPool = RefPrivateObjectPool,
    RefObjectCount = RefObjectCount,
    RefNewCameraPos = RefNewCameraPos,

    Initialize = Initialize,
    ProcessLine = ProcessLine,
    GetCommandParams = GetCommandParams,
    CreateVehicle = CreateVehicle,
    CreateObject = CreateObject,
}
