
--[[
    Project: SAMP-API.lua
    Version: SA-MP 0.3.DL-1
]]

local sampapi = require 'sampapi'
local shared = sampapi.shared
local ffi = require 'ffi'

shared.ffi.cdef[[
typedef struct SCRemotePlayer SCRemotePlayer;

typedef struct SCPlayerInfo SCPlayerInfo;
#pragma pack(push, 1)
struct SCPlayerInfo {
    int m_nScore;
    BOOL m_bIsNPC;
    SCRemotePlayer* m_pPlayer;
    unsigned int m_nPing;
    unsigned int __align;
    unsigned char m_szNick[28];
};
#pragma pack(pop)
]]

shared.validate_size('struct SCPlayerInfo', 0x30)

local CPlayerInfo_constructor = ffi.cast(
    'void(__thiscall*)(SCPlayerInfo*, const char*, BOOL)',
    sampapi.GetAddress(0x14060)
)

local CPlayerInfo_destructor = ffi.cast(
    'void(__thiscall*)(SCPlayerInfo*)',
    sampapi.GetAddress(0x13E10)
)

local function CPlayerInfo_new(szName, bIsNPC)
    local obj = ffi.gc(
        ffi.new('struct SCPlayerInfo[1]'),
        CPlayerInfo_destructor
    )
    CPlayerInfo_constructor(obj, szName, bIsNPC)
    return obj
end

return {
    new = CPlayerInfo_new,
}
