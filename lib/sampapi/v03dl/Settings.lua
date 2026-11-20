
local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

ffi.cdef[[
enum {
    SETTINGS_STRING_LEN = 256
};

typedef struct SSettings {
    BOOL m_bDebugMode;
    BOOL m_bOnlineGame;
    BOOL m_bWindowedMode;
    char m_szPass[257];
    char m_szHost[257];
    char m_szPort[257];
    char m_szNick[257];
    char m_szDebugScript[257];
} SSettings;
]]

shared.validate_size('SSettings', 0x511)

local GetAddress = sampapi.GetAddress

local Initialize =
    ffi.cast('void(__cdecl*)()', GetAddress(0xC5C90))

local GetFromCommandLine =
    ffi.cast('void(__cdecl*)(const char*, char*)', GetAddress(0xC5590))

local GetFromQuotes =
    ffi.cast('void(__cdecl*)(const char*, char*)', GetAddress(0xC55E0))

local function RefSettings()
    return ffi.cast('SSettings*', GetAddress(0x2ABE78))
end

return {
    Initialize = Initialize,
    GetFromCommandLine = GetFromCommandLine,
    GetFromQuotes = GetFromQuotes,
    RefSettings = RefSettings,
}
