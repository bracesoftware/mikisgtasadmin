
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
enum {
    MAX_EXCEPTIONS = 9,
};
]]

local function RefCount()
    return ffi.cast(
        'int*',
        sampapi.GetAddress(0x163A70)
    )
end

local function RefContextRecord()
    return ffi.cast(
        'void**',
        sampapi.GetAddress(0x15FA68)
    )
end

local function ArrayCrashDialogText()
    return ffi.cast(
        'char*',
        sampapi.GetAddress(0x15FA70)
    )
end

local Print = ffi.cast(
    'BOOL(__stdcall*)(int, void*, const char*)',
    sampapi.GetAddress(0x60470)
)

local SendCrashReport = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0x60260)
)

local CrashDialogProc = ffi.cast(
    'BOOL(__stdcall*)(void*, unsigned int, unsigned int, long)',
    sampapi.GetAddress(0x60330)
)

local ConstructCrashDialogText = ffi.cast(
    'void(__cdecl*)(BOOL)',
    sampapi.GetAddress(0x60070)
)

local Handler = ffi.cast(
    'long(__stdcall*)(void*)',
    sampapi.GetAddress(0x60430)
)

return {
    RefCount = RefCount,
    RefContextRecord = RefContextRecord,
    ArrayCrashDialogText = ArrayCrashDialogText,

    Print = Print,
    SendCrashReport = SendCrashReport,
    CrashDialogProc = CrashDialogProc,
    ConstructCrashDialogText = ConstructCrashDialogText,
    Handler = Handler,
}
