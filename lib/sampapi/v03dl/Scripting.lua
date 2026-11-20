
local sampapi = require 'sampapi'
local ffi = require 'ffi'

ffi.cdef[[
typedef struct SCRunningScript SCRunningScript;

typedef struct SOpcodeInfo {
    unsigned short m_wOpCode;
    char m_szParams[16];
} SOpcodeInfo;

typedef int (__thiscall *SProcessOneCommandFn)(SCRunningScript*);
typedef int (__cdecl *SFunctionProcessCommandFn)(const SOpcodeInfo*, ...);
]]

local GetAddress = sampapi.GetAddress

shared = sampapi.shared
shared.validate_size('SOpcodeInfo', 0x12)

local function RefThread()
    return ffi.cast('SCRunningScript**', GetAddress(0x2A93F0))
end

local function ArrayBuffer()
    return ffi.cast('unsigned char*', GetAddress(0x2A92F0))
end

local function RefLastUsedOpcode()
    return ffi.cast('unsigned long*', GetAddress(0x2A93F4))
end

local function ArrayThreadLocals()
    return ffi.cast('unsigned long**', GetAddress(0x2A92A8))
end

local function RefLocalDebug()
    return ffi.cast('BOOL*', GetAddress(0x2A93F8))
end

local function RefProcessOneCommand()
    return ffi.cast('SProcessOneCommandFn*', GetAddress(0x155390))
end

local Initialize =
    ffi.cast('void(__cdecl*)()', GetAddress(0xB2150))

local ExecBuffer =
    ffi.cast('int(__cdecl*)()', GetAddress(0xB1ED0))

local FunctionProcessCommand =
    ffi.cast('SFunctionProcessCommandFn', GetAddress(0xB1F10))

return {
    RefThread = RefThread,
    ArrayBuffer = ArrayBuffer,
    RefLastUsedOpcode = RefLastUsedOpcode,
    ArrayThreadLocals = ArrayThreadLocals,
    RefLocalDebug = RefLocalDebug,
    RefProcessOneCommand = RefProcessOneCommand,
    Initialize = Initialize,
    ExecBuffer = ExecBuffer,
    FunctionProcessCommand = FunctionProcessCommand,
}
