
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
enum {
    MAX_ANTICHEAT_DETECT_COUNT = 0xA,
};
]]

local SwitchWindowedMode = ffi.cast(
    'void(__cdecl*)()',
    sampapi.GetAddress(0x60D90)
)

local function RefPrevWindowProc()
    return ffi.cast(
        'void**',
        sampapi.GetAddress(0x16BE78)
    )
end

local function RefAntiCheatDetectCount()
    return ffi.cast(
        'unsigned int*',
        sampapi.GetAddress(0x2ACA60)
    )
end

local WindowProc = ffi.cast(
    'int(__stdcall*)(unsigned int, unsigned int, long)',
    sampapi.GetAddress(0x610D0)
)

local KeyPressHandler = ffi.cast(
    'BOOL(__cdecl*)(unsigned int)',
    sampapi.GetAddress(0x60DE0)
)

local CharInputHandler = ffi.cast(
    'BOOL(__cdecl*)(unsigned int)',
    sampapi.GetAddress(0x61010)
)

local Initialize = ffi.cast(
    'BOOL(__cdecl*)()',
    sampapi.GetAddress(0x61940)
)

return {
    SwitchWindowedMode = SwitchWindowedMode,
    RefPrevWindowProc = RefPrevWindowProc,
    RefAntiCheatDetectCount = RefAntiCheatDetectCount,
    WindowProc = WindowProc,
    KeyPressHandler = KeyPressHandler,
    CharInputHandler = CharInputHandler,
    Initialize = Initialize,
}
